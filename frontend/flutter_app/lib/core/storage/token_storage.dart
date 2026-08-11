import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  // ⚡ Modern zero-config setup for flutter_secure_storage v9+ and v11+
  static const _storage = FlutterSecureStorage();

  static const String _tokenKey = 'access_token';
  static const String _tokenTypeKey = 'token_type';

  static Future<void> saveToken({
    required String accessToken,
    required String tokenType,
  }) async {
    await _storage.write(key: _tokenKey, value: accessToken);
    await _storage.write(key: _tokenTypeKey, value: tokenType);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _tokenTypeKey);
  }
}