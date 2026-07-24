import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../models/pet_report.dart';
import '../providers/pet_reports_provider.dart';
import '../services/location_service.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key, required this.initialCenter});

  final LatLng initialCenter;

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mapController = MapController();
  final _locationService = LocationService();
  final _imagePicker = ImagePicker();

  final _nameCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _contactNameCtrl = TextEditingController();
  final _contactPhoneCtrl = TextEditingController();

  PetSpecies _species = PetSpecies.dog;
  late LatLng _selectedLocation;
  String? _address;
  String? _photoPath;
  bool _isResolvingAddress = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialCenter;
    _resolveAddress(_selectedLocation);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    _colorCtrl.dispose();
    _descriptionCtrl.dispose();
    _contactNameCtrl.dispose();
    _contactPhoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _resolveAddress(LatLng point) async {
    setState(() => _isResolvingAddress = true);
    final address = await _locationService.reverseGeocode(
      point.latitude,
      point.longitude,
    );
    if (!mounted) return;
    setState(() {
      _address = address;
      _isResolvingAddress = false;
    });
  }

  void _onMapTapped(LatLng point) {
    setState(() => _selectedLocation = point);
    _resolveAddress(point);
  }

  Future<void> _useMyLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      final point = LatLng(position.latitude, position.longitude);
      setState(() => _selectedLocation = point);
      _mapController.move(point, 16);
      _resolveAddress(point);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picked = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1280,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _photoPath = picked.path);
    }
  }

  void _showPhotoSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de galería'),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final provider = context.read<PetReportsProvider>();
      final report = await provider.addReport(
        name: _nameCtrl.text.trim(),
        species: _species,
        breed: _breedCtrl.text.trim(),
        color: _colorCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        contactName: _contactNameCtrl.text.trim(),
        contactPhone: _contactPhoneCtrl.text.trim(),
        localPhotoPath: _photoPath,
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
        address: _address,
      );
      if (!mounted) return;
      Navigator.of(context).pop(report);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportar mascota perdida')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(child: _PhotoPicker(photoPath: _photoPath, onTap: _showPhotoSourceSheet)),
            const SizedBox(height: 20),
            SegmentedButton<PetSpecies>(
              segments: const [
                ButtonSegment(
                  value: PetSpecies.dog,
                  label: Text('Perro'),
                  icon: Icon(Icons.pets),
                ),
                ButtonSegment(
                  value: PetSpecies.cat,
                  label: Text('Gato'),
                  icon: Icon(Icons.cruelty_free),
                ),
              ],
              selected: {_species},
              onSelectionChanged: (s) => setState(() => _species = s.first),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre de la mascota'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _breedCtrl,
              decoration: const InputDecoration(labelText: 'Raza (opcional)'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _colorCtrl,
              decoration: const InputDecoration(labelText: 'Color'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionCtrl,
              decoration: const InputDecoration(
                labelText: 'Descripción / señas particulares',
              ),
              maxLines: 3,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _contactNameCtrl,
              decoration: const InputDecoration(labelText: 'Tu nombre (contacto)'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _contactPhoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Teléfono de contacto',
                hintText: 'Ej. 0991234567',
              ),
              keyboardType: TextInputType.phone,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.place, size: 20),
                const SizedBox(width: 6),
                const Text(
                  'Última ubicación donde se perdió',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _useMyLocation,
                  icon: const Icon(Icons.my_location, size: 18),
                  label: const Text('Mi ubicación'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Toca el mapa para ajustar el punto exacto',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 260,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedLocation,
                    initialZoom: 15,
                    onTap: (_, point) => _onMapTapped(point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.examen.petfinder.pet_finder',
                    ),
                    MarkerLayer(markers: [
                      Marker(
                        point: _selectedLocation,
                        width: 40,
                        height: 40,
                        alignment: Alignment.bottomCenter,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.deepOrange,
                          size: 40,
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _isResolvingAddress
                        ? 'Buscando dirección...'
                        : (_address ??
                            '${_selectedLocation.latitude.toStringAsFixed(5)}, '
                                '${_selectedLocation.longitude.toStringAsFixed(5)}'),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isSaving ? null : _submit,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check),
              label: Text(_isSaving ? 'Guardando...' : 'Publicar reporte'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({required this.photoPath, required this.onTap});

  final String? photoPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 56,
        backgroundColor: Colors.grey.shade200,
        backgroundImage: photoPath != null ? FileImage(File(photoPath!)) : null,
        child: photoPath == null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_a_photo, color: Colors.grey.shade600),
                  const SizedBox(height: 4),
                  Text(
                    'Añadir foto',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
