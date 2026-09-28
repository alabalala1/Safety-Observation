import '../domain/observation_report.dart';

/// A local implementation will persist reports and attachment references.
/// Defining the boundary now keeps the UI independent of the storage package.
abstract interface class ReportRepository {
  Future<void> save(ObservationReport report);

  Future<ObservationReport?> findById(String id);

  Future<List<ObservationReport>> search({
    String query = '',
    ReportStatus? status,
  });

  Future<void> delete(String id);

  Future<ObservationReport> update(
    String id,
    ObservationReport Function(ObservationReport report) change,
  );
}
