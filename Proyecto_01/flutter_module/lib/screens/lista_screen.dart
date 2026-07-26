import 'package:flutter/material.dart';
import '../models/pelicula.dart';
import '../services/toast_channel.dart';
import '../services/sqlite_service.dart';
import '../services/hive_service.dart';
import 'formulario_screen.dart';
import 'rest_screen.dart';
import 'secrets_screen.dart';
import 'intents_tab_screen.dart';

class ListaScreen extends StatefulWidget {
  const ListaScreen({super.key});
  @override
  State<ListaScreen> createState() => _ListaScreenState();
}

class _ListaScreenState extends State<ListaScreen> {
  List<Pelicula> _peliculas = [];
  bool _usandoNoSQL = false;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    final datos = _usandoNoSQL
        ? await HiveService.getAll()
        : await SQLiteService.getAll();
    setState(() {
      _peliculas = datos;
      _cargando = false;
    });
  }

  void _cambiarBD(bool valor) {
    setState(() => _usandoNoSQL = valor);
    _cargarDatos();
  }

  void _eliminar(BuildContext context, Pelicula pelicula) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar película'),
        content: Text('¿Deseas eliminar "${pelicula.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (_usandoNoSQL) {
                await HiveService.delete(pelicula.id);
              } else {
                await SQLiteService.delete(pelicula.id);
              }
              await _cargarDatos();
              Navigator.pop(ctx);
              ToastChannel.mostrar('${pelicula.titulo} eliminada');
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Colores indicadores según BD activa
    final colorBD = _usandoNoSQL ? Colors.orange : Colors.blue;
    final labelBD = _usandoNoSQL ? 'NoSQL · Hive' : 'SQL · SQLite';
    final iconoBD = _usandoNoSQL ? Icons.inventory_2 : Icons.table_chart;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Películas'),
        centerTitle: true,
        backgroundColor: colorBD.shade100,
        actions: [
          // Indicador visual de BD activa
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: colorBD.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(iconoBD, size: 14, color: colorBD.shade800),
                const SizedBox(width: 4),
                Text(labelBD,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colorBD.shade800)),
              ],
            ),
          ),
          // Switch SQL/NoSQL
          Switch(
            value: _usandoNoSQL,
            onChanged: _cambiarBD,
            activeColor: Colors.orange,
            inactiveThumbColor: Colors.blue,
          ),
          // Botón REST
          IconButton(
            icon: const Icon(Icons.api),
            tooltip: 'REST API',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RestScreen()),
            ),
          ),
          // Botón Secrets
          IconButton(
            icon: const Icon(Icons.lock),
            tooltip: 'Gestión de Secretos',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SecretsScreen()),
            ),
          ),

          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Intents',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const IntentsTabScreen()),
            ),
          ),
        ],
      ),

      // Banner indicador debajo del AppBar
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            color: colorBD.shade50,
            child: Row(
              children: [
                Icon(iconoBD, size: 16, color: colorBD.shade700),
                const SizedBox(width: 8),
                Text(
                  _usandoNoSQL
                      ? 'Mostrando datos de Hive (NoSQL - orientado a documentos)'
                      : 'Mostrando datos de SQLite (SQL - relacional)',
                  style: TextStyle(
                      fontSize: 12,
                      color: colorBD.shade700,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Lista
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _peliculas.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.movie_creation_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text('No hay películas',
                      style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _peliculas.length,
              itemBuilder: (context, index) {
                final p = _peliculas[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        p.imagenUrl,
                        width: 50,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 50,
                          height: 70,
                          color: Colors.grey[300],
                          child: const Icon(Icons.movie),
                        ),
                      ),
                    ),
                    title: Text(p.titulo,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600)),
                    subtitle: Row(
                      children: [
                        Text('${p.genero} • ${p.anio}'),
                        const SizedBox(width: 8),
                        // Badge indicador de origen
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorBD.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _usandoNoSQL ? 'Hive' : 'SQLite',
                            style: TextStyle(
                                fontSize: 10,
                                color: colorBD.shade800,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete,
                          color: Colors.red),
                      onPressed: () => _eliminar(context, p),
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              FormularioScreen(pelicula: p),
                        ),
                      );
                      _cargarDatos();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final nueva = await Navigator.push<Pelicula>(
            context,
            MaterialPageRoute(builder: (_) => const FormularioScreen()),
          );
          if (nueva != null) {
            if (_usandoNoSQL) {
              await HiveService.insert(nueva);
            } else {
              await SQLiteService.insert(nueva);
            }
            _cargarDatos();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
        backgroundColor: colorBD,
        foregroundColor: Colors.white,
      ),
    );
  }
}