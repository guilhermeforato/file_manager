import 'package:file_manager/config/env/env_config.dart';

import '../model/app_user.dart';
import '../services/secure_storage_service.dart';

class AuthRepository {
  final SecureStorageService _secureStorageService = SecureStorageService();

  AppUser? authenticate({
    required String email,
    required String password,
  }) {
    try {
      return EnvConfig.users.firstWhere( // firstWhere: Retorna o primeiro elemento que satisfaz a condição dada. Se nenhum elemento satisfizer a condição, lança uma exceção.
            (user) =>
        user.email.trim().toLowerCase() == email.trim().toLowerCase() &&
            user.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveRememberedLogin({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    if (rememberMe) {
      await _secureStorageService.saveLogin(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
      return;
    }

    await _secureStorageService.clearLogin();
  }

  Future<Map<String, dynamic>?> getRememberedLogin() async {
    final rememberMe = await _secureStorageService.getRememberMe();
    if (!rememberMe) return null;

    final email = await _secureStorageService.getSavedEmail();
    final password = await _secureStorageService.getSavedPassword();

    if (email == null || password == null) {
      return null;
    }

    return {
      'email': email,
      'password': password,
      'rememberMe': rememberMe,
    };
  }

  Future<void> clearRememberedLogin() async {
    await _secureStorageService.clearLogin();
  }
}