import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_1/Services/AuthService.dart';

class RecordService {
  final String baseUrl = "http://192.168.56.1:8081"; // 백엔드 서버 URL

  // 사용자 인증 토큰을 이용해 식단 기록을 조회하는 함수
  Future<List<dynamic>> fetchMealLogsByDate(String date) async {
    final token = await AuthService.getToken(); // AuthService에서 토큰 가져오기
    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/getRecordsByDate?date=$date'),
      headers: {
        'Authorization': 'Bearer $token', // Bearer 토큰 사용
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load meal logs');
    }
  }

  // 식단 기록을 추가하는 함수
  Future<void> addMealRecord(Map<String, dynamic> recordData) async {
    final token = await AuthService.getToken(); // AuthService에서 토큰 가져오기
    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/addRecord'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(recordData),
      encoding: Encoding.getByName("utf-8"), // UTF-8 인코딩 설정
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add meal record');
    }
  }
}
