import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AuthService.dart'; // AuthService를 import합니다.
import '../Screens/login_page.dart';
import '../Screens/home_page.dart';

// 메인 함수, 애플리케이션 진입점
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 비동기 초기화
  await initializeDateFormatting('ko_KR', null);

  final authService = AuthService('http://192.168.56.1:8081'); // 서버의 base URL
  final token = await AuthService.getToken();
  final isAuthenticated = token != null;

  runApp(MyApp(isAuthenticated: isAuthenticated));
}

// 애플리케이션의 루트 위젯
class MyApp extends StatelessWidget {
  final bool isAuthenticated; // 인증 상태

  const MyApp({super.key, required this.isAuthenticated});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Title',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Color.fromARGB(255, 173, 216, 230),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          selectedLabelStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: TextStyle(
            color: Colors.white70,
          ),
        ),
      ),
      home: isAuthenticated ? HomePage() : LoginPage(), // 로그인 상태에 따라 페이지 결정
    );
  }
}
