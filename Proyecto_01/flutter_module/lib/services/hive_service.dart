import 'package:hive_flutter/hive_flutter.dart';
import '../models/pelicula.dart';

class HiveService {
  static const _boxName = 'peliculas_nosql';

  static Future<void> init() async {
    await Hive.initFlutter();
    final box = await Hive.openBox<Map>(_boxName);
    // Datos iniciales si está vacío
    if (box.isEmpty) {
      await box.add({
        'id': 1, 'titulo': 'Dune', 'genero': 'Ciencia Ficción',
        'anio': 2021, 'enStreaming': true,
        'imagenUrl': 'https://picsum.photos/seed/dune/80/120'
      });
      await box.add({
        'id': 2, 'titulo': 'Parasite', 'genero': 'Thriller',
        'anio': 2019, 'enStreaming': false,
        'imagenUrl': 'https://picsum.photos/seed/parasite/80/120'
      });
      await box.add({
        'id': 3, 'titulo': 'The Batman', 'genero': 'Acción',
        'anio': 2022, 'enStreaming': true,
        'imagenUrl': 'https://picsum.photos/seed/batman/80/120'
      });
    }
  }

  static Future<List<Pelicula>> getAll() async {
    final box = await Hive.openBox<Map>(_boxName);
    return box.values.map((m) => Pelicula(
      id: m['id'] as int,
      titulo: m['titulo'] as String,
      genero: m['genero'] as String,
      anio: m['anio'] as int,
      enStreaming: m['enStreaming'] as bool,
      imagenUrl: m['imagenUrl'] as String,
    )).toList();
  }

  static Future<void> insert(Pelicula p) async {
    final box = await Hive.openBox<Map>(_boxName);
    await box.add({
      'id': p.id, 'titulo': p.titulo, 'genero': p.genero,
      'anio': p.anio, 'enStreaming': p.enStreaming,
      'imagenUrl': p.imagenUrl,
    });
  }

  static Future<void> delete(int id) async {
    final box = await Hive.openBox<Map>(_boxName);
    final key = box.keys.firstWhere(
          (k) => box.get(k)?['id'] == id,
      orElse: () => null,
    );
    if (key != null) await box.delete(key);
  }

  static Future<void> update(Pelicula p) async {
    final box = await Hive.openBox<Map>(_boxName);
    final key = box.keys.firstWhere(
          (k) => box.get(k)?['id'] == p.id,
      orElse: () => null,
    );
    if (key != null) {
      await box.put(key, {
        'id': p.id, 'titulo': p.titulo, 'genero': p.genero,
        'anio': p.anio, 'enStreaming': p.enStreaming,
        'imagenUrl': p.imagenUrl,
      });
    }
  }
}