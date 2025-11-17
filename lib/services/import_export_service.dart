import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/livre.dart';
import '../models/reservation.dart';
import 'database_helper.dart';
import 'reservation_service.dart';

class ImportExportService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ReservationService _reservationService = ReservationService();

  // Exporter les livres vers un fichier JSON
  Future<String?> exporterLivres() async {
    try {
      final livres = await _dbHelper.readAllLivres();
      final jsonData = {
        'version': '1.0',
        'type': 'livres',
        'date_export': DateTime.now().toIso8601String(),
        'data': livres.map((livre) => livre.toMap()).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
      final directory = await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/livres_export_$timestamp.json');
      await file.writeAsString(jsonString);

      return file.path;
    } catch (e) {
      print('Erreur lors de l\'export des livres: $e');
      return null;
    }
  }

  // Exporter les réservations vers un fichier JSON
  Future<String?> exporterReservations() async {
    try {
      final reservations = await _reservationService.readAllReservations();
      final jsonData = {
        'version': '1.0',
        'type': 'reservations',
        'date_export': DateTime.now().toIso8601String(),
        'data': reservations.map((reservation) => reservation.toMap()).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
      final directory = await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file =
          File('${directory.path}/reservations_export_$timestamp.json');
      await file.writeAsString(jsonString);

      return file.path;
    } catch (e) {
      print('Erreur lors de l\'export des réservations: $e');
      return null;
    }
  }

  // Exporter tout (livres + réservations)
  Future<String?> exporterTout() async {
    try {
      final livres = await _dbHelper.readAllLivres();
      final reservations = await _reservationService.readAllReservations();

      final jsonData = {
        'version': '1.0',
        'type': 'complet',
        'date_export': DateTime.now().toIso8601String(),
        'livres': livres.map((livre) => livre.toMap()).toList(),
        'reservations':
            reservations.map((reservation) => reservation.toMap()).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
      final directory = await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file =
          File('${directory.path}/bibliotheque_export_$timestamp.json');
      await file.writeAsString(jsonString);

      return file.path;
    } catch (e) {
      print('Erreur lors de l\'export complet: $e');
      return null;
    }
  }

  // Importer des livres depuis un fichier JSON
  Future<Map<String, dynamic>> importerLivres() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) {
        return {'success': false, 'message': 'Aucun fichier sélectionné'};
      }

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final jsonData = json.decode(jsonString);

      if (jsonData['type'] != 'livres' && jsonData['type'] != 'complet') {
        return {'success': false, 'message': 'Type de fichier incorrect'};
      }

      final livresData =
          jsonData['type'] == 'complet' ? jsonData['livres'] : jsonData['data'];

      int importes = 0;
      for (var livreMap in livresData) {
        try {
          final livre = Livre.fromMap(livreMap);
          await _dbHelper.createLivre(livre.copyWith(id: null));
          importes++;
        } catch (e) {
          print('Erreur import livre: $e');
        }
      }

      return {
        'success': true,
        'message': '$importes livre(s) importé(s)',
        'count': importes,
      };
    } catch (e) {
      print('Erreur lors de l\'import des livres: $e');
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  // Importer des réservations depuis un fichier JSON
  Future<Map<String, dynamic>> importerReservations() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) {
        return {'success': false, 'message': 'Aucun fichier sélectionné'};
      }

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final jsonData = json.decode(jsonString);

      if (jsonData['type'] != 'reservations' && jsonData['type'] != 'complet') {
        return {'success': false, 'message': 'Type de fichier incorrect'};
      }

      final reservationsData = jsonData['type'] == 'complet'
          ? jsonData['reservations']
          : jsonData['data'];

      int importes = 0;
      for (var reservationMap in reservationsData) {
        try {
          final reservation = Reservation.fromMap(reservationMap);
          await _reservationService
              .createReservation(reservation.copyWith(id: null));
          importes++;
        } catch (e) {
          print('Erreur import réservation: $e');
        }
      }

      return {
        'success': true,
        'message': '$importes réservation(s) importée(s)',
        'count': importes,
      };
    } catch (e) {
      print('Erreur lors de l\'import des réservations: $e');
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  // Importer tout depuis un fichier complet
  Future<Map<String, dynamic>> importerTout() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) {
        return {'success': false, 'message': 'Aucun fichier sélectionné'};
      }

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final jsonData = json.decode(jsonString);

      if (jsonData['type'] != 'complet') {
        return {
          'success': false,
          'message': 'Le fichier doit être un export complet'
        };
      }

      int livresImportes = 0;
      int reservationsImportees = 0;

      // Importer les livres
      if (jsonData['livres'] != null) {
        for (var livreMap in jsonData['livres']) {
          try {
            final livre = Livre.fromMap(livreMap);
            await _dbHelper.createLivre(livre.copyWith(id: null));
            livresImportes++;
          } catch (e) {
            print('Erreur import livre: $e');
          }
        }
      }

      // Importer les réservations
      if (jsonData['reservations'] != null) {
        for (var reservationMap in jsonData['reservations']) {
          try {
            final reservation = Reservation.fromMap(reservationMap);
            await _reservationService
                .createReservation(reservation.copyWith(id: null));
            reservationsImportees++;
          } catch (e) {
            print('Erreur import réservation: $e');
          }
        }
      }

      return {
        'success': true,
        'message':
            '$livresImportes livre(s) et $reservationsImportees réservation(s) importé(s)',
        'livres': livresImportes,
        'reservations': reservationsImportees,
      };
    } catch (e) {
      print('Erreur lors de l\'import complet: $e');
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }
}
