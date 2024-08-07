// lib/home_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/service.dart'; // ApiService를 import
import 'calendar_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now(); // 선택된 날짜를 저장
  final ApiService apiService = ApiService('https://localhost:8081'); // API 서비스 인스턴스 생성
  Future<List<Map<String, dynamic>>>? _mealData; // 비동기 데이터 저장

  @override
  void initState() {
    super.initState();
    _fetchMeals(); // 초기 데이터 로드
  }

  // 날짜 선택 함수
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ); // 날짜 선택기 표시
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked; // 선택된 날짜 설정
        _fetchMeals(); // 날짜 변경 시 데이터 새로고침
      });
    }
  }

  // 식단 데이터 가져오기
  Future<void> _fetchMeals() async {
    setState(() {
      _mealData = apiService.getRecommendCountByDate(_selectedDate);
    });
  }

  // 식단 데이터 새로고침 함수
  Future<void> _refreshMeals() async {
    await _fetchMeals(); // 데이터를 다시 불러오는 로직
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
      appBar: AppBar(
        title: const Text('추천 식단',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Quicksand',
            )), // 앱바 타이틀
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 173, 216, 230),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.white), // 캘린더 아이콘 흰색으로 바꿈
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CalendarPage()), // 캘린더 페이지로 이동
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white), // 프로필 아이콘 흰색
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ProfilePage()), // 프로필 페이지로 이동
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshMeals,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 날짜 선택 버튼 및 새로 추천 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${DateFormat('yyyy년 MM월 dd일').format(_selectedDate)}의 맞춤 식단',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Quicksand',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _selectDate(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 173, 216, 230),
                      ),
                      child: const Text(
                        '날짜 선택',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Quicksand',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 식단 정보
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _mealData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      final meals = snapshot.data!;
                      return Column(
                        children: meals.map((meal) {
                          return buildMealCard(
                            meal['meal'] ?? '',
                            meal['calories'] ?? '',
                            meal['sugar'] ?? '',
                            meal['salt'] ?? '',
                          );
                        }).toList(),
                      );
                    } else {
                      return Center(child: Text('No recommendations available'));
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 식사 카드 위젯 생성
  Widget buildMealCard(
      String mealInfo, String calories, String sugar, String salt) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white, // 카드 배경색을 흰색으로 설정
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2), // 카드 그림자 위치
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '식단',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Quicksand',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mealInfo,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Quicksand',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '칼로리: $calories, 당: $sugar, 염분: $salt',
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Quicksand',
            ),
          ),
        ],
      ),
    );
  }
}
