import '../features/observations/data/sqlite_report_repository.dart';

abstract final class AppServices {
  static final reports = SqliteReportRepository();
}
