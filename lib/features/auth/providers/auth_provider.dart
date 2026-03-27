import 'package:file_manager/data/model/app_user.dart';
import 'package:flutter/material.dart';

import '../../../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  AppUser? _currentUser;
  bool _isLoading = false;
  bool _rememberMe = false;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get rememberMe => _rememberMe;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simula um atraso de rede
      await Future.delayed(const Duration(milliseconds: 1000));

      final user = _authRepository.authenticate(
        email: email,
        password: password,
      );

      if (user == null) {
        return false;
      }

      _currentUser = user;

      await _authRepository.saveRememberedLogin(
        email: email,
        password: password,
        rememberMe: _rememberMe,
      );

      return true;
    } catch (e) {
      debugPrint('Erro no login: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> tryAutoLogin() async {
    _isLoading = true;
    notifyListeners();
    //
    try {
      final rememberedLogin = await _authRepository.getRememberedLogin();

      if (rememberedLogin == null) {
        return false;
      }

      final email = rememberedLogin['email'] as String;
      final password = rememberedLogin['password'] as String;
      _rememberMe = rememberedLogin['rememberMe'] as bool;

      final user = _authRepository.authenticate(
        email: email,
        password: password,
      );

      if (user == null) {
        return false;
      }

      _currentUser = user;
      return true;
    } catch (e) {
      debugPrint('Erro no auto login: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      _currentUser = null;
      _rememberMe = false;
      await _authRepository.clearRememberedLogin();
    } catch (e) {
      debugPrint('Erro no logout: $e');
    } finally {
      notifyListeners();
    }
  }
}