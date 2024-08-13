import 'package:http/http.dart' as http;
import 'dart:convert';
import 'AuthService.dart';

class ReportService {
  final String baseUrl = "http://192.168.0.12:8081"; // 서버의 URL을 사용

  // recordId로 기록 조회
  Future<Map<String, dynamic>> fetchRecordById(int recordId) async {
    final response = await http.get(Uri.parse('$baseUrl/your-endpoint/$recordId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Error fetching record: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load record');
    }
  }

  // recordId로 평가 점수를 요청
  Future<double> evaluateRecord(int recordId) async {
    final token = await AuthService.getToken(); // AuthService에서 토큰 가져오기
    if (token == null) {
      throw Exception('No token found');
    }

    // 토큰 출력하여 확인
    print('Using token: $token');

    final response = await http.post(
      Uri.parse('$baseUrl/rating/score/$recordId'),
      headers: {
        'Authorization': 'Bearer $token', // Bearer 토큰 사용
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    print('Evaluating record with recordId: $recordId');
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        double score = double.parse(response.body);
        print('Score received: $score');
        return score;
      } catch (e) {
        print('Error parsing score: $e');
        throw Exception('Failed to parse the score');
      }
    } else {
      print('Error evaluating record: ${response.statusCode} - ${response.body}');
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

    // 상태 코드와 응답 본문을 로그에 출력
    print('Sending rating for recordId: $recordId');
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to send rating');
    }
  }
}
