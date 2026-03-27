import 'package:file_manager/data/services/env_service.dart';
import 'package:flutter/material.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const envPath = String.fromEnvironment(
    'ENV_PATH',
    defaultValue: 'assets/config/env_admin.json',
  );

  await EnvService.load(envPath);

  runApp(const MyApp());
}