import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Screens/calendar_page.dart';
import 'profile_page.dart';

//음식 추천 페이지
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now(); // 선택된 날짜를 저장
  final Map<String, List<Map<String, String>>> _mealData = {
    // 샘플 식단 데이터
    '2024-07-31': [
      {
        'calories': '1,709kcal',
        'sugar': '15g',
        'salt': '2g',
        'meal': '밥, 김치, 달걀말이, 된장국',
      },
      {
        'calories': '1,500kcal',
        'sugar': '10g',
        'salt': '1.5g',
        'meal': '밥, 무생채, 불고기, 미역국',
      },
      {
        'calories': '1,600kcal',
        'sugar': '18g',
        'salt': '2.2g',
        'meal': '밥, 생채, 참치캔, 김치찌개',
      },
      {
        'calories': '1,400kcal',
        'sugar': '12g',
        'salt': '1.8g',
        'meal': '밥, 멸치볶음, 계란후라이, 콩나물국',
      },
      {
        'calories': '1,550kcal',
        'sugar': '14g',
        'salt': '2.1g',
        'meal': '밥, 가지볶음, 두부김치, 순두부찌개',
      },
    ],
    '2024-08-01': [
      {
        'calories': '1,800kcal',
        'sugar': '20g',
        'salt': '2.5g',
        'meal': '밥, 샐러드, 치킨스테이크, 콩나물국',
      },
      {
        'calories': '1,750kcal',
        'sugar': '18g',
        'salt': '2g',
        'meal': '밥, 나물, 생선구이, 무국',
      },
    ],
    // 더 많은 데이터 추가 가능
  };

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
    }
  }

  // 식단 데이터 새로고침 함수
  Future<void> _refreshMeals() async {
    // 여기에 새로고침 시 데이터를 다시 불러오는 로직을 추가할 수 있습니다.
    setState(() {
      // 데이터 새로고침 로직
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    List<Map<String, String>> meals = _mealData[formattedDate] ?? [];

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
            icon: Icon(Icons.calendar_today,
                color: Colors.white), //캐린더 아이콘 흰색으로 바꿈
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CalendarPage()), // 캘린더 페이지로 이동
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white), //프로필 아이콘 흰색
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
                        backgroundColor:
                            const Color.fromARGB(255, 173, 216, 230),
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
                ...meals.map((meal) {
                  return buildMealCard(
                    meal['meal'] ?? '',
                    meal['calories'] ?? '',
                    meal['sugar'] ?? '',
                    meal['salt'] ?? '',
                  );
                }).toList(),
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
