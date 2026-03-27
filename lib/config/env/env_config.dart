
import 'package:file_manager/data/model/app_user.dart';
import 'package:file_manager/data/services/env_service.dart';

class EnvConfig {
  static String get appName => EnvService.appName;

  static String get appFlavor => EnvService.appFlavor;

  static List<AppUser> get users {
    return EnvService.usersRaw
        .map((item) => AppUser.fromMap(item))
        .toList();
  }
}