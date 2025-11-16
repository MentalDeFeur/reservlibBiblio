import '../models/livre.dart';

/// Stub pour les plateformes non-web
class WebStorageHelper {
  static Future<List<Livre>> getAllLivres() async {
    throw UnsupportedError(
        'WebStorageHelper is only available on web platform');
  }

  static Future<Livre> saveLivre(Livre livre) async {
    throw UnsupportedError(
        'WebStorageHelper is only available on web platform');
  }

  static Future<void> deleteLivre(int id) async {
    throw UnsupportedError(
        'WebStorageHelper is only available on web platform');
  }

  static Future<Livre?> getLivre(int id) async {
    throw UnsupportedError(
        'WebStorageHelper is only available on web platform');
  }

  static Future<List<Livre>> searchLivresByAuteur(String auteur) async {
    throw UnsupportedError(
        'WebStorageHelper is only available on web platform');
  }

  static Future<List<Livre>> searchLivresByThematique(String thematique) async {
    throw UnsupportedError(
        'WebStorageHelper is only available on web platform');
  }

  static Future<List<Livre>> searchLivresByTitre(String titre) async {
    throw UnsupportedError(
        'WebStorageHelper is only available on web platform');
  }

  static Future<List<Livre>> searchLivresByNumero(String numero) async {
    throw UnsupportedError(
        'WebStorageHelper is only available on web platform');
  }

  static Future<List<Map<String, dynamic>>> getAllReservations() async {
    throw UnsupportedError(
        'WebStorageHelper is only available on web platform');
  }

  static Future<Map<String, dynamic>> saveReservation(
      Map<String, dynamic> reservation) async {
    throw UnsupportedError(
        'WebStorageHelper is only available on web platform');
  }

  static Future<void> deleteReservation(int id) async {
    throw UnsupportedError(
        'WebStorageHelper is only available on web platform');
  }

  static Future<Map<String, dynamic>?> getReservation(int id) async {
    throw UnsupportedError(
        'WebStorageHelper is only available on web platform');
  }

  static Future<List<Map<String, dynamic>>> getReservationsByLivre(
      int livreId) async {
    throw UnsupportedError(
        'WebStorageHelper is only available on web platform');
  }
}
