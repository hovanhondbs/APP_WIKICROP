import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class ApiConfigPage extends StatefulWidget {
  @override
  _ApiConfigPageState createState() => _ApiConfigPageState();
}

class _ApiConfigPageState extends State<ApiConfigPage> {
  TextEditingController apiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    apiController.text = AppConfig.instance.apiBase;
  }

  Future<void> saveApi() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("api_base", apiController.text);

    AppConfig.instance.apiBase = apiController.text;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Đã lưu địa chỉ API")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Cấu hình API"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: apiController,
              decoration: InputDecoration(
                labelText: "Địa chỉ API",
                prefixIcon: Icon(Icons.link),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveApi,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text("Lưu"),
            )
          ],
        ),
      ),
    );
  }
}
