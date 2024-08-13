import 'package:flutter/material.dart';
import '../Screens/home_page.dart';
import 'health_page.dart';
import 'food_log_page.dart';
import '../Screens/report_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0; // 현재 선택된 탭 인덱스
  int _selectedRecordId = 1; // 기본적으로 사용할 recordId를 설정하거나 필요에 따라 동적으로 변경

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      const HomePage(), // 홈 페이지
      const HealthPage(), // 내 건강 페이지
      const FoodLogPage(), // 기록 페이지
      ReportPage(recordId: _selectedRecordId), // 리포트 페이지
    ]);
  }

  Future<bool> _onWillPop() async {
    if (_currentIndex == 0) {
      // 홈 페이지에서 뒤로 가기 버튼을 누르면 앱 종료 또는 아무 동작도 하지 않음
      return false;
    } else {
      // 다른 페이지에서 뒤로 가기 버튼을 누르면 이전 페이지로 이동
      setState(() {
        _currentIndex = (_currentIndex - 1) % _pages.length;
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: _pages[_currentIndex], // 현재 선택된 페이지 표시
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex, // 현재 선택된 탭 인덱스 설정
          onTap: (index) {
            setState(() {
              _currentIndex = index; // 탭 선택 시 인덱스 변경
            });
          },
          backgroundColor: Colors.white, // 네비게이션 바 배경색 (기본 흰색)
          selectedItemColor: const Color.fromARGB(178, 16, 19, 19), // 선택된 아이템 색상
          unselectedItemColor:
          const Color.fromARGB(163, 24, 26, 27), // 선택되지 않은 아이템 색상
          selectedLabelStyle: const TextStyle(
              color: Color.fromARGB(255, 236, 76, 132),
              fontWeight: FontWeight.bold), // 선택된 라벨 스타일
          unselectedLabelStyle: const TextStyle(
              color: Color.fromARGB(255, 98, 188, 218)), // 선택되지 않은 라벨 스타일
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home), // 홈 아이콘
              label: '홈', // 홈 라벨
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite), // 내 건강 아이콘
              label: '내 건강', // 내 건강 라벨
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant), // 기록 아이콘
              label: '기록', // 기록 라벨
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insert_chart), // 리포트 아이콘
              label: '리포트', // 리포트 라벨
            ),
          ],
        ),
      ),
    );
  }
}
