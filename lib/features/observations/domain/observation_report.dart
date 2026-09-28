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

  factory ObservationReport.fromJson(Map<String, dynamic> json) => ObservationReport(
        id: json['id'] as String,
        type: ObservationType.values.byName(json['type'] as String),
        status: ReportStatus.values.byName(json['status'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        stopCardCategory: json['stopCardCategory'] == null ? null :
            StopCardCategory.values.byName(json['stopCardCategory'] as String),
        area: (json['area'] as String?) ?? '',
        employeeName: (json['employeeName'] as String?) ?? '',
        employeeDepartment: (json['employeeDepartment'] as String?) ?? '',
        employeeNumber: (json['employeeNumber'] as String?) ?? '',
        observedEvent: (json['observedEvent'] as String?) ?? '',
        potentialHazard: (json['potentialHazard'] as String?) ?? '',
        actionTaken: (json['actionTaken'] as String?) ?? '',
        furtherActions: (json['furtherActions'] as String?) ?? '',
        safetyCategories: List<String>.from((json['safetyCategories'] as List<dynamic>?) ?? []),
        encouragement: (json['encouragement'] as String?) ?? '',
        immediateCorrectiveAction: (json['immediateCorrectiveAction'] as String?) ?? '',
        risk: json['risk'] == null ? null : RiskRanking.values.byName(json['risk'] as String),
        supervisorNotified: (json['supervisorNotified'] as bool?) ?? false,
        supervisorName: (json['supervisorName'] as String?) ?? '',
        supervisorFurtherAction: (json['supervisorFurtherAction'] as String?) ?? '',
        signaturePath: json['signaturePath'] as String?,
        attachmentPaths: List<String>.from((json['attachmentPaths'] as List<dynamic>?) ?? []),
      );

  ObservationReport withDetails({
    String? area,
    String? employeeName,
    String? employeeNumber,
    String? employeeDepartment,
    String? observedEvent,
    String? potentialHazard,
    String? actionTaken,
    String? furtherActions,
    List<String>? safetyCategories,
    String? encouragement,
    String? immediateCorrectiveAction,
    RiskRanking? risk,
    bool? supervisorNotified,
    String? supervisorName,
    String? supervisorFurtherAction,
    ReportStatus? status,
    String? signaturePath,
    List<String>? attachmentPaths,
  }) =>
      ObservationReport(
        id: id,
        type: type,
        status: status ?? this.status,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
        stopCardCategory: stopCardCategory,
        area: area ?? this.area,
        employeeName: employeeName ?? this.employeeName,
        employeeNumber: employeeNumber ?? this.employeeNumber,
        employeeDepartment: employeeDepartment ?? this.employeeDepartment,
        observedEvent: observedEvent ?? this.observedEvent,
        potentialHazard: potentialHazard ?? this.potentialHazard,
        actionTaken: actionTaken ?? this.actionTaken,
        furtherActions: furtherActions ?? this.furtherActions,
        safetyCategories: safetyCategories ?? this.safetyCategories,
        encouragement: encouragement ?? this.encouragement,
        immediateCorrectiveAction: immediateCorrectiveAction ?? this.immediateCorrectiveAction,
        risk: risk ?? this.risk,
        supervisorNotified: supervisorNotified ?? this.supervisorNotified,
        supervisorName: supervisorName ?? this.supervisorName,
        supervisorFurtherAction: supervisorFurtherAction ?? this.supervisorFurtherAction,
        signaturePath: signaturePath ?? this.signaturePath,
        attachmentPaths: attachmentPaths ?? this.attachmentPaths,
      );

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
