import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

Future<void> initializeSqflite() async {
  // Vérifier d'abord si c'est une plateforme desktop
  try {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Initialiser sqflite FFI pour les plateformes desktop
      sqfliteFfiInit();
      // Définir la factory par défaut pour sqflite
      databaseFactory = databaseFactoryFfi;
    }
  } catch (e) {
    // Sur mobile, Platform.isAndroid/isIOS ne causera pas d'erreur
    // mais les imports FFI pourraient, donc on ignore
    print('Sqflite FFI initialization skipped: $e');
  }
  // Pour Android et iOS, sqflite fonctionne nativement sans configuration
}
