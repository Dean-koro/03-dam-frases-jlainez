import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:frasesapp/models/frase.dart';

class FrasesDb {
  FrasesDb._();
  static final FrasesDb instancia = FrasesDb._();
  static const _nombreArchivo = 'misfrases.db';
  static const _tabla = 'frases';
  Database? _db;

  // devuelve la base de datos abierta (la abre solo la primera vez)
  Future<Database> get _database async {
    _db ??= await _abrir();
    return _db!;
  }

  Future<Database> _abrir() async {
    final ruta = join(await getDatabasesPath(), _nombreArchivo);
    return openDatabase(
      ruta,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tabla (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          ffrase TEXT NOT NULL,
          autor TEXT NOT NULL)
          ''');
      },
    );
  }

  //guarda y devuelve el id
  Future<int> insert(Frase frase) async {
    final db = await _database;
    return db.insert(_tabla, frase.toMap());
  }

  //lee todas las frases de manera descendente
  Future<List<Frase>> obtenerTodas() async {
    final db = await _database;
    final filas = await db.query(_tabla, orderBy: 'id DESC');
    return filas.map(Frase.fromMap).toList();
  }

  //modifica usando el id
  Future<int> actualizar(Frase frase) async {
    final db = await _database;
    return db.update(_tabla, 
    frase.toMap(),
    where: 'id = ?',
    whereArgs: [frase..id]
    );
  }

  //eliminar la frase con el id
  Future<int> eliminar(int id) async {
    final db = await _database;
    return db.delete(_tabla, where: 'id = ?', whereArgs: [id]);
  }
}