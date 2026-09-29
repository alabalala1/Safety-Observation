import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/l10n/app_strings.dart';
import '../../observations/domain/observation_report.dart';

/// Print layout based on the Figma report template (node 28:4). Content remains
/// data-driven and may flow onto more A4 pages when notes or photos are long.
class ReportPdf {
  static const _ink = PdfColor.fromInt(0xFF0F172A);
  static const _secondary = PdfColor.fromInt(0xFF475569);
  static const _muted = PdfColor.fromInt(0xFF64748B);
  static const _border = PdfColor.fromInt(0xFFCBD5E1);
  static const _slate = PdfColor.fromInt(0xFFF1F5F9);
  static const _orange = PdfColor.fromInt(0xFFEA580C);
  static const _green = PdfColor.fromInt(0xFF16A34A);

  static const _months = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String _date(DateTime date) =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';

  static String _time(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    return '${hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} '
        '${date.hour < 12 ? 'AM' : 'PM'}';
  }

  static pw.Text _text(String value, {double size = 9, PdfColor? color,
      bool bold = false, double? lineSpacing, pw.TextAlign? align}) => pw.Text(
        value.isEmpty ? '-' : value,
        textDirection: RegExp(r'[\u0600-\u06FF]').hasMatch(value)
            ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        textAlign: align,
        style: pw.TextStyle(fontSize: size, color: color ?? _ink,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          lineSpacing: lineSpacing),
      );

  static pw.Widget _section(String title) => pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: const pw.BoxDecoration(color: _slate,
          border: pw.Border(bottom: pw.BorderSide(color: _border, width: 0.7))),
        child: _text(title.toUpperCase(), size: 10, bold: true),
      );

  static pw.Widget _metaLine(String label, pw.Widget value) => pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _text('$label:', size: 8, color: _muted, bold: true),
          pw.SizedBox(width: 4),
          pw.Expanded(child: value),
        ],
      );

  static pw.Widget _employeeCell(String label, String value) => pw.Expanded(
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _text(label.toUpperCase(), size: 8, color: _muted),
            pw.SizedBox(height: 2),
            _text(value, size: 9, bold: true),
          ]),
      );

  static pw.Widget _paragraph(String value, {PdfColor? color}) => pw.Padding(
        padding: const pw.EdgeInsets.fromLTRB(8, 4, 8, 3),
        child: _text(value, size: 9, color: color, lineSpacing: 2.6),
      );

  static pw.Widget _labeledParagraph(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.fromLTRB(8, 3, 8, 4),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _text(label, size: 9, bold: true),
            pw.SizedBox(height: 2),
            _text(value, size: 9, color: _secondary, lineSpacing: 2),
          ]),
      );

  static pw.Widget _feedback(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.fromLTRB(8, 3, 8, 4),
        child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          _text(label, size: 9, bold: true),
          pw.SizedBox(width: 4),
          pw.Expanded(child: _text(value, size: 9, color: _secondary,
            lineSpacing: 1.8)),
        ]),
      );

  static pw.Widget _risk(ObservationReport report) {
    final (color, tint, label) = switch (report.risk) {
      RiskRanking.high => (const PdfColor.fromInt(0xFFDC2626),
        const PdfColor.fromInt(0xFFFEF2F2), 'HIGH'),
      RiskRanking.medium => (const PdfColor.fromInt(0xFFB45309),
        const PdfColor.fromInt(0xFFFFFBEB), 'MEDIUM'),
      RiskRanking.low => (const PdfColor.fromInt(0xFF16A34A),
        const PdfColor.fromInt(0xFFF0FDF4), 'LOW'),
      null => (_muted, _slate, 'NOT SET'),
    };
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: pw.BoxDecoration(color: tint,
        border: pw.Border.all(color: color, width: 0.7),
        borderRadius: pw.BorderRadius.circular(3)),
      child: _text(label, size: 8, bold: true, color: color),
    );
  }

  static pw.Widget _header(pw.Context context, ObservationReport report) =>
      pw.Column(children: [
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
          pw.Container(width: 98, height: 28,
            alignment: pw.Alignment.center,
            decoration: pw.BoxDecoration(color: const PdfColor.fromInt(0xFFF8FAFC),
              border: pw.Border.all(color: _border, width: 0.7),
              borderRadius: pw.BorderRadius.circular(4)),
            child: _text('COMPANY LOGO', size: 8, color: _muted, bold: true)),
          pw.Expanded(child: pw.Column(children: [
            _text('SAFETY OBSERVATION REPORT', size: 15, bold: true,
              align: pw.TextAlign.center),
            pw.SizedBox(height: 3),
            _text('STOP CARD SYSTEM - OFF-SITE DIRECT EXPORT', size: 7.5,
              color: _orange, bold: true, align: pw.TextAlign.center),
          ])),
          pw.SizedBox(width: 115, child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
              _text(report.id, size: 8.5, bold: true,
                align: pw.TextAlign.right),
              pw.SizedBox(height: 3),
              _text('Page ${context.pageNumber} of ${context.pagesCount}',
                size: 8, color: _muted),
            ])),
        ]),
        pw.SizedBox(height: 13),
        pw.Container(height: 2, color: _orange),
        pw.SizedBox(height: 10),
      ]);

  static pw.Widget _footer(pw.Context context, DateTime exported) =>
      pw.Column(children: [
        pw.Container(height: 1, color: _orange),
        pw.SizedBox(height: 7),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          _text('Generated by Safety Observation App - STOP CARD SYSTEM',
            size: 7.5, color: _muted),
          _text('EXPORTED: ${_date(exported).toUpperCase()} - '
            'PAGE ${context.pageNumber} OF ${context.pagesCount}',
            size: 7.5, color: _muted),
        ]),
      ]);

  static Future<Uint8List> build(ObservationReport report) async {
    final regular = pw.Font.ttf(await rootBundle.load('assets/fonts/ReportSans-Regular.ttf'));
    final bold = pw.Font.ttf(await rootBundle.load('assets/fonts/ReportSans-Bold.ttf'));
    final pdf = pw.Document();
    final recorded = report.createdAt.toLocal();
    final exported = DateTime.now();

    final photos = <pw.MemoryImage>[];
    for (final path in report.attachmentPaths) {
      final file = File(path);
      if (await file.exists()) {
        photos.add(pw.MemoryImage(await file.readAsBytes()));
      }
    }
    final signatureFile = report.signaturePath == null
        ? null : File(report.signaturePath!);
    final signature = signatureFile != null && await signatureFile.exists()
        ? pw.MemoryImage(await signatureFile.readAsBytes()) : null;

    final type = AppStrings.typeLabel(report.type);
    final category = report.stopCardCategory == null ? '' :
        report.stopCardCategory == StopCardCategory.positive
            ? AppStrings.positive : AppStrings.unsafeCorrective;

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 28),
      theme: pw.ThemeData.withFont(base: regular, bold: bold),
      maxPages: 50,
      header: (context) => _header(context, report),
      footer: (context) => _footer(context, exported),
      build: (_) => [
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Expanded(child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              _metaLine('DATE', _text(_date(recorded), size: 9)),
              pw.SizedBox(height: 7),
              _metaLine('TIME', _text(_time(recorded), size: 9)),
              pw.SizedBox(height: 7),
              _metaLine('AREA', _text(report.area, size: 9)),
            ])),
          pw.SizedBox(width: 24),
          pw.Expanded(child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              _metaLine('REPORT TYPE', _text(category.isEmpty ? type : '$type / $category',
                size: 9, bold: true)),
              pw.SizedBox(height: 7),
              _metaLine('RISK LEVEL', _risk(report)),
              pw.SizedBox(height: 7),
              _metaLine('STATUS', _text(AppStrings.statusLabel(report.status),
                size: 9, color: report.status == ReportStatus.completed
                    ? _green : _secondary, bold: true)),
            ])),
        ]),
        pw.SizedBox(height: 14),
        _section('Employee Information'),
        pw.SizedBox(height: 6),
        pw.Padding(padding: const pw.EdgeInsets.symmetric(horizontal: 8),
          child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            _employeeCell('Employee Name', report.employeeName),
            pw.SizedBox(width: 16),
            _employeeCell('Employee Number', report.employeeNumber),
            pw.SizedBox(width: 16),
            _employeeCell('Department / Plant', report.employeeDepartment),
          ])),
        pw.SizedBox(height: 14),
        _section('Observed Event / Incident Details'),
        _paragraph(report.observedEvent),
        pw.SizedBox(height: 10),
        _section('Potential Hazard / Expected Outcome'),
        _paragraph(report.potentialHazard),
        pw.SizedBox(height: 10),
        _section('Actions Actioned & Requested'),
        _labeledParagraph('Immediate Action Taken:', report.actionTaken),
        _labeledParagraph('Further Action Required:', report.furtherActions),
        pw.SizedBox(height: 10),
        _section('Safety Categories Evaluated'),
        pw.SizedBox(height: 5),
        if (report.safetyCategories.isEmpty)
          _paragraph('No categories selected.')
        else
          pw.Padding(padding: const pw.EdgeInsets.symmetric(horizontal: 8),
            child: pw.Wrap(spacing: 12, runSpacing: 7, children: [
              for (final item in report.safetyCategories)
                pw.SizedBox(width: 160, child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    _text('✓', size: 10, color: _orange, bold: true),
                    pw.SizedBox(width: 6),
                    pw.Expanded(child: _text(item, size: 8.5)),
                  ])),
            ])),
        pw.SizedBox(height: 12),
        _section('Safe / Unsafe Actions & Feedbacks'),
        _feedback('Encouragement Given:', report.encouragement),
        _feedback('Corrective Action:', report.immediateCorrectiveAction),
        pw.SizedBox(height: 10),
        _section('Supervisor Verification & Clearance'),
        pw.SizedBox(height: 4),
        pw.Padding(padding: const pw.EdgeInsets.symmetric(horizontal: 8),
          child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
            pw.Expanded(child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                _feedback('Supervisor Name:', report.supervisorNotified
                  ? report.supervisorName : 'Not notified'),
                _feedback('Further Action Taken:', report.supervisorFurtherAction),
              ])),
            pw.SizedBox(width: 16),
            pw.Container(width: 100, height: 42,
              alignment: pw.Alignment.center,
              decoration: pw.BoxDecoration(color: const PdfColor.fromInt(0xFFFAFBFD),
                border: pw.Border.all(color: _border, width: 0.7),
                borderRadius: pw.BorderRadius.circular(4)),
              child: signature == null
                  ? _text('NOT SIGNED', size: 7.5, color: _muted)
                  : pw.Image(signature, fit: pw.BoxFit.contain)),
          ])),
        pw.SizedBox(height: 14),
        _section('Attachments / Photographic Evidence'),
        pw.SizedBox(height: 6),
        if (photos.isEmpty)
          _paragraph('No photos attached.')
        else
          pw.Wrap(spacing: 8, runSpacing: 10, children: [
              for (var i = 0; i < photos.length; i++)
                pw.SizedBox(width: 257, child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    pw.Container(height: 118, width: 257,
                      padding: const pw.EdgeInsets.all(3),
                      decoration: pw.BoxDecoration(color: _slate,
                        border: pw.Border.all(color: _border, width: 0.7),
                        borderRadius: pw.BorderRadius.circular(4)),
                      child: pw.Image(photos[i], fit: pw.BoxFit.contain)),
                    pw.SizedBox(height: 4),
                    _text('Photo ${i + 1}', size: 8, color: _secondary),
                  ])),
            ]),
        pw.SizedBox(height: 5),
        pw.Padding(padding: const pw.EdgeInsets.symmetric(horizontal: 8),
          child: _text('Photos are stored locally and attached to the report file.',
            size: 8, color: _muted)),
      ],
    ));
    return pdf.save();
  }
}
