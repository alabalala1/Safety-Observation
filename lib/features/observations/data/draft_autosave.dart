import 'dart:async';

import '../../../app/app_services.dart';
import '../domain/observation_report.dart';

/// Debounces edits and applies each patch to the latest row in a transaction.
/// This prevents a previous screen's snapshot from erasing later edits.
class DraftAutosave {
  DraftAutosave(this.reportId, this.onError);

  final String reportId;
  final void Function(Object error) onError;
  Timer? _timer;
  ObservationReport Function(ObservationReport)? _patch;
  Future<ObservationReport>? _active;

  void schedule(ObservationReport Function(ObservationReport) patch) {
    _patch = patch;
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 400), () {
      unawaited(flush().then<void>((_) {}, onError: onError));
    });
  }

  Future<ObservationReport> flush() async {
    _timer?.cancel();
    final patch = _patch;
    _patch = null;
    if (patch == null) {
      final active = _active;
      if (active != null) return active;
      final report = await AppServices.reports.findById(reportId);
      if (report == null) throw StateError('Draft not found');
      return report;
    }
    final active = _active;
    if (active != null) await active;
    final operation = AppServices.reports.update(reportId, patch);
    _active = operation;
    try {
      return await operation;
    } finally {
      if (identical(_active, operation)) _active = null;
    }
  }

  void close() {
    _timer?.cancel();
    if (_patch != null) {
      unawaited(flush().then<void>((_) {}, onError: onError));
    }
  }
}
