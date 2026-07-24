import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/pet_report.dart';
import '../services/report_storage_service.dart';

class PetReportsProvider extends ChangeNotifier {
  PetReportsProvider({ReportStorageService? storageService})
      : _storage = storageService ?? ReportStorageService();

  final ReportStorageService _storage;
  final _uuid = const Uuid();

  List<PetReport> _reports = [];
  bool _isLoading = true;

  List<PetReport> get reports => List.unmodifiable(_reports);
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _reports = await _storage.loadReports();
    _isLoading = false;
    notifyListeners();
  }

  Future<PetReport> addReport({
    required String name,
    required PetSpecies species,
    required String breed,
    required String color,
    required String description,
    required String contactName,
    required String contactPhone,
    String? localPhotoPath,
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    final id = _uuid.v4();
    String? persistedPhotoPath;
    if (localPhotoPath != null) {
      persistedPhotoPath = await _storage.persistPhoto(localPhotoPath, id);
    }

    final report = PetReport(
      id: id,
      name: name,
      species: species,
      breed: breed,
      color: color,
      description: description,
      contactName: contactName,
      contactPhone: contactPhone,
      photoPath: persistedPhotoPath,
      latitude: latitude,
      longitude: longitude,
      address: address,
      createdAt: DateTime.now(),
    );

    _reports = [report, ..._reports];
    await _storage.saveReports(_reports);
    notifyListeners();
    return report;
  }

  Future<void> addSighting({
    required String reportId,
    required double latitude,
    required double longitude,
    required String note,
  }) async {
    final sighting = Sighting(
      id: _uuid.v4(),
      latitude: latitude,
      longitude: longitude,
      note: note,
      reportedAt: DateTime.now(),
    );

    _reports = _reports.map((r) {
      if (r.id != reportId) return r;
      return r.copyWith(sightings: [...r.sightings, sighting]);
    }).toList();

    await _storage.saveReports(_reports);
    notifyListeners();
  }

  Future<void> markAsFound(String reportId) async {
    _reports = _reports.map((r) {
      if (r.id != reportId) return r;
      return r.copyWith(status: PetStatus.found);
    }).toList();
    await _storage.saveReports(_reports);
    notifyListeners();
  }

  Future<void> deleteReport(String reportId) async {
    _reports = _reports.where((r) => r.id != reportId).toList();
    await _storage.saveReports(_reports);
    notifyListeners();
  }

  PetReport? byId(String id) {
    try {
      return _reports.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}
