import '../features/observations/data/sqlite_report_repository.dart';
import '../features/observations/data/report_media_store.dart';

abstract final class AppServices {
  static final reports = SqliteReportRepository();
  static final media = ReportMediaStore(reports);
}
