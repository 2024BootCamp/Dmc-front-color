import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'meal_service.dart'; // import meal_service.dart 추가
import 'profile_page.dart';
import '../Screens/calendar_page.dart';

// 음식 추천 페이지
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now(); // 선택된 날짜를 저장
  List<List<Map<String, dynamic>>> _meals = []; // 식단 데이터 저장 (각 식단이 List<Map<String, dynamic>> 형태로 저장됨)

  @override
  void initState() {
    super.initState();
    _fetchMealsByDate(); // 초기 로드 시 오늘의 추천 식단 가져오기
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
      });
      _fetchMealsByDate(); // 날짜 선택 후 식단 데이터 새로고침
    }
  }

  // 특정 날짜의 식단 데이터 가져오기 함수
  Future<void> _fetchMealsByDate() async {
    try {
      List<List<Map<String, dynamic>>> meals = await fetchMealsByDate(_selectedDate);
      setState(() {
        _meals = meals;
      });
    } catch (e) {
      print('Error fetching meals by date: $e');
    }
  }

  // 오늘의 추천 식단 데이터 가져오기 함수
  Future<void> _fetchTodayMeal() async {
    try {
      List<Map<String, dynamic>> meals = await fetchRecommendedMealForToday();
      setState(() {
        _meals = [meals];
      });
    } catch (e) {
      print('Error fetching today\'s meals: $e');
    }
  }

  // 문자열을 숫자로 변환하는 함수
  double parseStringToDouble(dynamic value) {
    if (value is String) {
      // 문자열에서 숫자 부분만 추출
      return double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
    }
    return (value as num?)?.toDouble() ?? 0.0;
  }

  // 영양 정보를 기준에 따라 변환하는 함수
  Map<String, double> calculateNutrient(Map<String, dynamic> meal, String type) {
    double multiplier = 1.0;

    switch (type) {
      case '밥':
        multiplier = 2.1; // 210g / 100g = 2.1
        break;
      case '국':
        multiplier = 1.5; // 150ml / 100ml = 1.5
        break;
      case '반찬1':
      case '반찬2':
        multiplier = 0.4; // 40g / 100g = 0.4
        break;
    }

    return {
      'calories': parseStringToDouble(meal['calories']) * multiplier,
      'sugar': parseStringToDouble(meal['sugar']) * multiplier,
      'salt': parseStringToDouble(meal['salt']) * multiplier,
    };
  }

  @override
  Widget build(BuildContext context) {
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
            icon: Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalendarPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchMealsByDate,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 날짜 선택 버튼
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
                if (_meals.isNotEmpty)
                  ..._meals.asMap().entries.map((entry) {
                    return buildMealCard(entry.value);
                  }).toList(),
                // 추천 식단 버튼을 항상 보이도록 설정
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await _fetchTodayMeal(); // 추천 버튼 클릭 시 오늘의 추천 식단 가져오기
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 173, 216, 230),
                  ),
                  child: const Text(
                    '오늘의 추천 식단',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Quicksand',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 식사 카드 위젯 생성 (한 식단을 하나의 카드로 표시)
  Widget buildMealCard(List<Map<String, dynamic>> mealList) {
    final labels = ['밥', '국', '반찬1', '반찬2'];

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
        children: mealList.asMap().entries.map((entry) {
          int idx = entry.key;
          Map<String, dynamic> meal = entry.value;

          var nutrients = calculateNutrient(meal, labels[idx]);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${labels[idx]}: ${meal['meal']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Quicksand',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '칼로리: ${nutrients['calories']?.toStringAsFixed(1) ?? '0.0'} kcal',
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Quicksand',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '당분: ${nutrients['sugar']?.toStringAsFixed(2) ?? '0.00'} g',
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Quicksand',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '염분: ${nutrients['salt']?.toStringAsFixed(2) ?? '0.00'} g',
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Quicksand',
                  ),
                ),
                if (idx < mealList.length - 1) const Divider(color: Colors.grey), // 각 음식 사이에 구분선 추가
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
