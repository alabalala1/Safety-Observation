import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

import '../../../app/app_services.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../observations/presentation/observation_form_widgets.dart';
import '../../reports/data/report_transfer.dart';
import 'active_site_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _name = '', _number = '', _department = '', _site = '';
  String _dateFormat = 'DD MMM YYYY', _timeFormat = '12-hour';
  String _organization = '';
  int? _storageBytes;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final profile = await AppServices.reports.loadProfile();
      final values = await Future.wait([
        AppServices.reports.loadSetting('activeSite'),
        AppServices.reports.loadSetting('dateFormat'),
        AppServices.reports.loadSetting('timeFormat'),
        AppServices.reports.loadSetting('organization'),
      ]);
      final bytes = await _storageUsed();
      if (!mounted) return;
      setState(() {
        _name = profile['name'] ?? '';
        _number = profile['employeeNumber'] ?? '';
        _department = profile['department'] ?? '';
        _site = values[0] ?? '';
        _dateFormat = values[1] ?? _dateFormat;
        _timeFormat = values[2] ?? _timeFormat;
        _organization = values[3] ?? '';
        _storageBytes = bytes;
      });
    } catch (_) {
      _message(AppStrings.loadFailed);
    }
  }

  Future<int> _storageUsed() async {
    var total = 0;
    final database = File(p.join(await getDatabasesPath(), 'safety_observation.db'));
    if (await database.exists()) total += await database.length();
    final root = await getApplicationDocumentsDirectory();
    final media = Directory(p.join(root.path, 'report_media'));
    if (await media.exists()) {
      await for (final entry in media.list(recursive: true, followLinks: false)) {
        if (entry is File) total += await entry.length();
      }
    }
    return total;
  }

  void _message(String message) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _edit(String label, String current, Future<void> Function(String) save) async {
    final controller = TextEditingController(text: current);
    final value = await showDialog<String>(context: context, builder: (dialog) => AlertDialog(
      title: Text(label),
      content: TextField(controller: controller, autofocus: true,
        maxLength: 100, decoration: InputDecoration(labelText: label),
        onSubmitted: (text) => Navigator.pop(dialog, text.trim())),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialog), child: const Text(AppStrings.cancel)),
        FilledButton(onPressed: () => Navigator.pop(dialog, controller.text.trim()),
          child: const Text(AppStrings.save)),
      ],
    ));
    controller.dispose();
    if (value == null || !mounted) return;
    try {
      await save(value);
      if (mounted) setState(() {});
    } catch (_) {
      _message(AppStrings.saveFailed);
    }
  }

  Future<void> _profile(String label, String current, String field) => _edit(label, current, (value) async {
    final name = field == 'name' ? value : _name;
    final number = field == 'number' ? value : _number;
    final department = field == 'department' ? value : _department;
    await AppServices.reports.saveProfile(name: name,
      employeeNumber: number, department: department);
    _name = name; _number = number; _department = department;
    _message(AppStrings.profileSaved);
  });

  Future<void> _choice(String label, String current, List<String> choices,
      String key, void Function(String) apply) async {
    final value = await showModalBottomSheet<String>(context: context,
      builder: (sheet) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(padding: const EdgeInsets.all(20), child: Text(label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
        for (final item in choices) ListTile(title: Text(item),
          trailing: item == current ? const Icon(Icons.check, color: AppColors.orange) : null,
          onTap: () => Navigator.pop(sheet, item)),
      ])));
    if (value == null || !mounted) return;
    try {
      await AppServices.reports.saveSetting(key, value);
      setState(() => apply(value));
    } catch (_) {
      _message(AppStrings.saveFailed);
    }
  }

  Future<void> _perform(Future<void> Function() action, String error) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (_) {
      _message(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _share(File file, String subject) async {
    if (!mounted) return;
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], subject: subject));
  }

  Future<void> _restore() => _perform(() async {
    final selection = await FilePicker.pickFile(type: FileType.custom,
      allowedExtensions: ['sbackup']);
    if (selection?.path == null) return;
    final count = await ReportTransfer.importBackup(File(selection!.path!));
    _message(AppStrings.restoreCount(count));
    await _load();
  }, AppStrings.restoreFailed);

  Future<void> _backup() => _perform(() async {
    await _share(await ReportTransfer.exportBackup(), AppStrings.backupTitle);
  }, AppStrings.backupFailed);

  Future<void> _exportAll() => _perform(() async {
    await _share(await ReportTransfer.exportAllReports(), AppStrings.exportAllReports);
  }, AppStrings.exportFailed);

  void _unavailable(String feature) => _message('$feature ${AppStrings.unavailableSetting}');

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Column(children: [
      ActiveSiteBar(site: _site.isEmpty ? null : _site),
      Container(color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 16, 20, 16),
        child: Row(children: [
          _BackButton(onPressed: () => Navigator.pop(context)),
          const SizedBox(width: 12),
          const Text(AppStrings.settings, style: TextStyle(fontSize: 20,
            fontWeight: FontWeight.w800, color: AppColors.ink)),
        ])),
      Expanded(child: ListView(children: [
        const _SectionHeader(AppStrings.userProfile),
        _SettingsRow(AppStrings.name, _name, onTap: () => _profile(AppStrings.name, _name, 'name')),
        _SettingsRow(AppStrings.department, _department,
          onTap: () => _profile(AppStrings.department, _department, 'department')),
        _SettingsRow(AppStrings.employeeNumber, _number,
          onTap: () => _profile(AppStrings.employeeNumber, _number, 'number'), last: true),
        const _SectionHeader(AppStrings.appSettings),
        _SettingsRow(AppStrings.activeSite, _site, onTap: () => _edit(
          AppStrings.activeSite, _site, (value) async {
            await AppServices.reports.saveSetting('activeSite', value);
            setState(() => _site = value);
          })),
        _SettingsRow(AppStrings.language, 'English', onTap: () => _unavailable(AppStrings.language)),
        _SettingsRow(AppStrings.dateFormat, _dateFormat,
          onTap: () => _choice(AppStrings.dateFormat, _dateFormat,
            ['DD MMM YYYY', 'YYYY-MM-DD', 'MM/DD/YYYY'], 'dateFormat',
            (value) => _dateFormat = value)),
        _SettingsRow(AppStrings.timeFormat, _timeFormat,
          onTap: () => _choice(AppStrings.timeFormat, _timeFormat,
            ['12-hour', '24-hour'], 'timeFormat', (value) => _timeFormat = value)),
        _SettingsRow(AppStrings.theme, 'System Default',
          onTap: () => _unavailable(AppStrings.theme), last: true),
        const _SectionHeader(AppStrings.security),
        _SettingsRow(AppStrings.pinLock, '', onTap: () => _unavailable(AppStrings.pinLock),
          trailing: const _DisabledSwitch()),
        _SettingsRow(AppStrings.biometricLock, '',
          onTap: () => _unavailable(AppStrings.biometricLock),
          trailing: const _DisabledSwitch(), last: true),
        const _SectionHeader(AppStrings.data),
        _SettingsRow(AppStrings.backupData, '', onTap: _busy ? null : _backup),
        _SettingsRow(AppStrings.importData, '', onTap: _busy ? null : _restore),
        _SettingsRow(AppStrings.exportAllReports, '', onTap: _busy ? null : _exportAll),
        _SettingsRow(AppStrings.storage, _storageBytes == null ? '—'
          : '${(_storageBytes! / 1024 / 1024).toStringAsFixed(1)} MB used', last: true),
        const _SectionHeader(AppStrings.about),
        const _SettingsRow(AppStrings.appVersion, '1.0.0'),
        _SettingsRow(AppStrings.organization, _organization,
          onTap: () => _edit(AppStrings.organization, _organization, (value) async {
            await AppServices.reports.saveSetting('organization', value);
            _organization = value;
          })),
        _SettingsRow(AppStrings.supportHelp, '', onTap: () => showDialog<void>(
          context: context, builder: (dialog) => AlertDialog(
            title: const Text(AppStrings.supportHelp),
            content: const Text(AppStrings.helpText),
            actions: [TextButton(onPressed: () => Navigator.pop(dialog),
              child: const Text(AppStrings.close))])), last: true),
        const Padding(padding: EdgeInsets.symmetric(vertical: 24),
          child: Column(children: [
            Text(AppStrings.buildInfo, style: TextStyle(fontSize: 11,
              fontWeight: FontWeight.w700, color: AppColors.mutedInk)),
            SizedBox(height: 6),
            Text(AppStrings.hardwareInfo, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: AppColors.mutedInk)),
          ])),
      ])),
    ])),
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    decoration: const BoxDecoration(color: Color(0xFFE2E8F0), border:
      Border.symmetric(horizontal: BorderSide(color: AppColors.border))),
    child: Text(title.toUpperCase(), style: const TextStyle(color: AppColors.secondaryInk,
      fontSize: 11, fontWeight: FontWeight.w800)),
  );
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow(this.title, this.value, {this.onTap, this.trailing, this.last = false});
  final String title, value;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool last;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    child: InkWell(onTap: onTap, child: Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
      decoration: BoxDecoration(border: last ? null : const Border(
        bottom: BorderSide(color: AppColors.border))),
      child: Row(children: [
        Flexible(child: Text(title, style: const TextStyle(fontSize: 15,
          fontWeight: FontWeight.w600, color: AppColors.ink))),
        const Spacer(),
        if (trailing != null) trailing! else ...[
          Flexible(child: Text(value.isEmpty ? '—' : value,
            textAlign: TextAlign.right, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, color: AppColors.secondaryInk))),
          if (onTap != null) const Padding(padding: EdgeInsets.only(left: 8),
            child: Icon(Icons.chevron_right, size: 20, color: AppColors.mutedInk)),
        ],
      ]),
    )),
  );
}

class _DisabledSwitch extends StatelessWidget {
  const _DisabledSwitch();
  @override
  Widget build(BuildContext context) => const IgnorePointer(
    child: Switch(value: false, onChanged: null));
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => InkWell(onTap: onPressed,
    borderRadius: BorderRadius.circular(8),
    child: const ObservationIcon('report_details', 'arrow_left', 36));
}
