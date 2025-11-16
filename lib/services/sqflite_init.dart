import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

Future<void> initializeSqflite() async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Initialiser sqflite FFI pour les plateformes desktop
    sqfliteFfiInit();
    // Définir la factory par défaut pour sqflite
    databaseFactory = databaseFactoryFfi;
  }
  // Pour Android et iOS, sqflite fonctionne nativement sans configuration
}
