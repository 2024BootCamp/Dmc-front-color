import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Services/AuthService.dart';

class HealthService {
  static Future<List<dynamic>> fetchHealthData() async {
    final token = await AuthService.getToken(); // AuthService에서 토큰 가져오기
    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.get(
      Uri.parse('http://172.16.227.191:8081/healthStatus/user'),
      headers: {
        'Authorization': 'Bearer $token', // Bearer 토큰 사용
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load health data');
    }
  }

  static Future<void> updateHealthData(Map<String, dynamic> updatedData) async {
    final token = await AuthService.getToken();
    final response = await http.post(
      Uri.parse('http://172.16.227.191:8081/healthStatus/saveOrUpdate'),
      headers: {
        'Authorization': 'Bearer $token', // Bearer 토큰 사용
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(updatedData),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to update health data');
    }
  }
}

// Weight data class
class WeightData {
  WeightData(this.date, this.weight);
  final String date;
  final double weight;
}

// Blood sugar data class
class BloodSugarData {
  BloodSugarData(this.date, this.value);
  final String date;
  final double value;
}

// Blood pressure data class
class BloodPressureData {
  BloodPressureData(this.date, this.high, this.low);
  final String date;
  final int high;
  final int low;
}
