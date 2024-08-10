import 'package:http/http.dart' as http;
import 'dart:convert';

class ReportService {//컴퓨터에 맞게 포트번호 변경
  final String baseUrl = "http://192.168.0.12:8081"; // 서버의 URL을 사용

  // recordId로 기록 조회
  Future<Map<String, dynamic>> fetchRecordById(int recordId) async {
    final response = await http.get(Uri.parse('$baseUrl/your-endpoint/$recordId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load record');
    }
  }

  // recordId로 평가 점수를 요청
  Future<double> evaluateRecord(int recordId) async {
    final response = await http.post(Uri.parse('$baseUrl/rating/score/$recordId'));

    if (response.statusCode == 200) {
      return double.parse(response.body);  // 서버에서 반환된 점수를 double로 파싱
    } else {
      throw Exception('Failed to evaluate record');
    }
  }

  // 새로운 평가를 서버로 전송
  Future<void> sendRating(int recordId, double rating, double starRating) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rating'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'rating': rating,
        'starRating': starRating,
        'recordId': recordId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send rating');
    }
  }
}
