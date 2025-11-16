import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/livre.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'web_storage_helper_stub.dart'
    if (dart.library.html) 'web_storage_helper_web.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError(
          'Database not supported on web, use WebStorageHelper');
    }
    if (_database != null) return _database!;
    _database = await _initDB('bibliotheque.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Ajouter la colonne coverUrl
      await db.execute('ALTER TABLE livres ADD COLUMN coverUrl TEXT');
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNull = 'TEXT';

    await db.execute('''
      CREATE TABLE livres (
        id $idType,
        titre $textType,
        auteur $textType,
        thematique $textType,
        numero $textType,
        description $textTypeNull,
        coverUrl $textTypeNull,
        dateAjout $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE reservations (
        id $idType,
        titre $textType,
        dateDebut $textType,
        dateFin $textType,
        nomReservant $textTypeNull,
        description $textTypeNull,
        categorie $textTypeNull
      )
    ''');
  }

  // Opérations CRUD pour les livres
  Future<Livre> createLivre(Livre livre) async {
    if (kIsWeb) {
      return await WebStorageHelper.saveLivre(livre);
    }
    try {
      final db = await instance.database;
      print('Base de données obtenue, insertion du livre...');
      final id = await db.insert('livres', livre.toMap());
      print('Livre inséré avec ID: $id');
      return livre.copyWith(id: id);
    } catch (e) {
      print('Erreur dans createLivre: $e');
      rethrow;
    }
  }

  Future<Livre?> readLivre(int id) async {
    if (kIsWeb) {
      return await WebStorageHelper.getLivre(id);
    }
    final db = await instance.database;
    final maps = await db.query(
      'livres',
      columns: [
        'id',
        'titre',
        'auteur',
        'thematique',
        'numero',
        'description',
        'dateAjout'
      ],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Livre.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Livre>> readAllLivres() async {
    if (kIsWeb) {
      return await WebStorageHelper.getAllLivres();
    }
    final db = await instance.database;
    const orderBy = 'titre ASC';
    final result = await db.query('livres', orderBy: orderBy);
    return result.map((json) => Livre.fromMap(json)).toList();
  }

  Future<List<Livre>> searchLivresByAuteur(String auteur) async {
    if (kIsWeb) {
      return await WebStorageHelper.searchLivresByAuteur(auteur);
    }
    final db = await instance.database;
    final result = await db.query(
      'livres',
      where: 'auteur LIKE ?',
      whereArgs: ['%$auteur%'],
      orderBy: 'titre ASC',
    );
    return result.map((json) => Livre.fromMap(json)).toList();
  }

  Future<List<Livre>> searchLivresByThematique(String thematique) async {
    if (kIsWeb) {
      return await WebStorageHelper.searchLivresByThematique(thematique);
    }
    final db = await instance.database;
    final result = await db.query(
      'livres',
      where: 'thematique LIKE ?',
      whereArgs: ['%$thematique%'],
      orderBy: 'titre ASC',
    );
    return result.map((json) => Livre.fromMap(json)).toList();
  }

  Future<List<Livre>> searchLivresByTitre(String titre) async {
    if (kIsWeb) {
      return await WebStorageHelper.searchLivresByTitre(titre);
    }
    final db = await instance.database;
    final result = await db.query(
      'livres',
      where: 'titre LIKE ?',
      whereArgs: ['%$titre%'],
      orderBy: 'titre ASC',
    );
    return result.map((json) => Livre.fromMap(json)).toList();
  }

  Future<List<Livre>> searchLivresByNumero(String numero) async {
    if (kIsWeb) {
      return await WebStorageHelper.searchLivresByNumero(numero);
    }
    final db = await instance.database;
    final result = await db.query(
      'livres',
      where: 'numero LIKE ?',
      whereArgs: ['%$numero%'],
      orderBy: 'numero ASC',
    );
    return result.map((json) => Livre.fromMap(json)).toList();
  }

  Future<int> updateLivre(Livre livre) async {
    if (kIsWeb) {
      await WebStorageHelper.saveLivre(livre);
      return 1;
    }
    final db = await instance.database;
    return db.update(
      'livres',
      livre.toMap(),
      where: 'id = ?',
      whereArgs: [livre.id],
    );
  }

  Future<int> deleteLivre(int id) async {
    if (kIsWeb) {
      await WebStorageHelper.deleteLivre(id);
      return 1;
    }
    final db = await instance.database;
    return await db.delete(
      'livres',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
