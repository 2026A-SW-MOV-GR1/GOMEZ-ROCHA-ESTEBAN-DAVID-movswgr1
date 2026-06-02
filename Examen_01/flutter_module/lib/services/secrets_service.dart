import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum MecanismoStorage { sharedPreferences, dataStore, encryptedSharedPreferences }

class SecretsService {
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ── GUARDAR ──────────────────────────────────────
  static Future<void> guardar(
      String llave, String valor, MecanismoStorage mecanismo) async {
    switch (mecanismo) {
      case MecanismoStorage.sharedPreferences:
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('sp_$llave', valor);
        break;

      case MecanismoStorage.dataStore:
      // Flutter usa SharedPreferences de forma asíncrona
      // como equivalente a DataStore
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('ds_$llave', valor);
        break;

      case MecanismoStorage.encryptedSharedPreferences:
        await _secureStorage.write(key: 'enc_$llave', value: valor);
        break;
    }
  }

  // ── RECUPERAR ────────────────────────────────────
  static Future<String?> recuperar(
      String llave, MecanismoStorage mecanismo) async {
    switch (mecanismo) {
      case MecanismoStorage.sharedPreferences:
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString('sp_$llave');

      case MecanismoStorage.dataStore:
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString('ds_$llave');

      case MecanismoStorage.encryptedSharedPreferences:
        return await _secureStorage.read(key: 'enc_$llave');
    }
  }
}