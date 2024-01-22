import 'package:http/http.dart' as http;
import 'dart:convert';

class NewsProvider {
  final String apiKey = "e8db554e436b4414b448a3c853aba37b";
  final String apiUrl = "https://newsapi.org/v2/top-headlines?country=us";

  Future<List<dynamic>> fetchNews() async {
    final response = await http.get(Uri.parse("$apiUrl&apiKey=$apiKey"));

    if (response.statusCode == 200) {
      return json.decode(response.body)["articles"];
    } else {
      throw Exception('Failed to load news');
    }
  }
}
