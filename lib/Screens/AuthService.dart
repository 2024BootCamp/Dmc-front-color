import 'dart:convert';
import 'package:http/http.dart' as http;

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

    if (response.statusCode == 200) {
      // You can handle token storage or other login state changes here
      return true;
    } else {
      // Handle errors
      return false;
    }
  }

  // Future<bool> signup(SingupModel sigunModel) async {
  //   final response = await http.post(
  //     Uri.parse('$baseUrl/account/register'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode(<String, String>{
  //       'userId': username,
  //       'password': password,
  //       'userName': userName,
  //       'gender': gender,
  //       'birthday': birthday,
  //       'height': height,
  //       'weight': weight,
  //       'email': email,
  //       'phone': phone,
  //       'address': address,
  //       'diseaseInfo': diseaseInfo,
  //     }),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     // You can handle token storage or other login state changes here
  //     return true;
  //   } else {
  //     // Handle errors
  //     return false;
  //   }
}
