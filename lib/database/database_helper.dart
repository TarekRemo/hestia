import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/discipline_badge.dart';
import '../models/app_user.dart';
import '../models/action_importance.dart';
import '../models/discipline_action.dart';
import '../models/action_time_slot.dart';
import '../models/action_history.dart';
import '../models/action_notification.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('discipline.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE DISCIPLINE_BADGE (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        label TEXT NOT NULL,
        min_streak INTEGER NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        update_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE APP_USER (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        discipline_badge_id INTEGER,
        total_score INTEGER DEFAULT 0,
        mail TEXT UNIQUE NOT NULL,
        firstname TEXT NOT NULL,
        lastname TEXT NOT NULL,
        gender TEXT NOT NULL CHECK (gender IN ('male', 'female')),
        birth_date TEXT NOT NULL,
        current_discipline_streak INTEGER NOT NULL DEFAULT 0,
        max_discipline_streak INTEGER NOT NULL DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        update_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (discipline_badge_id) REFERENCES DISCIPLINE_BADGE(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE ACTION_IMPORTANCE (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        label TEXT NOT NULL,
        points INTEGER NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        update_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE ACTION (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        action_importance_id INTEGER,
        name TEXT NOT NULL,
        description TEXT,
        frequency INTEGER,
        is_positive INTEGER DEFAULT 1,
        current_streak INTEGER NOT NULL DEFAULT 0,
        record_streak INTEGER NOT NULL DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        update_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES APP_USER(id),
        FOREIGN KEY (action_importance_id) REFERENCES ACTION_IMPORTANCE(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE ACTION_TIME_SLOT (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        action_id INTEGER,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        update_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (action_id) REFERENCES ACTION(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE ACTION_HISTORY (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        action_id INTEGER,
        date TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        action_status INTEGER DEFAULT -1 CHECK (action_status IN (-1, 0, 1)),
        user_comment TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        update_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (action_id) REFERENCES ACTION(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE ACTION_NOTIFICATION (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        action_id INTEGER,
        title TEXT NOT NULL,
        message TEXT,
        notification_type INTEGER NOT NULL CHECK (notification_type IN (1,2,3,4)),
        FOREIGN KEY (action_id) REFERENCES ACTION(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_action_user ON ACTION(user_id)');
    await db.execute('CREATE INDEX idx_action_history_action ON ACTION_HISTORY(action_id)');
    await db.execute('CREATE INDEX idx_time_slot_action ON ACTION_TIME_SLOT(action_id)');

    // Seed default data
    await _seedData(db);
  }

  Future<void> _seedData(Database db) async {
    // Default badges
    await db.insert('DISCIPLINE_BADGE', {'label': 'Débutant', 'min_streak': 0});
    await db.insert('DISCIPLINE_BADGE', {'label': 'Régulier', 'min_streak': 7});
    await db.insert('DISCIPLINE_BADGE', {'label': 'Discipliné', 'min_streak': 30});
    await db.insert('DISCIPLINE_BADGE', {'label': 'Exemplaire', 'min_streak': 90});

    // Default importance levels
    await db.insert('ACTION_IMPORTANCE', {'label': 'Faible', 'points': 5});
    await db.insert('ACTION_IMPORTANCE', {'label': 'Moyen', 'points': 10});
    await db.insert('ACTION_IMPORTANCE', {'label': 'Élevé', 'points': 20});
  }

  // ─── BADGE METHODS ───
  Future<List<DisciplineBadge>> getAllBadges() async {
    final db = await database;
    final result = await db.query('DISCIPLINE_BADGE', orderBy: 'min_streak ASC');
    return result.map((m) => DisciplineBadge.fromMap(m)).toList();
  }

  Future<DisciplineBadge?> getBadgeForStreak(int streak) async {
    final db = await database;
    final result = await db.query(
      'DISCIPLINE_BADGE',
      where: 'min_streak <= ?',
      whereArgs: [streak],
      orderBy: 'min_streak DESC',
      limit: 1,
    );
    if (result.isEmpty) return null;
    return DisciplineBadge.fromMap(result.first);
  }

  // ─── USER METHODS ───
  Future<AppUser?> getUser() async {
    final db = await database;
    final result = await db.query('APP_USER', limit: 1);
    if (result.isEmpty) return null;
    return AppUser.fromMap(result.first);
  }

  Future<int> insertUser(AppUser user) async {
    final db = await database;
    return await db.insert('APP_USER', user.toMap()..remove('id'));
  }

  Future<int> updateUser(AppUser user) async {
    final db = await database;
    return await db.update(
      'APP_USER',
      user.toMap()..['update_at'] = DateTime.now().toIso8601String(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> updateUserScore(int userId, int newScore) async {
    final db = await database;
    await db.update(
      'APP_USER',
      {'total_score': newScore, 'update_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> updateUserStreak(int userId, int currentStreak, int maxStreak) async {
    final db = await database;
    await db.update(
      'APP_USER',
      {
        'current_discipline_streak': currentStreak,
        'max_discipline_streak': maxStreak,
        'update_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // ─── IMPORTANCE METHODS ───
  Future<List<ActionImportance>> getAllImportanceLevels() async {
    final db = await database;
    final result = await db.query('ACTION_IMPORTANCE', orderBy: 'points ASC');
    return result.map((m) => ActionImportance.fromMap(m)).toList();
  }

  // ─── ACTION METHODS ───
  Future<List<DisciplineAction>> getActionsForUser(int userId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT a.*, ai.label as importance_label, ai.points as importance_points
      FROM ACTION a
      LEFT JOIN ACTION_IMPORTANCE ai ON a.action_importance_id = ai.id
      WHERE a.user_id = ?
      ORDER BY a.created_at DESC
    ''', [userId]);
    return result.map((m) => DisciplineAction.fromMap(m)).toList();
  }

  Future<DisciplineAction?> getAction(int actionId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT a.*, ai.label as importance_label, ai.points as importance_points
      FROM ACTION a
      LEFT JOIN ACTION_IMPORTANCE ai ON a.action_importance_id = ai.id
      WHERE a.id = ?
    ''', [actionId]);
    if (result.isEmpty) return null;
    return DisciplineAction.fromMap(result.first);
  }

  Future<int> insertAction(DisciplineAction action) async {
    final db = await database;
    return await db.insert('ACTION', action.toMap()..remove('id'));
  }

  Future<int> updateAction(DisciplineAction action) async {
    final db = await database;
    return await db.update(
      'ACTION',
      action.toMap()..['update_at'] = DateTime.now().toIso8601String(),
      where: 'id = ?',
      whereArgs: [action.id],
    );
  }

  Future<int> deleteAction(int actionId) async {
    final db = await database;
    return await db.delete('ACTION', where: 'id = ?', whereArgs: [actionId]);
  }

  Future<void> updateActionStreak(int actionId, int currentStreak, int recordStreak) async {
    final db = await database;
    await db.update(
      'ACTION',
      {
        'current_streak': currentStreak,
        'record_streak': recordStreak,
        'update_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [actionId],
    );
  }

  // ─── TIME SLOT METHODS ───
  Future<List<ActionTimeSlot>> getTimeSlotsForAction(int actionId) async {
    final db = await database;
    final result = await db.query(
      'ACTION_TIME_SLOT',
      where: 'action_id = ?',
      whereArgs: [actionId],
      orderBy: 'start_time ASC',
    );
    return result.map((m) => ActionTimeSlot.fromMap(m)).toList();
  }

  Future<int> insertTimeSlot(ActionTimeSlot slot) async {
    final db = await database;
    return await db.insert('ACTION_TIME_SLOT', slot.toMap()..remove('id'));
  }

  Future<void> deleteTimeSlotsForAction(int actionId) async {
    final db = await database;
    await db.delete('ACTION_TIME_SLOT', where: 'action_id = ?', whereArgs: [actionId]);
  }

  // ─── HISTORY METHODS ───
  Future<List<ActionHistory>> getHistoryForAction(int actionId, {int? limit}) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT ah.*, a.name as action_name, a.is_positive, ai.points as importance_points
      FROM ACTION_HISTORY ah
      JOIN ACTION a ON ah.action_id = a.id
      LEFT JOIN ACTION_IMPORTANCE ai ON a.action_importance_id = ai.id
      WHERE ah.action_id = ?
      ORDER BY ah.date DESC
      ${limit != null ? 'LIMIT $limit' : ''}
    ''', [actionId]);
    return result.map((m) => ActionHistory.fromMap(m)).toList();
  }

  Future<List<ActionHistory>> getHistoryForUser(int userId, {String? startDate, String? endDate, int? limit}) async {
    final db = await database;
    String whereClause = 'a.user_id = ?';
    List<dynamic> args = [userId];

    if (startDate != null) {
      whereClause += ' AND ah.date >= ?';
      args.add(startDate);
    }
    if (endDate != null) {
      whereClause += ' AND ah.date <= ?';
      args.add(endDate);
    }

    final result = await db.rawQuery('''
      SELECT ah.*, a.name as action_name, a.is_positive, ai.points as importance_points
      FROM ACTION_HISTORY ah
      JOIN ACTION a ON ah.action_id = a.id
      LEFT JOIN ACTION_IMPORTANCE ai ON a.action_importance_id = ai.id
      WHERE $whereClause
      ORDER BY ah.date DESC
      ${limit != null ? 'LIMIT $limit' : ''}
    ''', args);
    return result.map((m) => ActionHistory.fromMap(m)).toList();
  }

  Future<int> insertHistory(ActionHistory history) async {
    final db = await database;
    return await db.insert('ACTION_HISTORY', history.toMap()..remove('id'));
  }

  Future<int> updateHistory(ActionHistory history) async {
    final db = await database;
    return await db.update(
      'ACTION_HISTORY',
      history.toMap()..['update_at'] = DateTime.now().toIso8601String(),
      where: 'id = ?',
      whereArgs: [history.id],
    );
  }

  Future<List<ActionHistory>> getTodayHistory(int userId) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return getHistoryForUser(userId, startDate: '$today 00:00:00', endDate: '$today 23:59:59');
  }

  Future<int> calculateTotalScore(int userId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        SUM(
          CASE 
            WHEN ah.action_status = 1 AND a.is_positive = 1 THEN ai.points
            WHEN ah.action_status = 0 AND a.is_positive = 1 THEN -ai.points
            WHEN ah.action_status = 1 AND a.is_positive = 0 THEN -ai.points
            WHEN ah.action_status = 0 AND a.is_positive = 0 THEN ai.points
            ELSE 0
          END
        ) as total
      FROM ACTION_HISTORY ah
      JOIN ACTION a ON ah.action_id = a.id
      LEFT JOIN ACTION_IMPORTANCE ai ON a.action_importance_id = ai.id
      WHERE a.user_id = ?
    ''', [userId]);
    final total = result.first['total'] as int?;
    return total ?? 0;
  }

  Future<Map<String, double>> getScoreEvolution(int userId, int days) async {
    final db = await database;
    final startDate = DateTime.now().subtract(Duration(days: days));
    final result = await db.rawQuery('''
      SELECT 
        substr(ah.date, 1, 10) as day,
        SUM(
          CASE 
            WHEN ah.action_status = 1 AND a.is_positive = 1 THEN ai.points
            WHEN ah.action_status = 0 AND a.is_positive = 1 THEN -ai.points
            WHEN ah.action_status = 1 AND a.is_positive = 0 THEN -ai.points
            WHEN ah.action_status = 0 AND a.is_positive = 0 THEN ai.points
            ELSE 0
          END
        ) as daily_score
      FROM ACTION_HISTORY ah
      JOIN ACTION a ON ah.action_id = a.id
      LEFT JOIN ACTION_IMPORTANCE ai ON a.action_importance_id = ai.id
      WHERE a.user_id = ? AND ah.date >= ?
      GROUP BY substr(ah.date, 1, 10)
      ORDER BY day ASC
    ''', [userId, startDate.toIso8601String()]);

    Map<String, double> evolution = {};
    for (var row in result) {
      evolution[row['day'] as String] = (row['daily_score'] as num?)?.toDouble() ?? 0;
    }
    return evolution;
  }

  Future<double> getActionSuccessRate(int actionId) async {
    final db = await database;
    final total = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM ACTION_HISTORY WHERE action_id = ? AND action_status != -1',
      [actionId],
    );
    final done = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM ACTION_HISTORY WHERE action_id = ? AND action_status = 1',
      [actionId],
    );
    final totalCount = (total.first['cnt'] as int?) ?? 0;
    final doneCount = (done.first['cnt'] as int?) ?? 0;
    if (totalCount == 0) return 0;
    return doneCount / totalCount;
  }

  // ─── NOTIFICATION METHODS ───
  Future<List<ActionNotification>> getNotificationsForAction(int actionId) async {
    final db = await database;
    final result = await db.query(
      'ACTION_NOTIFICATION',
      where: 'action_id = ?',
      whereArgs: [actionId],
    );
    return result.map((m) => ActionNotification.fromMap(m)).toList();
  }

  Future<int> insertNotification(ActionNotification notification) async {
    final db = await database;
    return await db.insert('ACTION_NOTIFICATION', notification.toMap()..remove('id'));
  }

  Future<int> deleteNotification(int notificationId) async {
    final db = await database;
    return await db.delete('ACTION_NOTIFICATION', where: 'id = ?', whereArgs: [notificationId]);
  }

  Future<void> deleteNotificationsForAction(int actionId) async {
    final db = await database;
    await db.delete('ACTION_NOTIFICATION', where: 'action_id = ?', whereArgs: [actionId]);
  }

  Future<List<ActionNotification>> getMotivationMessages(int actionId, int type) async {
    final db = await database;
    final result = await db.query(
      'ACTION_NOTIFICATION',
      where: 'action_id = ? AND notification_type = ?',
      whereArgs: [actionId, type],
    );
    return result.map((m) => ActionNotification.fromMap(m)).toList();
  }

  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
