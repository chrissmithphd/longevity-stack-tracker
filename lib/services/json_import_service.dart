import 'dart:convert';
import 'package:flutter/services.dart';
import 'database_service.dart';
import '../models/schedule/schedule_models.dart';

class JsonImportService {
  final DatabaseService _db = DatabaseService.instance;

  /// Import all data from JSON files
  Future<void> importAllData() async {
    await importSupplements();
    await importExercises();
    await importSchedule();
  }

  /// Check if data has already been imported
  Future<bool> isDataImported() async {
    final supplements = await _db.getAllSupplements();
    final exercises = await _db.getAllExerciseModules();
    final events = await _db.getScheduleEvents();

    return supplements.isNotEmpty && exercises.isNotEmpty && events.isNotEmpty;
  }

  /// Import supplements from JSON file
  Future<void> importSupplements() async {
    try {
      final jsonString = await rootBundle.loadString('supplements.json');
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final supplementsList = jsonData['supplements'] as List;

      for (var suppJson in supplementsList) {
        final supplement = Supplement.fromJson(suppJson as Map<String, dynamic>);
        await _db.insertSupplement(supplement);
      }

      print('✅ Imported ${supplementsList.length} supplements');
    } catch (e) {
      print('❌ Error importing supplements: $e');
      rethrow;
    }
  }

  /// Import exercise modules from JSON file
  Future<void> importExercises() async {
    try {
      final jsonString = await rootBundle.loadString('exercises.json');
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final modules = jsonData['modules'] as Map<String, dynamic>;

      for (var entry in modules.entries) {
        final moduleId = entry.key;
        final moduleData = entry.value; // Can be Map or List

        // Pass directly to fromJson - it handles both types
        final module = ExerciseModule.fromJson(moduleId, moduleData);
        await _db.insertExerciseModule(module);
      }

      print('✅ Imported ${modules.length} exercise modules');
    } catch (e) {
      print('❌ Error importing exercises: $e');
      rethrow;
    }
  }

  /// Import schedule from JSON file
  Future<void> importSchedule() async {
    try {
      final jsonString = await rootBundle.loadString('fullschedule.json');
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final weekSchedule = jsonData['week_schedule'] as List;

      // Load supplements for matching
      final allSupplements = await _db.getAllSupplements();
      final supplementMap = {for (var s in allSupplements) s.name: s.id};

      int eventCount = 0;
      for (var dayData in weekSchedule) {
        final day = _parseDayName(dayData['day'] as String);
        final events = dayData['events'] as List;

        for (var eventJson in events) {
          final event = await _parseScheduleEvent(
            day,
            eventJson as Map<String, dynamic>,
            supplementMap,
          );

          if (event != null) {
            await _db.insertScheduleEvent(event);
            eventCount++;
          }
        }
      }

      print('✅ Imported $eventCount schedule events');
    } catch (e) {
      print('❌ Error importing schedule: $e');
      rethrow;
    }
  }

  /// Parse a schedule event and match supplement names to IDs
  Future<ScheduleEvent?> _parseScheduleEvent(
    String day,
    Map<String, dynamic> json,
    Map<String, String> supplementMap,
  ) async {
    // Skip branch events for now (saving for later phase)
    if (json['type'] == 'branch') {
      return null;
    }

    final eventType = json['type'] as String;
    final time = json['time'] as String;

    // Determine if this should be a task
    bool isTask = _shouldBeTask(eventType, json);

    // Extract details
    String? details;
    String? moduleId;
    List<String>? supplementIds;

    if (json['details'] is String) {
      details = json['details'] as String;
    } else if (json['details'] is List) {
      // Supplement list - match names to IDs
      supplementIds = _matchSupplementNames(
        json['details'] as List,
        supplementMap,
      );
    }

    if (json['module'] != null) {
      moduleId = json['module'] as String;
    }

    return ScheduleEvent(
      dayOfWeek: day,
      time: time,
      eventType: eventType,
      details: details,
      moduleId: moduleId,
      supplementIds: supplementIds,
      isTask: isTask,
      metadata: json,
    );
  }

  /// Match supplement descriptions to IDs
  List<String> _matchSupplementNames(
    List<dynamic> supplementList,
    Map<String, String> supplementMap,
  ) {
    List<String> ids = [];

    for (var item in supplementList) {
      if (item is String) {
        // Try to match by name
        // e.g., "Creatine 3–5 g" should match supplement with name "Creatine monohydrate"
        String matchedId = _findSupplementId(item, supplementMap);
        if (matchedId.isNotEmpty) {
          ids.add(matchedId);
        }
      }
    }

    return ids;
  }

  /// Find supplement ID by matching description against supplement names
  String _findSupplementId(String description, Map<String, String> supplementMap) {
    final lowerDesc = description.toLowerCase();

    // Direct ID match first
    if (supplementMap.containsKey(description)) {
      return supplementMap[description]!;
    }

    // Fuzzy matching
    for (var entry in supplementMap.entries) {
      final name = entry.key.toLowerCase();
      final id = entry.value;

      // Check if description contains key terms from supplement name
      if (_containsKeyTerms(lowerDesc, name)) {
        return id;
      }
    }

    // If no match, return the description as fallback (will need manual matching)
    return '';
  }

  /// Check if description contains key terms from supplement name
  bool _containsKeyTerms(String description, String supplementName) {
    // Extract key terms
    final descWords = description.split(' ').map((w) => w.toLowerCase()).toSet();

    // Key matching patterns
    if (description.contains('creatine') && supplementName.contains('creatine')) {
      return true;
    }
    if (description.contains('omega') && supplementName.contains('omega')) {
      return true;
    }
    if (description.contains('vitamin d') && supplementName.contains('vitamin d')) {
      return true;
    }
    if (description.contains('vitamin k') && supplementName.contains('vitamin k')) {
      return true;
    }
    if (description.contains('magnesium') && supplementName.contains('magnesium')) {
      return true;
    }
    if (description.contains('zinc') && supplementName.contains('zinc')) {
      return true;
    }
    if (description.contains('nmn') && supplementName.contains('nmn')) {
      return true;
    }
    if (description.contains('nr') && supplementName.contains('nr')) {
      return true;
    }
    if (description.contains('resveratrol') && supplementName.contains('resveratrol')) {
      return true;
    }
    if (description.contains('quercetin') && supplementName.contains('quercetin')) {
      return true;
    }
    if (description.contains('curcumin') && supplementName.contains('curcumin')) {
      return true;
    }
    if (description.contains('spermidine') && supplementName.contains('spermidine')) {
      return true;
    }
    if (description.contains('coq10') && supplementName.contains('coq10')) {
      return true;
    }
    if (description.contains('acetyl-l-carnitine') && supplementName.contains('acetyl')) {
      return true;
    }
    if (description.contains('sulforaphane') && supplementName.contains('sulforaphane')) {
      return true;
    }

    return false;
  }

  /// Determine if event should generate a task
  bool _shouldBeTask(String eventType, Map<String, dynamic> json) {
    // Task-generating event types
    if (eventType == 'supplements' ||
        eventType == 'exercise' ||
        eventType == 'breathing' ||
        eventType == 'hydration') {
      return true;
    }

    // Caffeine: first of day is task, last is reminder
    if (eventType == 'caffeine') {
      final details = json['details'] as String? ?? '';
      if (details.contains('Must finish by') || details.contains('allowed')) {
        return false; // Reminder
      }
      return true; // Task
    }

    return false; // Everything else is info/reminder
  }

  /// Parse day name abbreviation
  String _parseDayName(String day) {
    // Already in correct format (Mon, Tue, Wed, etc.)
    return day;
  }

  /// Clear all imported data (for reimport)
  Future<void> clearAllData() async {
    await _db.clearScheduleEvents();
    // Note: Not clearing supplements/exercises to preserve user edits
    print('✅ Cleared schedule data');
  }
}
