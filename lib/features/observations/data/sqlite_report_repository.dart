import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../domain/observation_report.dart';
import 'report_repository.dart';

/// The app's private SQLite database. Text is stored as a versioned report
/// payload; frequently searched fields are indexed separately.
class SqliteReportRepository implements ReportRepository {
  Future<Database>? _opening;

  Future<Database> get _db => _opening ??= _open();

  Future<Database> _open() async => openDatabase(
        p.join(await getDatabasesPath(), 'safety_observation.db'),
        version: 3,
        onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE reports (
              id TEXT PRIMARY KEY,
              type TEXT NOT NULL,
              status TEXT NOT NULL,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL,
              area TEXT NOT NULL DEFAULT '',
              employee_name TEXT NOT NULL DEFAULT '',
              employee_department TEXT NOT NULL DEFAULT '',
              risk TEXT,
              payload TEXT NOT NULL
            )
          ''');
          await db.execute('CREATE INDEX reports_status_date ON reports(status, updated_at DESC)');
          await db.execute('CREATE INDEX reports_type_risk ON reports(type, risk)');
          await db.execute('''
            CREATE TABLE report_events (
              event_id INTEGER PRIMARY KEY AUTOINCREMENT,
              report_id TEXT NOT NULL REFERENCES reports(id) ON DELETE CASCADE,
              event_type TEXT NOT NULL,
              occurred_at TEXT NOT NULL
            )
          ''');
          await _createProfileTable(db);
          await _createSettingsTable(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) await _createProfileTable(db);
          if (oldVersion < 3) await _createSettingsTable(db);
        },
      );

  Future<void> _createProfileTable(DatabaseExecutor db) async {
    await db.execute('''CREATE TABLE user_profile (
      id INTEGER PRIMARY KEY CHECK (id = 1),
      name TEXT NOT NULL DEFAULT '',
      employee_number TEXT NOT NULL DEFAULT '',
      department TEXT NOT NULL DEFAULT ''
    )''');
  }

  Future<void> _createSettingsTable(DatabaseExecutor db) async {
    await db.execute('''CREATE TABLE app_settings (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL
    )''');
  }

  Future<String?> loadSetting(String key) async {
    final rows = await (await _db).query('app_settings', columns: ['value'],
      where: 'key = ?', whereArgs: [key], limit: 1);
    return rows.isEmpty ? null : rows.first['value'] as String;
  }

  Future<void> saveSetting(String key, String value) async {
    await (await _db).insert('app_settings', {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, String>> loadProfile() async {
    final rows = await (await _db).query('user_profile', where: 'id = 1', limit: 1);
    if (rows.isEmpty) return {'name': '', 'employeeNumber': '', 'department': ''};
    final row = rows.first;
    return {
      'name': row['name'] as String,
      'employeeNumber': row['employee_number'] as String,
      'department': row['department'] as String,
    };
  }

  Future<void> saveProfile({required String name, required String employeeNumber,
      required String department}) async {
    await (await _db).insert('user_profile', {
      'id': 1, 'name': name, 'employee_number': employeeNumber,
      'department': department,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Map<String, Object?> _row(ObservationReport report) => {
        'id': report.id,
        'type': report.type.name,
        'status': report.status.name,
        'created_at': report.createdAt.toUtc().toIso8601String(),
        'updated_at': report.updatedAt.toUtc().toIso8601String(),
        'area': report.area,
        'employee_name': report.employeeName,
        'employee_department': report.employeeDepartment,
        'risk': report.risk?.name,
        'payload': jsonEncode(report.toJson()),
      };

  Future<void> _put(Transaction txn, ObservationReport report) async {
    final prior = await txn.query('reports', columns: ['status'],
      where: 'id = ?', whereArgs: [report.id], limit: 1);
    if (prior.isEmpty) {
      await txn.insert('reports', _row(report));
    } else {
      await txn.update('reports', _row(report), where: 'id = ?', whereArgs: [report.id]);
    }
    if (prior.isEmpty || prior.first['status'] != report.status.name) {
      await txn.insert('report_events', {
        'report_id': report.id,
        'event_type': prior.isEmpty ? 'created' : report.status.name,
        'occurred_at': DateTime.now().toUtc().toIso8601String(),
      });
    }
  }

  @override
  Future<void> save(ObservationReport report) async {
    final db = await _db;
    await db.transaction((txn) => _put(txn, report));
  }

  @override
  Future<ObservationReport> update(String id,
      ObservationReport Function(ObservationReport report) change) async {
    final db = await _db;
    return db.transaction((txn) async {
      final rows = await txn.query('reports', columns: ['payload'],
        where: 'id = ?', whereArgs: [id], limit: 1);
      if (rows.isEmpty) throw StateError('Report not found: $id');
      final current = _fromRow(rows.first);
      final updated = change(current);
      if (updated.id != id) throw StateError('Report ID cannot change');
      await _put(txn, updated);
      return updated;
    });
  }

  ObservationReport _fromRow(Map<String, Object?> row) =>
      ObservationReport.fromJson(jsonDecode(row['payload'] as String) as Map<String, dynamic>);

  @override
  Future<ObservationReport?> findById(String id) async {
    final rows = await (await _db).query('reports', columns: ['payload'],
      where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : _fromRow(rows.first);
  }

  @override
  Future<List<ObservationReport>> search({String query = '', ReportStatus? status}) async {
    final terms = <String>[];
    final args = <Object?>[];
    if (status != null) {
      terms.add('status = ?');
      args.add(status.name);
    }
    final text = query.trim();
    if (text.isNotEmpty) {
      terms.add('''(id LIKE ? ESCAPE '\\' OR employee_name LIKE ? ESCAPE '\\'
        OR employee_department LIKE ? ESCAPE '\\' OR area LIKE ? ESCAPE '\\'
        OR type LIKE ? ESCAPE '\\' OR risk LIKE ? ESCAPE '\\'
        OR created_at LIKE ? ESCAPE '\\' OR status LIKE ? ESCAPE '\\')''');
      final escaped = text.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');
      args.addAll(List.filled(8, '%$escaped%'));
    }
    final rows = await (await _db).query('reports', columns: ['payload'],
      where: terms.isEmpty ? null : terms.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'updated_at DESC');
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> delete(String id) async {
    await (await _db).delete('reports', where: 'id = ?', whereArgs: [id]);
  }
}
