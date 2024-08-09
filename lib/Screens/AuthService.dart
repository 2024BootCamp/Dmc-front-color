import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/SignupModel.dart';

class AuthService {
  final String baseUrl;

  AuthService(this.baseUrl);

  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/account/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'userId': username,
        'password': password,
      }),
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final String token = responseBody['jwtToken'];
        print("Token received: $token");

        if (token.isNotEmpty) {
          await saveToken(token);
          print("Token saved successfully");
          return true;
        }
      } catch (e) {
        print("Error parsing JSON: $e");
      }
    } else {
      print("Login failed with status: ${response.statusCode}");
    }
    return false;
  }

  Future<bool> registerUser(SignupModel signupModel) async {
    final url = Uri.parse('$baseUrl/account/register');
    final body = jsonEncode(signupModel.toJson());

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Registration failed with status: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');

  }
}
