import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/l10n/app_strings.dart';
import '../../observations/domain/observation_report.dart';

class ReportPdf {
  static Future<Uint8List> build(ObservationReport report) async {
    final doc = pw.Document();
    final images = <pw.Widget>[];
    for (final path in report.attachmentPaths) {
      final file = File(path);
      if (await file.exists()) {
        images.add(pw.Padding(padding: const pw.EdgeInsets.only(top: 8),
          child: pw.Image(pw.MemoryImage(await file.readAsBytes()),
            height: 160, fit: pw.BoxFit.contain)));
      }
    }
    pw.Widget field(String label, String value) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(label.toUpperCase(), style: pw.TextStyle(fontSize: 9,
          color: PdfColors.blueGrey700, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 3),
        pw.Text(value.isEmpty ? '—' : value, style: const pw.TextStyle(fontSize: 11)),
      ]),
    );
    final signatureFile = report.signaturePath == null ? null : File(report.signaturePath!);
    final signature = signatureFile != null && await signatureFile.exists()
        ? pw.Image(pw.MemoryImage(await signatureFile.readAsBytes()), height: 60)
        : null;
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      header: (_) => pw.Container(
        padding: const pw.EdgeInsets.only(bottom: 10),
        decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.orange))),
        child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text(AppStrings.appName, style: pw.TextStyle(fontSize: 17,
            fontWeight: pw.FontWeight.bold)),
          pw.Text(report.id, style: const pw.TextStyle(fontSize: 10)),
        ]),
      ),
      footer: (context) => pw.Align(alignment: pw.Alignment.centerRight,
        child: pw.Text('${context.pageNumber} / ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 9))),
      build: (_) => [
        pw.SizedBox(height: 16),
        pw.Text('Safety Observation Report', style: pw.TextStyle(fontSize: 20,
          fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 16),
        pw.TableHelper.fromTextArray(headers: const ['Type', 'Status', 'Risk', 'Date'], data: [[
          AppStrings.typeLabel(report.type), AppStrings.statusLabel(report.status),
          report.risk == null ? '—' : AppStrings.riskLabel(report.risk!),
          report.createdAt.toLocal().toString().split('.').first,
        ]]),
        pw.SizedBox(height: 16),
        field(AppStrings.area, report.area),
        field(AppStrings.employeeName, report.employeeName),
        field(AppStrings.employeeNumber, report.employeeNumber),
        field(AppStrings.department, report.employeeDepartment),
        field(AppStrings.observedEvent, report.observedEvent),
        field(AppStrings.potentialHazard, report.potentialHazard),
        field(AppStrings.actionTaken, report.actionTaken),
        field(AppStrings.furtherActionsLabel, report.furtherActions),
        field(AppStrings.safetyCategories, report.safetyCategories.join(', ')),
        field(AppStrings.encouragementLabel, report.encouragement),
        field(AppStrings.immediateCorrectionLabel, report.immediateCorrectiveAction),
        field(AppStrings.supervisorNotified, report.supervisorNotified ? AppStrings.yes : AppStrings.no),
        field(AppStrings.supervisorName, report.supervisorName),
        field(AppStrings.supervisorNotes, report.supervisorFurtherAction),
        if (signature != null) ...[
          pw.Text(AppStrings.supervisorSignature), signature,
        ],
        if (images.isNotEmpty) ...[
          pw.Text(AppStrings.evidencePhotos,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ...images,
        ],
      ],
    ));
    return doc.save();
  }
}
