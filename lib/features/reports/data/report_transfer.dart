import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../app/app_services.dart';
import '../../observations/domain/observation_report.dart';

class ReportAlreadyExists implements Exception {
  const ReportAlreadyExists();
}

class ReportTransfer {
  static const _maxArchiveBytes = 50 * 1024 * 1024;
  static const _maxExpandedBytes = 100 * 1024 * 1024;
  static const _maxEntryBytes = 12 * 1024 * 1024;

  static Future<List<int>> _package(ObservationReport report) async {
    final archive = Archive();
    final json = Map<String, Object?>.from(report.toJson());
    final photos = <String>[];
    for (var i = 0; i < report.attachmentPaths.length; i++) {
      final file = File(report.attachmentPaths[i]);
      if (!await file.exists()) continue;
      final name = 'photos/$i.${p.extension(file.path).toLowerCase() == '.png' ? 'png' : 'jpg'}';
      archive.addFile(ArchiveFile.bytes(name, await file.readAsBytes()));
      photos.add(name);
    }
    json['attachmentPaths'] = photos;
    final signature = report.signaturePath == null ? null : File(report.signaturePath!);
    if (signature != null && await signature.exists()) {
      const name = 'signatures/supervisor.png';
      archive.addFile(ArchiveFile.bytes(name, await signature.readAsBytes()));
      json['signaturePath'] = name;
    } else {
      json['signaturePath'] = null;
    }
    archive.addFile(ArchiveFile.string('report.json', jsonEncode(json)));
    return ZipEncoder().encode(archive);
  }

  static Future<File> exportReport(ObservationReport report) async {
    final directory = await getTemporaryDirectory();
    final file = File(p.join(directory.path, '${report.id}.safety'));
    await file.writeAsBytes(await _package(report), flush: true);
    return file;
  }

  static Archive _decode(List<int> bytes, {int maxEntries = 40}) {
    if (bytes.length > _maxArchiveBytes) throw const FormatException('Archive too large');
    final archive = ZipDecoder().decodeBytes(bytes);
    if (archive.length > maxEntries) throw const FormatException('Too many files');
    var total = 0;
    for (final entry in archive) {
      if (!entry.isFile || entry.size > _maxEntryBytes ||
          entry.name.contains('..') || entry.name.startsWith('/') ||
          entry.name.contains('\\')) throw const FormatException('Invalid archive entry');
      total += entry.size;
      if (total > _maxExpandedBytes) throw const FormatException('Archive too large');
    }
    return archive;
  }

  static Future<ObservationReport> _import(List<int> bytes,
      {ReportStatus? statusOverride}) async {
    final archive = _decode(bytes);
    final entry = archive.files.where((item) => item.name == 'report.json').toList();
    if (entry.length != 1) throw const FormatException('Missing report');
    final json = jsonDecode(utf8.decode(entry.single.readBytes())) as Map<String, dynamic>;
    if (json['schemaVersion'] != 1) throw const FormatException('Unsupported report version');
    final id = json['id'] as String?;
    if (id == null || !RegExp(r'^OBS-[A-Za-z0-9-]{1,60}$').hasMatch(id)) {
      throw const FormatException('Invalid report ID');
    }
    if (await AppServices.reports.findById(id) != null) {
      throw const ReportAlreadyExists();
    }
    final photoNames = List<String>.from((json['attachmentPaths'] as List<dynamic>?) ?? []);
    final signatureName = json['signaturePath'] as String?;
    for (final name in [...photoNames, if (signatureName != null) signatureName]) {
      if (!RegExp(r'^(photos/[0-9]+\.(jpg|png)|signatures/supervisor\.png)$').hasMatch(name) ||
          archive.files.where((item) => item.name == name).length != 1) {
        throw const FormatException('Missing or invalid media');
      }
    }
    json['attachmentPaths'] = <String>[];
    json['signaturePath'] = null;
    final report = ObservationReport.fromJson(json);
    final storedPhotos = <String>[];
    try {
      for (final name in photoNames) {
        final media = archive.files.singleWhere((item) => item.name == name);
        storedPhotos.add(await AppServices.media.importMedia(id,
          name.endsWith('.png') ? 'png' : 'jpg', media.readBytes()));
      }
      String? storedSignature;
      if (signatureName != null) {
        final media = archive.files.singleWhere((item) => item.name == signatureName);
        storedSignature = await AppServices.media.importMedia(id, 'png', media.readBytes());
      }
      final received = report.withDetails(
        status: statusOverride ?? report.status,
        attachmentPaths: storedPhotos,
        signaturePath: storedSignature,
      );
      await AppServices.reports.save(received);
      return received;
    } catch (_) {
      await AppServices.media.deleteMedia(id);
      rethrow;
    }
  }

  static Future<ObservationReport> importReport(File file) async =>
      _import(await file.readAsBytes(), statusOverride: ReportStatus.received);

  static Future<File> exportBackup() async {
    final reports = await AppServices.reports.search();
    final archive = Archive();
    for (final report in reports) {
      archive.addFile(ArchiveFile.bytes('reports/${report.id}.safety',
        await _package(report)));
    }
    archive.addFile(ArchiveFile.string('backup.json', jsonEncode({
      'schemaVersion': 1,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'reportCount': reports.length,
    })));
    final directory = await getTemporaryDirectory();
    final file = File(p.join(directory.path,
      'SafetyApp_Backup_${DateTime.now().millisecondsSinceEpoch}.sbackup'));
    await file.writeAsBytes(ZipEncoder().encode(archive), flush: true);
    return file;
  }

  static Future<int> importBackup(File file) async {
    final archive = _decode(await file.readAsBytes(), maxEntries: 1001);
    final manifest = archive.files.where((entry) => entry.name == 'backup.json').toList();
    if (manifest.length != 1) throw const FormatException('Invalid backup');
    final metadata = jsonDecode(utf8.decode(manifest.single.readBytes())) as Map<String, dynamic>;
    if (metadata['schemaVersion'] != 1) throw const FormatException('Unsupported backup');
    var imported = 0;
    for (final entry in archive.files.where((item) =>
        item.name.startsWith('reports/') && item.name.endsWith('.safety'))) {
      try {
        await _import(entry.readBytes());
        imported++;
      } on ReportAlreadyExists {
        // Existing report IDs are kept; backup restore never overwrites them.
      }
    }
    return imported;
  }
}
