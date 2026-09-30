import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/weekly_schedule_template.dart';
import '../models/daily_task_instance.dart';
import '../models/schedule/schedule_models.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('longevity.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 5, // Version 5: Add app_settings table for location/preferences
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Legacy tables (keeping for backward compatibility)
    await db.execute('''
      CREATE TABLE weekly_schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        day_of_week INTEGER NOT NULL,
        planned_time TEXT NOT NULL,
        instructions TEXT NOT NULL,
        is_optional INTEGER NOT NULL DEFAULT 0,
        active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        template_id INTEGER,
        schedule_event_id INTEGER,
        task_date TEXT NOT NULL,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        planned_time TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        completed_at TEXT,
        skipped_at TEXT,
        notes TEXT,
        event_type TEXT,
        metadata TEXT,
        FOREIGN KEY (template_id) REFERENCES weekly_schedules (id),
        FOREIGN KEY (schedule_event_id) REFERENCES schedule_events (id)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_daily_tasks_date ON daily_tasks (task_date)
    ''');

    // New tables for configurable system
    await db.execute('''
      CREATE TABLE supplements (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        dose TEXT NOT NULL,
        timing_rule TEXT NOT NULL,
        food_required INTEGER NOT NULL DEFAULT 0,
        notes TEXT,
        active INTEGER NOT NULL DEFAULT 1,
        importance INTEGER NOT NULL DEFAULT 5
      )
    ''');

    await db.execute('''
      CREATE TABLE exercise_modules (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        module_type TEXT NOT NULL,
        details TEXT NOT NULL,
        active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE schedule_events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        day_of_week TEXT NOT NULL,
        time TEXT NOT NULL,
        event_type TEXT NOT NULL,
        details TEXT,
        module_id TEXT,
        supplement_ids TEXT,
        is_task INTEGER NOT NULL DEFAULT 1,
        metadata TEXT,
        FOREIGN KEY (module_id) REFERENCES exercise_modules (id)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_schedule_events_day ON schedule_events (day_of_week)
    ''');

    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns to daily_tasks
      await db.execute('ALTER TABLE daily_tasks ADD COLUMN schedule_event_id INTEGER');
      await db.execute('ALTER TABLE daily_tasks ADD COLUMN event_type TEXT');
      await db.execute('ALTER TABLE daily_tasks ADD COLUMN metadata TEXT');

      // Create new tables
      await db.execute('''
        CREATE TABLE supplements (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          dose TEXT NOT NULL,
          timing_rule TEXT NOT NULL,
          food_required INTEGER NOT NULL DEFAULT 0,
          notes TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE exercise_modules (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          module_type TEXT NOT NULL,
          details TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE schedule_events (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          day_of_week TEXT NOT NULL,
          time TEXT NOT NULL,
          event_type TEXT NOT NULL,
          details TEXT,
          module_id TEXT,
          supplement_ids TEXT,
          is_task INTEGER NOT NULL DEFAULT 1,
          metadata TEXT,
          FOREIGN KEY (module_id) REFERENCES exercise_modules (id)
        )
      ''');

      await db.execute('''
        CREATE INDEX idx_schedule_events_day ON schedule_events (day_of_week)
      ''');
    }

    if (oldVersion < 3) {
      // Add active column to supplements and exercise_modules
      await db.execute('ALTER TABLE supplements ADD COLUMN active INTEGER NOT NULL DEFAULT 1');
      await db.execute('ALTER TABLE exercise_modules ADD COLUMN active INTEGER NOT NULL DEFAULT 1');
    }

    if (oldVersion < 4) {
      // Add importance column to supplements
      await db.execute('ALTER TABLE supplements ADD COLUMN importance INTEGER NOT NULL DEFAULT 5');
    }

    if (oldVersion < 5) {
      // Add app_settings table for location and preferences
      await db.execute('''
        CREATE TABLE app_settings (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');
    }
  }

  // ========================================
  // Supplement CRUD
  // ========================================

  Future<void> insertSupplement(Supplement supplement) async {
    final db = await database;
    await db.insert(
      'supplements',
      supplement.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Supplement>> getAllSupplements() async {
    final db = await database;
    // Sort by importance (highest first), then by name alphabetically
    final maps = await db.query('supplements', orderBy: 'importance DESC, name ASC');
    return maps.map((map) => Supplement.fromMap(map)).toList();
  }

  Future<Supplement?> getSupplement(String id) async {
    final db = await database;
    final maps = await db.query(
      'supplements',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Supplement.fromMap(maps.first);
  }

  Future<void> updateSupplement(Supplement supplement) async {
    final db = await database;
    await db.update(
      'supplements',
      supplement.toMap(),
      where: 'id = ?',
      whereArgs: [supplement.id],
    );
  }

  Future<void> deleteSupplement(String id) async {
    final db = await database;
    await db.delete(
      'supplements',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========================================
  // Exercise Module CRUD
  // ========================================

  Future<void> insertExerciseModule(ExerciseModule module) async {
    final db = await database;
    await db.insert(
      'exercise_modules',
      module.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ExerciseModule>> getAllExerciseModules() async {
    final db = await database;
    final maps = await db.query('exercise_modules', orderBy: 'name ASC');
    return maps.map((map) => ExerciseModule.fromMap(map)).toList();
  }

  Future<ExerciseModule?> getExerciseModule(String id) async {
    final db = await database;
    final maps = await db.query(
      'exercise_modules',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return ExerciseModule.fromMap(maps.first);
  }

  Future<void> updateExerciseModule(ExerciseModule module) async {
    final db = await database;
    await db.update(
      'exercise_modules',
      module.toMap(),
      where: 'id = ?',
      whereArgs: [module.id],
    );
  }

  Future<void> deleteExerciseModule(String id) async {
    final db = await database;
    await db.delete(
      'exercise_modules',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========================================
  // Schedule Event CRUD
  // ========================================

  Future<int> insertScheduleEvent(ScheduleEvent event) async {
    final db = await database;
    return await db.insert('schedule_events', event.toMap());
  }

  Future<List<ScheduleEvent>> getScheduleEvents({String? dayOfWeek}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps;

    if (dayOfWeek != null) {
      maps = await db.query(
        'schedule_events',
        where: 'day_of_week = ?',
        whereArgs: [dayOfWeek],
        orderBy: 'time ASC',
      );
    } else {
      maps = await db.query('schedule_events', orderBy: 'day_of_week, time ASC');
    }

    return maps.map((map) => ScheduleEvent.fromMap(map)).toList();
  }

  Future<List<ScheduleEvent>> getScheduleTaskEvents(String dayOfWeek) async {
    final db = await database;
    final maps = await db.query(
      'schedule_events',
      where: 'day_of_week = ? AND is_task = 1',
      whereArgs: [dayOfWeek],
      orderBy: 'time ASC',
    );
    return maps.map((map) => ScheduleEvent.fromMap(map)).toList();
  }

  Future<void> updateScheduleEvent(ScheduleEvent event) async {
    final db = await database;
    await db.update(
      'schedule_events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  Future<void> deleteScheduleEvent(int id) async {
    final db = await database;
    await db.delete(
      'schedule_events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearScheduleEvents() async {
    final db = await database;
    await db.delete('schedule_events');
  }

  // ========================================
  // Legacy Weekly Schedule CRUD (keeping for compatibility)
  // ========================================

  Future<int> insertWeeklySchedule(WeeklyScheduleTemplate template) async {
    final db = await database;
    return await db.insert('weekly_schedules', template.toMap());
  }

  Future<List<WeeklyScheduleTemplate>> getWeeklySchedules({int? dayOfWeek}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps;

    if (dayOfWeek != null) {
      maps = await db.query(
        'weekly_schedules',
        where: 'day_of_week = ? AND active = 1',
        whereArgs: [dayOfWeek],
        orderBy: 'planned_time ASC',
      );
    } else {
      maps = await db.query(
        'weekly_schedules',
        where: 'active = 1',
        orderBy: 'day_of_week ASC, planned_time ASC',
      );
    }

    return maps.map((map) => WeeklyScheduleTemplate.fromMap(map)).toList();
  }

  // ========================================
  // Daily Task CRUD
  // ========================================

  Future<int> insertDailyTask(DailyTaskInstance task) async {
    final db = await database;
    return await db.insert('daily_tasks', task.toMap());
  }

  Future<List<DailyTaskInstance>> getDailyTasks(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];

    final maps = await db.query(
      'daily_tasks',
      where: 'task_date = ?',
      whereArgs: [dateStr],
      orderBy: 'planned_time ASC',
    );

    return maps.map((map) => DailyTaskInstance.fromMap(map)).toList();
  }

  Future<List<DailyTaskInstance>> getTaskHistory({int limit = 30}) async {
    final db = await database;
    final today = DateTime.now().toIso8601String().split('T')[0];

    final maps = await db.query(
      'daily_tasks',
      where: 'task_date < ?',
      whereArgs: [today],
      orderBy: 'task_date DESC, planned_time ASC',
      limit: limit,
    );

    return maps.map((map) => DailyTaskInstance.fromMap(map)).toList();
  }

  Future<int> updateDailyTask(DailyTaskInstance task) async {
    final db = await database;
    return await db.update(
      'daily_tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTasksForDate(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    await db.delete(
      'daily_tasks',
      where: 'task_date = ?',
      whereArgs: [dateStr],
    );
  }

  /// Get completion stats for a date range (for calendar view)
  /// Returns a map of date string -> {totalActive, completed}
  Future<Map<String, Map<String, int>>> getCompletionStatsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final startStr = startDate.toIso8601String().split('T')[0];
    final endStr = endDate.toIso8601String().split('T')[0];

    final maps = await db.query(
      'daily_tasks',
      where: 'task_date >= ? AND task_date <= ?',
      whereArgs: [startStr, endStr],
    );

    final tasks = maps.map((map) => DailyTaskInstance.fromMap(map)).toList();

    // Group by date and calculate stats
    final Map<String, Map<String, int>> stats = {};

    for (final task in tasks) {
      final dateStr = task.taskDate.toIso8601String().split('T')[0];
      final isActive = task.metadata?['is_active'] ?? true;

      if (!stats.containsKey(dateStr)) {
        stats[dateStr] = {'totalActive': 0, 'completed': 0};
      }

      if (isActive) {
        stats[dateStr]!['totalActive'] = stats[dateStr]!['totalActive']! + 1;
        if (task.status == 'done') {
          stats[dateStr]!['completed'] = stats[dateStr]!['completed']! + 1;
        }
      }
    }

    return stats;
  }

  /// Calculate current streak (consecutive days with 100% active task completion)
  Future<int> getCurrentStreak() async {
    final db = await database;
    final today = DateTime.now();

    int streak = 0;
    DateTime checkDate = DateTime(today.year, today.month, today.day);

    while (true) {
      final dateStr = checkDate.toIso8601String().split('T')[0];
      final maps = await db.query(
        'daily_tasks',
        where: 'task_date = ?',
        whereArgs: [dateStr],
      );

      if (maps.isEmpty) break; // No tasks for this day

      final tasks = maps.map((map) => DailyTaskInstance.fromMap(map)).toList();
      final activeTasks = tasks.where((t) => t.metadata?['is_active'] ?? true).toList();

      if (activeTasks.isEmpty) {
        checkDate = checkDate.subtract(const Duration(days: 1));
        continue;
      }

      final completedCount = activeTasks.where((t) => t.status == 'done').length;
      final completionRate = completedCount / activeTasks.length;

      if (completionRate == 1.0) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Calculate longest streak ever
  Future<int> getBestStreak() async {
    final db = await database;

    // Get all dates with tasks, sorted
    final maps = await db.rawQuery('''
      SELECT DISTINCT task_date
      FROM daily_tasks
      ORDER BY task_date ASC
    ''');

    if (maps.isEmpty) return 0;

    int bestStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;

    for (final map in maps) {
      final dateStr = map['task_date'] as String;
      final date = DateTime.parse(dateStr);

      // Get tasks for this date
      final taskMaps = await db.query(
        'daily_tasks',
        where: 'task_date = ?',
        whereArgs: [dateStr],
      );

      final tasks = taskMaps.map((m) => DailyTaskInstance.fromMap(m)).toList();
      final activeTasks = tasks.where((t) => t.metadata?['is_active'] ?? true).toList();

      if (activeTasks.isEmpty) continue;

      final completedCount = activeTasks.where((t) => t.status == 'done').length;
      final completionRate = completedCount / activeTasks.length;

      if (completionRate == 1.0) {
        // Perfect day
        if (lastDate != null && date.difference(lastDate).inDays == 1) {
          currentStreak++;
        } else {
          currentStreak = 1;
        }
        bestStreak = currentStreak > bestStreak ? currentStreak : bestStreak;
        lastDate = date;
      } else {
        currentStreak = 0;
        lastDate = null;
      }
    }

    return bestStreak;
  }

  /// Get completion rate for current week
  Future<double> getWeekCompletionRate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: today.weekday % 7));

    final stats = await getCompletionStatsByDateRange(startOfWeek, today);

    int totalActive = 0;
    int totalCompleted = 0;

    for (final dayStat in stats.values) {
      totalActive += dayStat['totalActive'] ?? 0;
      totalCompleted += dayStat['completed'] ?? 0;
    }

    return totalActive > 0 ? totalCompleted / totalActive : 0.0;
  }

  /// Get total number of completed tasks (all time)
  Future<int> getTotalCompletedTasks() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM daily_tasks
      WHERE status = 'done'
    ''');

    return result.first['count'] as int? ?? 0;
  }

  // ============================================================
  // App Settings (for location, preferences, etc.)
  // ============================================================

  /// Get a setting value by key
  Future<String?> getSetting(String key) async {
    final db = await database;
    final result = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (result.isEmpty) return null;
    return result.first['value'] as String;
  }

  /// Set a setting value
  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'app_settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all settings as a Map
  Future<Map<String, dynamic>> getAppSettings() async {
    final db = await database;
    final results = await db.query('app_settings');

    final settings = <String, dynamic>{};
    for (var row in results) {
      final key = row['key'] as String;
      final value = row['value'] as String;

      // Try to parse as number
      final numValue = double.tryParse(value);
      if (numValue != null) {
        settings[key] = numValue;
      } else if (value == 'true' || value == 'false') {
        settings[key] = value == 'true';
      } else {
        settings[key] = value;
      }
    }

    return settings;
  }

  /// Set location for sunrise/sunset calculations
  Future<void> setLocation(
    double latitude,
    double longitude,
    double timezoneOffset,
  ) async {
    await setSetting('latitude', latitude.toString());
    await setSetting('longitude', longitude.toString());
    await setSetting('timezone_offset', timezoneOffset.toString());
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
