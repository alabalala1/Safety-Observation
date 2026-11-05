import 'package:flutter/material.dart';

import '../../../app/app_services.dart';
import '../../../app/role_code.dart';
import '../../../app/user_role.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';

class RoleActivationScreen extends StatefulWidget {
  const RoleActivationScreen({super.key, required this.onActivated});
  final ValueChanged<UserRole> onActivated;

  @override
  State<RoleActivationScreen> createState() => _RoleActivationScreenState();
}

class _RoleActivationScreenState extends State<RoleActivationScreen> {
  UserRole? _role;
  final _code = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _activate() async {
    final decoded = RoleCode.decode(_code.text);
    if (_role == null || decoded == null || decoded != _role) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.invalidRoleCode)));
      return;
    }
    setState(() => _busy = true);
    try {
      await AppServices.reports.saveSetting('userRole', decoded.name);
      if (mounted) widget.onActivated(decoded);
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text(AppStrings.saveFailed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
            child: Center(
                child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.shield_outlined,
                        size: 64, color: AppColors.orange),
                    const SizedBox(height: 20),
                    const Text(AppStrings.roleActivationTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink)),
                    const SizedBox(height: 20),
                    SegmentedButton<UserRole>(
                      segments: const [
                        ButtonSegment(
                            value: UserRole.employee,
                            label: Text(AppStrings.employeeRole)),
                        ButtonSegment(
                            value: UserRole.supervisor,
                            label: Text(AppStrings.supervisorRole)),
                      ],
                      selected: _role == null ? <UserRole>{} : {_role!},
                      emptySelectionAllowed: true,
                      onSelectionChanged: (value) => setState(
                          () => _role = value.isEmpty ? null : value.first),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                        controller: _code,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                            labelText: AppStrings.activationCode,
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.key_outlined))),
                    const SizedBox(height: 20),
                    FilledButton(
                        onPressed: _busy ? null : _activate,
                        child: Text(_busy
                            ? AppStrings.pleaseWait
                            : AppStrings.activateRole)),
                  ])),
        ))),
      );
}
