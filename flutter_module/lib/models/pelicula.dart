class Pelicula {
  final int id;
  String titulo;
  String genero;
  int anio;
  bool enStreaming;
  String imagenUrl;

  Pelicula({
    required this.id,
    required this.titulo,
    required this.genero,
    required this.anio,
    required this.enStreaming,
    required this.imagenUrl,
  });
}