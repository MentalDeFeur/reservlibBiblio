import 'dart:convert';
import 'dart:html' as html;
import '../models/livre.dart';

class WebStorageHelper {
  static const String _livresKey = 'bibliotheque_livres';
  static const String _reservationsKey = 'bibliotheque_reservations';

  // Livres
  static Future<List<Livre>> getAllLivres() async {
    final jsonString = html.window.localStorage[_livresKey];
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Livre.fromMap(json)).toList();
  }

  static Future<Livre> saveLivre(Livre livre) async {
    final livres = await getAllLivres();

    if (livre.id == null) {
      // Nouveau livre - générer un ID
      final maxId = livres.isEmpty
          ? 0
          : livres.map((l) => l.id ?? 0).reduce((a, b) => a > b ? a : b);
      final newLivre = livre.copyWith(id: maxId + 1);
      livres.add(newLivre);
      await _saveLivres(livres);
      return newLivre;
    } else {
      // Mise à jour d'un livre existant
      final index = livres.indexWhere((l) => l.id == livre.id);
      if (index != -1) {
        livres[index] = livre;
        await _saveLivres(livres);
      }
      return livre;
    }
  }

  static Future<void> deleteLivre(int id) async {
    final livres = await getAllLivres();
    livres.removeWhere((l) => l.id == id);
    await _saveLivres(livres);
  }

  static Future<Livre?> getLivre(int id) async {
    final livres = await getAllLivres();
    try {
      return livres.firstWhere((l) => l.id == id);
    } catch (e) {
      return null;
    }
  }

  static Future<List<Livre>> searchLivresByTitre(String query) async {
    final livres = await getAllLivres();
    return livres
        .where((l) => l.titre.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  static Future<List<Livre>> searchLivresByAuteur(String query) async {
    final livres = await getAllLivres();
    return livres
        .where((l) => l.auteur.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  static Future<List<Livre>> searchLivresByThematique(String query) async {
    final livres = await getAllLivres();
    return livres
        .where((l) => l.thematique.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  static Future<List<Livre>> searchLivresByNumero(String query) async {
    final livres = await getAllLivres();
    return livres
        .where((l) => l.numero.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  static Future<void> _saveLivres(List<Livre> livres) async {
    final jsonList = livres.map((l) => l.toMap()).toList();
    final jsonString = json.encode(jsonList);
    html.window.localStorage[_livresKey] = jsonString;
  }

  // Réservations
  static Future<List<Map<String, dynamic>>> getAllReservations() async {
    final jsonString = html.window.localStorage[_reservationsKey];
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }

  static Future<Map<String, dynamic>> saveReservation(
      Map<String, dynamic> reservation) async {
    final reservations = await getAllReservations();

    if (reservation['id'] == null) {
      // Nouvelle réservation - générer un ID
      final maxId = reservations.isEmpty
          ? 0
          : reservations
              .map((r) => r['id'] as int? ?? 0)
              .reduce((a, b) => a > b ? a : b);
      reservation['id'] = maxId + 1;
      reservations.add(reservation);
      await _saveReservations(reservations);
    } else {
      // Mise à jour
      final index =
          reservations.indexWhere((r) => r['id'] == reservation['id']);
      if (index != -1) {
        reservations[index] = reservation;
        await _saveReservations(reservations);
      }
    }
    return reservation;
  }

  static Future<void> deleteReservation(int id) async {
    final reservations = await getAllReservations();
    reservations.removeWhere((r) => r['id'] == id);
    await _saveReservations(reservations);
  }

  static Future<Map<String, dynamic>?> getReservation(int id) async {
    final reservations = await getAllReservations();
    try {
      return reservations.firstWhere((r) => r['id'] == id);
    } catch (e) {
      return null;
    }
  }

  static Future<void> _saveReservations(
      List<Map<String, dynamic>> reservations) async {
    final jsonString = json.encode(reservations);
    html.window.localStorage[_reservationsKey] = jsonString;
  }
}
