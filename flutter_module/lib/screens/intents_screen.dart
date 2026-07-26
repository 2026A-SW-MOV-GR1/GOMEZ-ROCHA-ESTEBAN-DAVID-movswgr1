import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';

class IntentsScreen extends StatefulWidget {
  const IntentsScreen({super.key});

  @override
  State<IntentsScreen> createState() => _IntentsScreenState();
}

class _IntentsScreenState extends State<IntentsScreen> {
  final _telefonoCtrl = TextEditingController(text: '0987654321');
  File? _foto;
  bool  _cargandoFoto = false;

  // ── INTENT SALIENTE: DIAL ────────────────────────
  Future<void> _iniciarDial() async {
    final numero = _telefonoCtrl.text.trim();
    if (numero.isEmpty) return;

    final uri = Uri.parse('tel:$numero');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el marcador')),
        );
      }
    }
  }

  // ── INTENT SALIENTE: CÁMARA ───────────────────────
  Future<void> _tomarFoto() async {
    setState(() => _cargandoFoto = true);
    try {
      final picker = ImagePicker();
      final XFile? imagen = await picker.pickImage(source: ImageSource.camera);
      if (imagen != null) {
        setState(() => _foto = File(imagen.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _cargandoFoto = false);
    }
  }

  @override
  void dispose() {
    _telefonoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Módulo: Intents Salientes',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          // ── Panel 1: Llamador Misterioso ──────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.dialpad, color: Colors.green),
                      const SizedBox(width: 8),
                      Text('Llamador Misterioso',
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('ACTION_DIAL · tel:xxxxxxxxxx',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade600)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _telefonoCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Teléfono',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: _iniciarDial,
                        icon: const Icon(Icons.call),
                        label: const Text('Iniciar Dial'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Panel 2: Foto Express ─────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.camera_alt, color: Colors.purple),
                      const SizedBox(width: 8),
                      Text('Foto Express',
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('MediaStore.ACTION_IMAGE_CAPTURE',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade600)),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Miniatura
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: _cargandoFoto
                            ? const Center(
                            child: CircularProgressIndicator())
                            : _foto != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_foto!,
                              fit: BoxFit.cover),
                        )
                            : Icon(Icons.image,
                            size: 40, color: Colors.grey.shade400),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _tomarFoto,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Tomar Foto'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.purple,
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                      ),
                    ],
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