import 'dart:io';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class RecepcionScreen extends StatefulWidget {
  const RecepcionScreen({super.key});

  @override
  State<RecepcionScreen> createState() => _RecepcionScreenState();
}

class _RecepcionScreenState extends State<RecepcionScreen> {
  String? _textoRecibido;
  File?   _imagenRecibida;

  @override
  void initState() {
    super.initState();
    _escucharCompartidos();
  }

  void _escucharCompartidos() {
    // Mientras la app está abierta
    ReceiveSharingIntent.instance.getMediaStream().listen((files) {
      _procesarArchivos(files);
    });

    ReceiveSharingIntent.instance.getInitialMedia().then((files) {
      _procesarArchivos(files);
    });
  }

  void _procesarArchivos(List<SharedMediaFile> files) {
    if (files.isEmpty) return;
    final archivo = files.first;

    setState(() {
      if (archivo.type == SharedMediaType.text ||
          archivo.type == SharedMediaType.url) {
        _textoRecibido = archivo.path;
        _imagenRecibida = null;
      } else if (archivo.type == SharedMediaType.image) {
        _imagenRecibida = File(archivo.path);
        _textoRecibido = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hayDatos = _textoRecibido != null || _imagenRecibida != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Módulo: Intents Entrantes',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          // Estado
          Card(
            color: hayDatos ? Colors.green.shade50 : Colors.grey.shade100,
            child: ListTile(
              leading: Icon(
                hayDatos ? Icons.check_circle : Icons.hourglass_empty,
                color: hayDatos ? Colors.green : Colors.grey,
              ),
              title: Text(
                hayDatos
                    ? 'Datos recibidos'
                    : 'Esperando datos externos...',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: hayDatos ? Colors.green.shade800 : Colors.grey.shade700),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Receptor de texto
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.text_snippet, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text('Receptor de Chismes',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('SEND · text/plain',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Text(
                      _textoRecibido ?? 'Sin texto recibido aún',
                      style: TextStyle(
                          color: _textoRecibido != null
                              ? Colors.blue.shade900
                              : Colors.grey.shade500),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Receptor de imagen
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.image, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Text('Lector de Imágenes',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('SEND · image/*',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: _imagenRecibida != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(_imagenRecibida!,
                          fit: BoxFit.cover),
                    )
                        : Center(
                      child: Text('Sin imagen recibida aún',
                          style: TextStyle(color: Colors.grey.shade500)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}