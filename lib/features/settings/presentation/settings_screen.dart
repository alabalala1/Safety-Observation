import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/app_services.dart';
import '../../../core/l10n/app_strings.dart';
import '../../reports/data/report_transfer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _name = TextEditingController();
  final _number = TextEditingController();
  final _department = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final profile = await AppServices.reports.loadProfile();
      if (!mounted) return;
      _name.text = profile['name'] ?? '';
      _number.text = profile['employeeNumber'] ?? '';
      _department.text = profile['department'] ?? '';
    } catch (_) {
      _message(AppStrings.loadFailed);
    }
  }

  void _message(String message) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      await AppServices.reports.saveProfile(name: _name.text.trim(),
        employeeNumber: _number.text.trim(), department: _department.text.trim());
      _message(AppStrings.profileSaved);
    } catch (_) {
      _message(AppStrings.saveFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final file = await ReportTransfer.exportBackup();
      if (!mounted) return;
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)],
        subject: AppStrings.backupTitle));
    } catch (_) {
      _message(AppStrings.backupFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _busy = true);
    try {
      final selection = await FilePicker.platform.pickFiles(type: FileType.custom,
        allowedExtensions: ['sbackup']);
      final path = selection?.files.single.path;
      if (path == null) return;
      final count = await ReportTransfer.importBackup(File(path));
      _message(AppStrings.restoreCount(count));
    } catch (_) {
      _message(AppStrings.restoreFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _number.dispose();
    _department.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text(AppStrings.settings)),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      const Text(AppStrings.myProfile, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      TextField(controller: _name, decoration: const InputDecoration(labelText: AppStrings.employeeName)),
      const SizedBox(height: 12),
      TextField(controller: _number, decoration: const InputDecoration(labelText: AppStrings.employeeNumber)),
      const SizedBox(height: 12),
      TextField(controller: _department, decoration: const InputDecoration(labelText: AppStrings.department)),
      const SizedBox(height: 16),
      FilledButton(onPressed: _busy ? null : _save, child: const Text(AppStrings.saveProfile)),
      const SizedBox(height: 32),
      const Text(AppStrings.backupTitle, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text(AppStrings.backupExplanation),
      const SizedBox(height: 12),
      OutlinedButton.icon(onPressed: _busy ? null : _export,
        icon: const Icon(Icons.ios_share), label: const Text(AppStrings.exportBackup)),
      OutlinedButton.icon(onPressed: _busy ? null : _restore,
        icon: const Icon(Icons.restore), label: const Text(AppStrings.restoreBackup)),
    ]),
  );
}
