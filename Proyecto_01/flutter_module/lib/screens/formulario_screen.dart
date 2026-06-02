import 'package:flutter/material.dart';
import '../models/pelicula.dart';
import '../services/sqlite_service.dart';
import '../services/hive_service.dart';
import '../services/hive_service.dart';

class FormularioScreen extends StatefulWidget {
  final Pelicula? pelicula;
  final bool usandoNoSQL;
  const FormularioScreen({super.key, this.pelicula,this.usandoNoSQL = false});

  @override
  State<FormularioScreen> createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloCtrl;
  late String _generoSeleccionado;
  late int _anioSeleccionado;
  late bool _enStreaming;

  final List<String> _generos = [
    'Acción', 'Comedia', 'Drama',
    'Ciencia Ficción', 'Terror', 'Thriller'
  ];

  @override
  void initState() {
    super.initState();
    _tituloCtrl = TextEditingController(
        text: widget.pelicula?.titulo ?? '');
    _generoSeleccionado = widget.pelicula?.genero ?? 'Acción';
    _anioSeleccionado = widget.pelicula?.anio ?? DateTime.now().year;
    _enStreaming = widget.pelicula?.enStreaming ?? false;
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    super.dispose();
  }

  Future  <void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.pelicula != null) {
      widget.pelicula!.titulo    = _tituloCtrl.text;
      widget.pelicula!.genero    = _generoSeleccionado;
      widget.pelicula!.anio      = _anioSeleccionado;
      widget.pelicula!.enStreaming = _enStreaming;
      if (widget.usandoNoSQL) {
        await HiveService.update(widget.pelicula!);
      } else {
        await SQLiteService.update(widget.pelicula!);
      }
      Navigator.pop(context);
    } else {
      final nueva = Pelicula(
        id: DateTime.now().millisecondsSinceEpoch,
        titulo: _tituloCtrl.text,
        genero: _generoSeleccionado,
        anio: _anioSeleccionado,
        enStreaming: _enStreaming,
        imagenUrl:
            'https://picsum.photos/seed/${_tituloCtrl.text}/80/120',
      );
      Navigator.pop(context, nueva);
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.pelicula != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar película' : 'Nueva película'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Título
            TextFormField(
              controller: _tituloCtrl,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.movie),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Ingresa un título' : null,
            ),
            const SizedBox(height: 16),

            // Género
            DropdownButtonFormField<String>(
              value: _generoSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Género',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _generos
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _generoSeleccionado = v!),
            ),
            const SizedBox(height: 16),

            // Año
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(_anioSeleccionado),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _anioSeleccionado = picked.year);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Año de estreno',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text('$_anioSeleccionado'),
              ),
            ),
            const SizedBox(height: 16),

            // Switch streaming
            Card(
              child: SwitchListTile(
                title: const Text('Disponible en streaming'),
                subtitle: const Text('Netflix, Prime, etc.'),
                secondary: const Icon(Icons.stream),
                value: _enStreaming,
                onChanged: (v) => setState(() => _enStreaming = v),
              ),
            ),
            const SizedBox(height: 24),

            // Botón guardar
            FilledButton.icon(
              onPressed: () async => await _guardar(),
              icon: Icon(esEdicion ? Icons.save : Icons.add),
              label: Text(esEdicion ? 'Guardar cambios' : 'Agregar película'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}