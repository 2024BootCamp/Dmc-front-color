//spring boot와 flutter 통신 담당 클래스 
// lib/services/service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  // 식단 추천 데이터 가져오기
  Future<List<Map<String, dynamic>>> getRecommendCountByDate(DateTime date) async {
    final url = Uri.parse('$baseUrl/recommend/by-date?date=${date.toIso8601String()}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load recommendations');
    }
  }
  // 건강 기록 데이터 전송
  Future<void> recordHealth(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/record-health');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print('Health data recorded successfully');
    } else {
      throw Exception('Failed to record health data');
    }
  }


}
