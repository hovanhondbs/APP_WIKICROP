import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;

import 'config.dart';
import 'api_config_page.dart'; // ← thêm import trang cấu hình API

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.load();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Tra cứu cây trồng",
      theme: ThemeData(
        primaryColor: Colors.green,
        scaffoldBackgroundColor: Color(0xFFF8FBEF),
      ),
      home: HomePage(),
    );
  }
}

//////////////////////////////////////////////////////////////////////
// API SEARCH – LẤY TÊN TRANG
//////////////////////////////////////////////////////////////////////

Future<String?> searchPageTitle(String keyword) async {
  final url =
      "${AppConfig.instance.apiBase}?action=query&list=search&format=json&srsearch=$keyword";

  try {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final list = data["query"]["search"];
      if (list.isNotEmpty) return list[0]["title"];
    }
  } catch (e) {
    print("Search error: $e");
  }
  return null;
}

//////////////////////////////////////////////////////////////////////
// API PARSE – LẤY HTML + HÌNH
//////////////////////////////////////////////////////////////////////

Future<Map<String, dynamic>?> fetchPlantContent(String title) async {
  final url =
      "${AppConfig.instance.apiBase}?action=parse&page=$title&format=json&prop=text|images";

  try {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data["parse"];
    }
  } catch (e) {
    print("Parse error: $e");
  }

  return null;
}

//////////////////////////////////////////////////////////////////////
// API LẤY LINK ẢNH
//////////////////////////////////////////////////////////////////////

Future<String?> getImageUrl(String fileName) async {
  final url =
      "${AppConfig.instance.apiBase}?action=query&titles=File:$fileName&prop=imageinfo&iiprop=url&format=json";

  try {
    final res = await http.get(Uri.parse(url));
    final data = jsonDecode(res.body);

    final pages = data["query"]["pages"];
    final key = pages.keys.first;
    final info = pages[key]["imageinfo"];

    if (info != null) return info[0]["url"];
  } catch (e) {
    print("Image error: $e");
  }

  return null;
}

//////////////////////////////////////////////////////////////////////
// HOME PAGE
//////////////////////////////////////////////////////////////////////

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final searchController = TextEditingController();
  List<String> recentViewed = [];

  final categories = {
    "Ngũ cốc (Cereal Crops)": ["Lúa", "Lúa mì", "Ngô", "Lúa miến"],
    "Các loại kê (Millet Crops)": ["Kê Ý", "Kê nhỏ"],
    "Cây họ đậu": ["Đậu xanh", "Đậu tương", "Đậu đen"],
    "Cây dầu ăn": ["Đậu phộng", "Vừng", "Cải dầu"],
    "Cây lấy đường": ["Mía", "Củ cải đường"],
    "Cây củ": ["Khoai tây", "Sắn"],
    "Cây ăn quả": ["Chuối", "Xoài", "Mít", "Ổi"],
    "Cây khác": ["Bắp"],
  };

  void saveRecent(String name) {
    recentViewed.remove(name);
    recentViewed.insert(0, name);
    if (recentViewed.length > 5) recentViewed.removeLast();
    setState(() {});
  }

  Future<void> handleSearch() async {
    final keyword = searchController.text.trim();
    if (keyword.isEmpty) return;

    saveRecent(keyword);
    final title = await searchPageTitle(keyword);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultPage(title: title ?? keyword),
      ),
    );
  }

  //////////////////////////////////////////////////////////////////
  // UI HOME
  //////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Tra cứu cây trồng",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.green, fontSize: 22),
        ),

        // ⭐⭐⭐ Thêm nút cấu hình API (⚙️)
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.green),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ApiConfigPage()),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: searchController,
              onSubmitted: (_) => handleSearch(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.green),
                hintText: "Nhập tên cây trồng...",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: handleSearch,
              icon: Icon(Icons.search),
              label: Text("Tìm kiếm"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            SizedBox(height: 20),
            if (recentViewed.isNotEmpty) ...[
              Text("Xem gần đây",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green)),
              SizedBox(height: 10),
              SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: recentViewed.map((name) {
                    return GestureDetector(
                      onTap: () async {
                        final title = await searchPageTitle(name);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ResultPage(title: title ?? name),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.history, color: Colors.green),
                            SizedBox(width: 8),
                            Text(name),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 20),
            ],
            Text("Danh mục cây trồng",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green)),
            SizedBox(height: 10),
            ...categories.entries.map((entry) {
              return Card(
                color: Colors.green[50],
                child: ExpansionTile(
                  leading: Icon(Icons.eco, color: Colors.green),
                  title: Text(entry.key,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800])),
                  children: entry.value.map((name) {
                    return ListTile(
                      title: Text(name),
                      onTap: () async {
                        saveRecent(name);
                        final title = await searchPageTitle(name);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ResultPage(title: title ?? name),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////////
// PAGE HIỂN THỊ KẾT QUẢ
//////////////////////////////////////////////////////////////////////

class ResultPage extends StatefulWidget {
  final String title;
  ResultPage({required this.title});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  String htmlContent = "";
  List<String> imageUrls = [];

  final synonym = {
    "ngô": "Bắp",
    "zea mays": "Bắp",
  };

  @override
  void initState() {
    super.initState();
    load();
  }

  String cleanHtml(String html) {
    html = html.replaceAll(
        RegExp(r'<span class="mw-editsection"[\s\S]*?<\/span>'), "");
    html = html.replaceAll(RegExp(r'\[sửa.*?\]'), "");
    html = html.replaceAll(RegExp(r'>sửa<'), "");
    html = html.replaceAll(RegExp(r'>sửa mã nguồn<'), "");
    html = html.replaceAll(
        RegExp(r'<span class="mw-editsection-bracket".*?<\/span>'), '');
    html = html.replaceAll(
        RegExp(r'<span class="mw-editsection-divider".*?<\/span>'), '');
    return html;
  }

  Future<void> load() async {
    String trueTitle = synonym[widget.title.toLowerCase()] ?? widget.title;

    final data = await fetchPlantContent(trueTitle);
    if (data == null) {
      setState(() {
        htmlContent = "<p>Không tìm thấy dữ liệu.</p>";
      });
      return;
    }

    List images = data["images"];
    imageUrls = [];

    for (var name in images) {
      if (name.toLowerCase().endsWith(".jpg") ||
          name.toLowerCase().endsWith(".png")) {
        final url = await getImageUrl(name);
        if (url != null) imageUrls.add(url);
      }
    }

    setState(() {
      htmlContent = cleanHtml(data["text"]["*"]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Colors.green,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(children: [
            if (imageUrls.isNotEmpty)
              ...imageUrls.map((url) => Container(
                    margin: EdgeInsets.only(bottom: 16),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(url)),
                  )),
            Html(
              data: htmlContent,
              onLinkTap: (url, _, __) async {
                if (url == null) return;

                String page = url.split("/").last;
                page = Uri.decodeFull(page);
                final trueName = await searchPageTitle(page);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ResultPage(title: trueName ?? page)),
                );
              },
            )
          ]),
        ));
  }
}
