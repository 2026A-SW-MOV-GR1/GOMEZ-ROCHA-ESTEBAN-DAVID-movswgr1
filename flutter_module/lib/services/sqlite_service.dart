import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/pelicula.dart';

class SQLiteService {
  static Database? _db;

  static Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'peliculas.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE peliculas (
            id INTEGER PRIMARY KEY,
            titulo TEXT,
            genero TEXT,
            anio INTEGER,
            enStreaming INTEGER,
            imagenUrl TEXT
          )
        ''');
        // Datos iniciales
        await db.insert('peliculas', {
          'id': 1, 'titulo': 'Inception', 'genero': 'Ciencia Ficción',
          'anio': 2010, 'enStreaming': 1,
          'imagenUrl': 'https://picsum.photos/seed/inception/80/120'
        });
        await db.insert('peliculas', {
          'id': 2, 'titulo': 'El Padrino', 'genero': 'Drama',
          'anio': 1972, 'enStreaming': 0,
          'imagenUrl': 'https://picsum.photos/seed/padrino/80/120'
        });
        await db.insert('peliculas', {
          'id': 3, 'titulo': 'Interstellar', 'genero': 'Ciencia Ficción',
          'anio': 2014, 'enStreaming': 1,
          'imagenUrl': 'https://picsum.photos/seed/interstellar/80/120'
        });
      },
    );
  }

  static Future<List<Pelicula>> getAll() async {
    final database = await db;
    final maps = await database.query('peliculas');
    return maps.map((m) => Pelicula(
      id: m['id'] as int,
      titulo: m['titulo'] as String,
      genero: m['genero'] as String,
      anio: m['anio'] as int,
      enStreaming: (m['enStreaming'] as int) == 1,
      imagenUrl: m['imagenUrl'] as String,
    )).toList();
  }

  static Future<void> insert(Pelicula p) async {
    final database = await db;
    await database.insert('peliculas', {
      'id': p.id, 'titulo': p.titulo, 'genero': p.genero,
      'anio': p.anio, 'enStreaming': p.enStreaming ? 1 : 0,
      'imagenUrl': p.imagenUrl,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> delete(int id) async {
    final database = await db;
    await database.delete('peliculas', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> update(Pelicula p) async {
    final database = await db;
    await database.update('peliculas', {
      'titulo': p.titulo, 'genero': p.genero,
      'anio': p.anio, 'enStreaming': p.enStreaming ? 1 : 0,
    }, where: 'id = ?', whereArgs: [p.id]);
  }
}