import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../domain/observation_report.dart';
import 'report_repository.dart';

class ReportMediaStore {
  ReportMediaStore(this._reports);
  final ReportRepository _reports;
  final ImagePicker _picker = ImagePicker();

  Future<Directory> _directory(String reportId) async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory(p.join(root.path, 'report_media', reportId));
    await directory.create(recursive: true);
    return directory;
  }

  String _name(String extension) {
    final suffix = Random.secure().nextInt(0x7fffffff).toRadixString(16);
    return '${DateTime.now().microsecondsSinceEpoch}_$suffix.$extension';
  }

  Future<ObservationReport?> addPhoto(String reportId, ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80,
      maxWidth: 1600);
    if (picked == null) return null;
    final extension = p.extension(picked.path).toLowerCase() == '.png' ? 'png' : 'jpg';
    final directory = await _directory(reportId);
    final copied = await File(picked.path).copy(p.join(directory.path, _name(extension)));
    try {
      return await _reports.update(reportId, (report) => report.withDetails(
        attachmentPaths: [...report.attachmentPaths, copied.path]));
    } catch (_) {
      await copied.delete();
      rethrow;
    }
  }

  Future<ObservationReport> removePhoto(String reportId, String path) async {
    final report = await _reports.update(reportId, (value) => value.withDetails(
      attachmentPaths: value.attachmentPaths.where((item) => item != path).toList()));
    final file = File(path);
    if (await file.exists()) await file.delete();
    return report;
  }

  Future<ObservationReport> saveSignature(String reportId, Uint8List bytes) async {
    final directory = await _directory(reportId);
    final file = File(p.join(directory.path, _name('png')));
    await file.writeAsBytes(bytes, flush: true);
    try {
      final report = await _reports.update(reportId,
        (value) => value.withDetails(signaturePath: file.path));
      return report;
    } catch (_) {
      await file.delete();
      rethrow;
    }
  }

  Future<String> importMedia(String reportId, String extension, List<int> bytes) async {
    final directory = await _directory(reportId);
    final safeExtension = extension == 'png' ? 'png' : 'jpg';
    final file = File(p.join(directory.path, _name(safeExtension)));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<void> deleteMedia(String reportId) async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory(p.join(root.path, 'report_media', reportId));
    if (await directory.exists()) await directory.delete(recursive: true);
  }
}
