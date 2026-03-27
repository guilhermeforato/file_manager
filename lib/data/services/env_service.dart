import 'dart:convert';
import 'package:flutter/services.dart';

class EnvService {
  static late Map<String, dynamic> _env;

  static Future<void> load([
    String path = 'assets/config/env_admin.json',
  ]) async {
    final jsonString = await rootBundle.loadString(path);
    _env = json.decode(jsonString) as Map<String, dynamic>;
  }

  static String get appName => _env['APP_NAME'] as String? ?? 'File Manager';
  static String get appFlavor => _env['APP_FLAVOR'] as String? ?? 'default';
  static bool get isAdminBuild => _env['IS_ADMIN_BUILD'] as bool? ?? false;

  static List<Map<String, dynamic>> get usersRaw {
    final users = _env['USERS'] as List<dynamic>? ?? [];
    return users.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}