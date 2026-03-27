import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static const _emailKey = 'saved_email';
  static const _passwordKey = 'saved_password';
  static const _rememberMeKey = 'remember_me';

  Future<void> saveLogin({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    await _storage.write(key: _emailKey, value: email);
    await _storage.write(key: _passwordKey, value: password);
    await _storage.write(key: _rememberMeKey, value: rememberMe.toString());
  }

  Future<String?> getSavedEmail() async {
    return _storage.read(key: _emailKey);
  }

  Future<String?> getSavedPassword() async {
    return _storage.read(key: _passwordKey);
  }

  Future<bool> getRememberMe() async {
    final value = await _storage.read(key: _rememberMeKey);
    return value == 'true';
  }

  Future<void> clearLogin() async {
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _passwordKey);
    await _storage.delete(key: _rememberMeKey);
  }
}