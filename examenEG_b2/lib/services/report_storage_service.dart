import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pet_report.dart';

/// Persiste los reportes en disco como JSON (SharedPreferences) y guarda una
/// copia local de las fotos en el directorio de documentos de la app.
class ReportStorageService {
  static const _storageKey = 'pet_reports_v1';

  Future<List<PetReport>> loadReports() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => PetReport.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveReports(List<PetReport> reports) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(reports.map((r) => r.toJson()).toList());
    await prefs.setString(_storageKey, raw);
  }

  /// Copia la foto seleccionada al directorio persistente de la app y
  /// devuelve la nueva ruta local.
  Future<String> persistPhoto(String sourcePath, String reportId) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final extension = sourcePath.split('.').last;
    final targetPath = '${docsDir.path}/pet_$reportId.$extension';
    final sourceFile = File(sourcePath);
    final savedFile = await sourceFile.copy(targetPath);
    return savedFile.path;
  }
}
