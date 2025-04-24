import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> setAccessToken(String accessToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  static Future<void> deleteAccessToken() async {
    await _storage.delete(key: 'access_token');
  }
}
