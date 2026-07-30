// Simplified database stub — Drift code generation not needed for web/Chrome preview.
// On Android: run `flutter pub run build_runner build` to generate database.g.dart
// and restore the full Drift implementation.

import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppDatabase {
  static const String _dbKeyName = 'carebridge_db_sqlcipher_passphrase';
  static const _secureStorage = FlutterSecureStorage();

  /// Fetches or generates a cryptographically secure 256-bit passphrase stored in Android Keystore.
  /// NO string literal passphrases are used anywhere in the codebase.
  static Future<String> getOrGeneratePassphrase() async {
    String? passphrase = await _secureStorage.read(key: _dbKeyName);
    if (passphrase == null) {
      final random = Random.secure();
      final values = List<int>.generate(32, (i) => random.nextInt(256));
      passphrase = base64Url.encode(values);
      await _secureStorage.write(key: _dbKeyName, value: passphrase);
    }
    return passphrase;
  }
}
