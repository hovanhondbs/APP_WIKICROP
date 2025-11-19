import 'dart:convert';
import 'package:flutter/services.dart';

class AppConfig {
  static AppConfig? _instance;
  final String apiBase;

  AppConfig({required this.apiBase});

  static AppConfig get instance {
    if (_instance == null) {
      throw Exception(
          "AppConfig chưa được load! Hãy gọi AppConfig.load() trong main()");
    }
    return _instance!;
  }

  static Future<void> load() async {
    final data = await rootBundle.loadString('assets/config.json');
    final jsonMap = jsonDecode(data);

    _instance = AppConfig(
      apiBase: jsonMap['api_base'],
    );
  }
}
