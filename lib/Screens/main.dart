import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../Screens/login_page.dart';

// 메인 함수, 애플리케이션 진입점
void main() async {
  // 한국 로케일 날짜 형식 초기화
  await initializeDateFormatting('ko_KR', null);
  // MyApp 위젯 실행
  runApp(const MyApp());
}

// 애플리케이션의 루트 위젯
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Title', // 앱 제목 설정 (선택 사항)
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // BottomNavigationBar의 테마 설정
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Color.fromARGB(255, 173, 216, 230), // 네비게이션 바 배경색
          selectedItemColor: Colors.white, // 선택된 아이템 색상
          unselectedItemColor: Colors.white70, // 선택되지 않은 아이템 색상
          selectedLabelStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ), // 선택된 라벨 스타일
          unselectedLabelStyle: TextStyle(
            color: Colors.white70,
          ), // 선택되지 않은 라벨 스타일
        ),
      ),
      home: LoginPage(), // 시작 페이지를 LoginPage로 설정
    );
  }
}
