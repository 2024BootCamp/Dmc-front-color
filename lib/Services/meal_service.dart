import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'AuthService.dart';

// 오늘의 추천 식단 API 호출 함수
Future<List<Map<String, dynamic>>> fetchRecommendedMealForToday() async {
  try {
    final token = await AuthService.getToken(); // AuthService에서 토큰 가져오기
    final response = await http.get(
      Uri.parse('http://localhost:8081/recommend-meal'),
      headers: {
        'Authorization': 'Bearer $token', // 헤더에 토큰 추가
      },
    );

    if (response.statusCode == 200) {
      var data = utf8.decode(response.bodyBytes);
      var jsonData = json.decode(data) as Map<String, dynamic>;

      List<dynamic> foodList = jsonData['foodResponseList'] ?? [];

      List<Map<String, dynamic>> meals = foodList.map((food) {
        return {
          'meal': food['foodName'] ?? '',
          'calories': '${food['calories'] ?? 0} kcal',
          'sugar': '${food['sugar'] ?? 0}g',
          'salt': '${food['sodium'] ?? 0}g', // 염분 값을 sodium으로 변경
        };
      }).toList();

      return meals;
    } else {
      throw Exception('Failed to load today\'s recommended meal, status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching today\'s recommended meal: $e');
    rethrow;
  }
}
// 식단 호불호
Future<bool> postLikeDislike(int recommendId, bool like) async {
  var url = Uri.parse('http://your-server.com/api/like-meal/$recommendId');
  var response = await http.post(url, body: {
    'recommendId': recommendId.toString(),
    'like': like.toString(),
  });

  return response.statusCode == 200;
}

// 날짜에 맞는 추천된 식단 데이터 가져오기 함수
Future<List<List<Map<String, dynamic>>>> fetchMealsByDate(DateTime date) async {
  try {
    final token = await AuthService.getToken(); // AuthService에서 토큰 가져오기
    final response = await http.get(
      Uri.parse('http://localhost:8081/recommend/by-date?date=${DateFormat('yyyy-MM-dd').format(date)}'),
      headers: {
        'Authorization': 'Bearer $token', // 헤더에 토큰 추가
      },
    );

    if (response.statusCode == 200) {
      var data = utf8.decode(response.bodyBytes);
      var jsonData = json.decode(data) as List<dynamic>;

      List<List<Map<String, dynamic>>> meals = [];
      for (var item in jsonData) {
        List<dynamic> foodList = item['foodResponseList'] ?? [];
        List<Map<String, dynamic>> mealList = foodList.map((food) {
          return {
            'meal': food['foodName'] ?? '',
            'calories': '${food['calories'] ?? 0} kcal',
            'sugar': '${food['sugar'] ?? 0}g',
            'salt': '${food['sodium'] ?? 0}g', // 염분 값을 sodium으로 변경
          };
        }).toList();
        meals.add(mealList);
      }

      return meals;
    } else {
      throw Exception('Failed to load meals by date, status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching meals by date: $e');
    rethrow;
  }
}

