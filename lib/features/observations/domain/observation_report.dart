import 'dart:math';

/// The report is the unit of storage and transfer; it is independent of the
/// screen currently editing it.
enum ObservationType { nearMiss, tofs, hazardId, stopCard }

enum StopCardCategory { positive, unsafeCorrective }

enum RiskRanking { high, medium, low }

enum ReportStatus {
  draft,
  ready,
  sentForCompletion,
  received,
  inProgress,
  completed,
  exported,
}

class ObservationReport {
  factory ObservationReport.newDraft({
    required ObservationType type,
    StopCardCategory? stopCardCategory,
  }) {
    final now = DateTime.now();
    final random = Random.secure();
    final suffix = List.generate(
      3,
      (_) => random.nextInt(0x10000).toRadixString(16).padLeft(4, '0'),
    ).join().toUpperCase();
    return ObservationReport(
      id: 'OBS-${now.year}-$suffix',
      type: type,
      stopCardCategory: stopCardCategory,
      status: ReportStatus.draft,
      createdAt: now,
      updatedAt: now,
    );
  }

  const ObservationReport({
    required this.id,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.stopCardCategory,
    this.area = '',
    this.employeeName = '',
    this.employeeDepartment = '',
    this.employeeNumber = '',
    this.observedEvent = '',
    this.potentialHazard = '',
    this.actionTaken = '',
    this.furtherActions = '',
    this.safetyCategories = const [],
    this.encouragement = '',
    this.immediateCorrectiveAction = '',
    this.risk,
    this.supervisorNotified = false,
    this.supervisorName = '',
    this.supervisorFurtherAction = '',
    this.signaturePath,
    this.attachmentPaths = const [],
  });

  final String id;
  final ObservationType type;
  final StopCardCategory? stopCardCategory;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String area;
  final String employeeName;
  final String employeeDepartment;
  final String employeeNumber;
  final String observedEvent;
  final String potentialHazard;
  final String actionTaken;
  final String furtherActions;
  final List<String> safetyCategories;
  final String encouragement;
  final String immediateCorrectiveAction;
  final RiskRanking? risk;
  final bool supervisorNotified;
  final String supervisorName;
  final String supervisorFurtherAction;
  final String? signaturePath;
  final List<String> attachmentPaths;

  Map<String, Object?> toJson() => {
        'schemaVersion': 1,
        'id': id,
        'type': type.name,
        'stopCardCategory': stopCardCategory?.name,
        'status': status.name,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
        'area': area,
        'employeeName': employeeName,
        'employeeDepartment': employeeDepartment,
        'employeeNumber': employeeNumber,
        'observedEvent': observedEvent,
        'potentialHazard': potentialHazard,
        'actionTaken': actionTaken,
        'furtherActions': furtherActions,
        'safetyCategories': safetyCategories,
        'encouragement': encouragement,
        'immediateCorrectiveAction': immediateCorrectiveAction,
        'risk': risk?.name,
        'supervisorNotified': supervisorNotified,
        'supervisorName': supervisorName,
        'supervisorFurtherAction': supervisorFurtherAction,
        'signaturePath': signaturePath,
        'attachmentPaths': attachmentPaths,
      };
}
