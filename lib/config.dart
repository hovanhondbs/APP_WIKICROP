import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static final AppConfig instance = AppConfig._internal();

  String apiBase = ""; // ⭐ thêm biến apiBase

  AppConfig._internal();

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    // Nếu người dùng đã lưu API → ưu tiên giá trị này
    final savedApi = prefs.getString("api_base");
    if (savedApi != null && savedApi.isNotEmpty) {
      instance.apiBase = savedApi;
      return;
    }

    // Nếu chưa lưu: đọc từ assets/config.json
    final jsonStr = await rootBundle.loadString("assets/config.json");
    final data = jsonDecode(jsonStr);

    instance.apiBase = data["api_base"];
  }
}
