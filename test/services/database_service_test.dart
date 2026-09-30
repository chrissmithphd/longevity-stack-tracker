import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:longevity/services/database_service.dart';
import 'package:longevity/models/schedule/schedule_models.dart';

void main() {
  // Initialize FFI for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DatabaseService Supplement Tests', () {
    late DatabaseService db;

    setUp(() async {
      db = DatabaseService.instance;
      // Start with fresh database for each test
      await db.database;
    });

    test('getAllSupplements sorts by importance DESC then name ASC', () async {
      // Insert test supplements with different importance scores
      final testSupplements = [
        Supplement(
          id: 'test_b_7',
          name: 'B Test Supplement',
          dose: '100mg',
          timingRule: 'with_meal',
          foodRequired: false,
          notes: 'Test',
          active: true,
          importance: 7,
        ),
        Supplement(
          id: 'test_a_10',
          name: 'A Test Supplement',
          dose: '200mg',
          timingRule: 'with_meal',
          foodRequired: false,
          notes: 'Test',
          active: true,
          importance: 10,
        ),
        Supplement(
          id: 'test_c_10',
          name: 'C Test Supplement',
          dose: '300mg',
          timingRule: 'with_meal',
          foodRequired: false,
          notes: 'Test',
          active: true,
          importance: 10,
        ),
      ];

      for (var supp in testSupplements) {
        await db.insertSupplement(supp);
      }

      // Retrieve all supplements
      final supplements = await db.getAllSupplements();

      // Filter to only test supplements
      final testResults = supplements
          .where((s) => s.id.startsWith('test_'))
          .toList();

      // Verify sorting: importance DESC (10, 10, 7), then name ASC (A, C, B)
      expect(testResults.length, 3);
      expect(testResults[0].id, 'test_a_10'); // importance=10, name=A
      expect(testResults[1].id, 'test_c_10'); // importance=10, name=C
      expect(testResults[2].id, 'test_b_7');  // importance=7, name=B

      // Cleanup
      for (var supp in testSupplements) {
        await db.deleteSupplement(supp.id);
      }
    });

    test('Supplement active flag toggles correctly', () async {
      final testSupplement = Supplement(
        id: 'test_toggle',
        name: 'Toggle Test',
        dose: '100mg',
        timingRule: 'with_meal',
        foodRequired: false,
        notes: 'Test',
        active: true,
        importance: 5,
      );

      // Insert
      await db.insertSupplement(testSupplement);

      // Verify active
      var retrieved = await db.getSupplement('test_toggle');
      expect(retrieved?.active, true);

      // Toggle to inactive
      await db.updateSupplement(testSupplement.copyWith(active: false));
      retrieved = await db.getSupplement('test_toggle');
      expect(retrieved?.active, false);

      // Cleanup
      await db.deleteSupplement('test_toggle');
    });

    test('Supplement importance persists correctly', () async {
      final testSupplement = Supplement(
        id: 'test_importance',
        name: 'Importance Test',
        dose: '100mg',
        timingRule: 'with_meal',
        foodRequired: false,
        notes: 'Test',
        active: true,
        importance: 9,
      );

      await db.insertSupplement(testSupplement);

      final retrieved = await db.getSupplement('test_importance');
      expect(retrieved?.importance, 9);

      // Cleanup
      await db.deleteSupplement('test_importance');
    });
  });

  group('DatabaseService Exercise Tests', () {
    late DatabaseService db;

    setUp(() async {
      db = DatabaseService.instance;
      await db.database;
    });

    test('Exercise module active flag toggles correctly', () async {
      final testModule = ExerciseModule(
        id: 'test_exercise',
        name: 'Test Exercise',
        moduleType: 'strength',
        details: {'exercises': []},
        active: true,
      );

      await db.insertExerciseModule(testModule);

      var retrieved = await db.getExerciseModule('test_exercise');
      expect(retrieved?.active, true);

      await db.updateExerciseModule(testModule.copyWith(active: false));
      retrieved = await db.getExerciseModule('test_exercise');
      expect(retrieved?.active, false);

      // Cleanup
      await db.deleteExerciseModule('test_exercise');
    });
  });
}
