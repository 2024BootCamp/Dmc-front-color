import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'AuthService.dart';



// 추천 식단 API 호출 함수
// 추천 식단 데이터 가져오기 함수
Future<List<Map<String, String>>> fetchRecommendedMeals() async {
  try {
    final token = await AuthService.getToken();// AuthService에서 토큰 가져오기
    final response = await http.get(
      Uri.parse('http://localhost:8081/recommend-meal'),
      headers: {
        'Authorization': 'Bearer $token', // 헤더에 토큰 추가
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      // data를 처리하여 반환
      List<dynamic> mealsData = data['foodResponseList'] ?? [];
      List<Map<String, String>> meals = [];
      for (var meal in mealsData) {
        meals.add({
          'meal': meal['foodName'] ?? '',
          'calories': '${meal['calories'] ?? 0} kcal',
          'sugar': '${meal['sugar'] ?? 0}g',
          'salt': '${meal['sodium'] ?? 0}g', // 염분 값을 sodium으로 변경
        });
      }
      return meals;
    } else {
      throw Exception('Failed to load recommended meals, status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching recommended meals: $e');
    rethrow;
  }
}
// 날짜에 맞는 식단 데이터 가져오기 함수
Future<List<Map<String, String>>> fetchMealsByDate(DateTime date) async {
  try {
    final token = await AuthService.getToken(); // AuthService에서 토큰 가져오기
    final response = await http.get(
      Uri.parse('http://localhost:8081/meal-by-date?date=${DateFormat('yyyy-MM-dd').format(date)}'),
      headers: {
        'Authorization': 'Bearer $token', // 헤더에 토큰 추가
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      // data를 처리하여 반환
      List<dynamic> mealsData = data['meals'] ?? [];
      List<Map<String, String>> meals = [];
      for (var meal in mealsData) {
        meals.add({
          'meal': meal['mealName'] ?? '',
          'calories': '${meal['calories'] ?? 0} kcal',
          'sugar': '${meal['sugar'] ?? 0}g',
          'salt': '${meal['salt'] ?? 0}g',
        });
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
// // 식단 데이터를 가져오는 함수
// Future<List<Map<String, String>>> fetchRecommendedMeals(DateTime date) async {
//   final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
//   final response = await http.get(
//     Uri.parse('http://localhost:8081/recommend/by-date?date=$formattedDate'),
//   );
//
//   if (response.statusCode == 200) {
//     List<dynamic> data = json.decode(response.body);
//
//     // 데이터 가공
//     List<Map<String, String>> meals = [];
//     for (var item in data) {
//       List<dynamic> foodList = item['foodResponseList'] ?? [];
//       for (var food in foodList) {
//         meals.add({
//           'meal': food['foodName'] ?? '',
//           'calories': '${food['calories'] ?? 0} kcal',
//           'sugar': '${food['sugar'] ?? 0}g',
//           'salt': '${food['sodium'] ?? 0}g', // sodium을 salt로 변환
//         });
//       }
//     }
//
//     return meals;
//   } else {
//     throw Exception('Failed to load meals');
//   }
// }
