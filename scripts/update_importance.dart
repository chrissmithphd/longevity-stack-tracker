import 'dart:convert';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Quick script to update supplement importance scores in the database
/// Run with: dart run update_importance.dart
void main() async {
  // Initialize FFI for desktop
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Open database
  final dbPath = '${Platform.environment['HOME']}/.local/share/longevity/longevity.db';
  print('Opening database at: $dbPath');

  final db = await openDatabase(dbPath);

  // Read supplements.json
  final jsonFile = File('supplements.json');
  final jsonString = await jsonFile.readAsString();
  final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
  final supplements = jsonData['supplements'] as List;

  print('\nUpdating importance scores...\n');

  for (var supp in supplements) {
    final id = supp['id'] as String;
    final importance = supp['importance'] as int;
    final name = supp['name'] as String;

    await db.update(
      'supplements',
      {'importance': importance},
      where: 'id = ?',
      whereArgs: [id],
    );

    print('✅ $name: $importance/10');
  }

  await db.close();
  print('\n✅ Database updated successfully!');
}
