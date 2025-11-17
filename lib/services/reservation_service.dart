import '../models/reservation.dart';
import 'database_helper.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'web_storage_helper_stub.dart'
    if (dart.library.html) 'web_storage_helper_web.dart';

class ReservationService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<Reservation> createReservation(Reservation reservation) async {
    if (kIsWeb) {
      final map = await WebStorageHelper.saveReservation(reservation.toMap());
      return Reservation.fromMap(map);
    }
    final db = await _dbHelper.database;
    final id = await db.insert('reservations', reservation.toMap());
    return reservation.copyWith(id: id);
  }

  Future<Reservation?> readReservation(int id) async {
    if (kIsWeb) {
      final map = await WebStorageHelper.getReservation(id);
      return map != null ? Reservation.fromMap(map) : null;
    }
    final db = await _dbHelper.database;
    final maps = await db.query(
      'reservations',
      columns: [
        'id',
        'titre',
        'dateDebut',
        'dateFin',
        'nomReservant',
        'description',
        'categorie'
      ],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Reservation.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Reservation>> readAllReservations() async {
    if (kIsWeb) {
      final maps = await WebStorageHelper.getAllReservations();
      return maps.map((json) => Reservation.fromMap(json)).toList();
    }
    final db = await _dbHelper.database;
    const orderBy = 'dateDebut ASC';
    final result = await db.query('reservations', orderBy: orderBy);
    return result.map((json) => Reservation.fromMap(json)).toList();
  }

  Future<List<Reservation>> getReservationsParDate(DateTime date) async {
    if (kIsWeb) {
      final allReservations = await readAllReservations();
      final debut = DateTime(date.year, date.month, date.day);
      final fin = DateTime(date.year, date.month, date.day, 23, 59, 59);
      return allReservations
          .where((r) => r.dateDebut.isBefore(fin) && r.dateFin.isAfter(debut))
          .toList();
    }
    final db = await _dbHelper.database;
    final debut = DateTime(date.year, date.month, date.day);
    final fin = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final result = await db.query(
      'reservations',
      where: 'dateDebut <= ? AND dateFin >= ?',
      whereArgs: [fin.toIso8601String(), debut.toIso8601String()],
      orderBy: 'dateDebut ASC',
    );
    return result.map((json) => Reservation.fromMap(json)).toList();
  }

  Future<List<Reservation>> getReservationsParPeriode(
      DateTime debut, DateTime fin) async {
    if (kIsWeb) {
      final allReservations = await readAllReservations();
      return allReservations
          .where((r) => r.dateDebut.isBefore(fin) && r.dateFin.isAfter(debut))
          .toList();
    }
    final db = await _dbHelper.database;
    final result = await db.query(
      'reservations',
      where: 'dateDebut <= ? AND dateFin >= ?',
      whereArgs: [fin.toIso8601String(), debut.toIso8601String()],
      orderBy: 'dateDebut ASC',
    );
    return result.map((json) => Reservation.fromMap(json)).toList();
  }

  Future<bool> verifierDisponibilite(DateTime debut, DateTime fin,
      {int? excludeId}) async {
    final reservations = await getReservationsParPeriode(debut, fin);

    for (var reservation in reservations) {
      if (excludeId != null && reservation.id == excludeId) {
        continue;
      }
      final nouvelle = Reservation(
        titre: '',
        dateDebut: debut,
        dateFin: fin,
      );
      if (nouvelle.conflitsAvec(reservation)) {
        return false;
      }
    }
    return true;
  }

  Future<int> updateReservation(Reservation reservation) async {
    if (kIsWeb) {
      await WebStorageHelper.saveReservation(reservation.toMap());
      return 1;
    }
    final db = await _dbHelper.database;
    return db.update(
      'reservations',
      reservation.toMap(),
      where: 'id = ?',
      whereArgs: [reservation.id],
    );
  }

  Future<int> deleteReservation(int id) async {
    if (kIsWeb) {
      await WebStorageHelper.deleteReservation(id);
      return 1;
    }
    final db = await _dbHelper.database;
    return await db.delete(
      'reservations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Vérifier si un livre est actuellement réservé
  Future<Reservation?> getReservationActivePourLivre(String titreLivre) async {
    final now = DateTime.now();
    final reservations = await readAllReservations();

    for (var reservation in reservations) {
      if (reservation.titre.toLowerCase() == titreLivre.toLowerCase() &&
          reservation.dateDebut.isBefore(now) &&
          reservation.dateFin.isAfter(now)) {
        return reservation;
      }
    }
    return null;
  }
}
