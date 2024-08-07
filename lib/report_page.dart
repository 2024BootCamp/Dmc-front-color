import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'profile_page.dart';

class ReportPage extends StatefulWidget {
  final Map<String, dynamic>? result;

  const ReportPage({super.key, required this.result});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String _selectedMeal = '아침';
  Map<String, List<Map<String, dynamic>>> _mealLogs = {
    '아침': [],
    '점심': [],
    '저녁': [],
  };
  int? _appRating;

  @override
  void initState() {
    super.initState();
    // 샘플 데이터 초기화
    _mealLogs = {
      '아침': [
        {
          'food': '밥',
          'grams': '200',
          'calories': '300',
          'carbs': '70',
          'fat': '1',
          'protein': '6',
          'sugar': '0',
          'salt': '1',
          'comment': '아침밥',
          'imagePath': null
        },
      ],
      '점심': [
        {
          'food': '스테이크',
          'grams': '250',
          'calories': '400',
          'carbs': '5',
          'fat': '30',
          'protein': '25',
          'sugar': '0',
          'salt': '2',
          'comment': '점심스테이크',
          'imagePath': null
        },
      ],
      '저녁': [
        {
          'food': '샐러드',
          'grams': '150',
          'calories': '150',
          'carbs': '10',
          'fat': '10',
          'protein': '5',
          'sugar': '5',
          'salt': '0.5',
          'comment': '저녁샐러드',
          'imagePath': null
        },
      ],
    };
  }

  // 날짜 선택 함수
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // 총 칼로리 계산 함수
  int _calculateTotalCalories() {
    return _mealLogs[_selectedMeal]?.map((meal) {
      return int.tryParse(meal['calories']?.toString() ?? '0') ?? 0;
    }).fold(0, (a, b) => a! + b) ??
        0;
  }

  // 영양소 합계 계산 함수
  Map<String, int> _calculateNutrients() {
    final nutrients = {'탄수화물': 0, '지방': 0, '단백질': 0, '당': 0, '염분': 0};
    for (var meal in _mealLogs[_selectedMeal] ?? []) {
      nutrients.forEach((key, _) {
        nutrients[key] = (nutrients[key] ?? 0) +
            (int.tryParse(meal[key]?.toString() ?? '0') ?? 0);
      });
    }
    return nutrients;
  }

  // 식단 평가 점수 계산 함수
  void _evaluateAppRating() {
    // 데모를 위한 4점으로 설정
    setState(() {
      _appRating = 4;
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalCalories = _calculateTotalCalories();
    final nutrients = _calculateNutrients();

    return Scaffold(
      appBar: AppBar(
        title: const Text('리포트',
            style: TextStyle(color: Colors.white, fontFamily: 'Quicksand')),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 173, 216, 230), // AppBar 배경색 설정
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white), // 아이콘 색상 흰색으로 설정
            onPressed: () {
              _selectDate(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white), // 아이콘 색상 흰색으로 설정
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white, // 전체 화면 배경색을 흰색으로 설정
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _selectDate(context);
                },
                child: Text('날짜 선택: $_selectedDate',
                    style: const TextStyle(fontFamily: 'Quicksand', color: Colors.white)), // 버튼 텍스트 색상 흰색으로 설정
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color.fromARGB(255, 173, 216, 230), // 버튼 배경색을 요청하신 색상으로 설정
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildMealTypeButtons(),
            const SizedBox(height: 16),
            _buildSectionHeader('총 섭취 영양소'),
            _buildNutrientsInfo(totalCalories, nutrients),
            const SizedBox(height: 16),
            _buildMealBox(_selectedMeal),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader('식단 평가 점수'),
                ElevatedButton(
                  onPressed: _evaluateAppRating,
                  child: const Text('평가하기',
                      style: TextStyle(fontFamily: 'Quicksand', color: Colors.white)), // 버튼 텍스트 색상 흰색으로 설정
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 173, 216, 230), // 버튼 배경색을 요청하신 색상으로 설정
                  ),
                ),
              ],
            ),
            if (_appRating != null) ...[
              const SizedBox(height: 16),
              _buildAppRating(_appRating!),
            ]
          ],
        ),
      ),
    );
  }

  // 식사 종류 선택 버튼 생성 함수
  Widget _buildMealTypeButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ['아침', '점심', '저녁'].map((meal) {
        return ChoiceChip(
          label: Text(meal, style: const TextStyle(fontFamily: 'Quicksand')),
          selected: _selectedMeal == meal,
          onSelected: (selected) {
            setState(() {
              _selectedMeal = meal;
            });
          },
          selectedColor: const Color.fromARGB(255, 173, 216, 230), // 선택된 버튼 배경색
          backgroundColor:
          const Color.fromARGB(255, 240, 240, 240), // 선택되지 않은 버튼 배경색
          labelStyle: TextStyle(
            color: _selectedMeal == meal
                ? Colors.white
                : const Color.fromARGB(255, 102, 102, 102), // 텍스트 색상
          ),
        );
      }).toList(),
    );
  }

  // 섹션 헤더 생성 함수
  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Quicksand',
        ),
      ),
    );
  }

  // 영양 정보 표시 위젯 생성 함수
  Widget _buildNutrientsInfo(int totalCalories, Map<String, int> nutrients) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '총 칼로리: $totalCalories kcal',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Quicksand',
            ),
          ),
          ...nutrients.entries.map((entry) {
            return Text(
              '${entry.key}: ${entry.value}g',
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Quicksand',
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // 식사 기록 박스 생성 함수
  Widget _buildMealBox(String mealType) {
    final logs = _mealLogs[mealType] ?? [];
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: logs.map((meal) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${meal['food']} (${meal['grams']}g)',
                          style: const TextStyle(fontFamily: 'Quicksand'),
                        ),
                        Text(
                          '칼로리: ${meal['calories']} kcal\n'
                              '탄수화물: ${meal['carbs']}g 지방: ${meal['fat']}g 단백질: ${meal['protein']}g\n'
                              '당: ${meal['sugar']}g 염분: ${meal['salt']}g\n'
                              '코멘트: ${meal['comment']}',
                          style: const TextStyle(fontFamily: 'Quicksand'),
                        ),
                      ],
                    ),
                  ),
                  if (meal['imagePath'] != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Image.file(
                        File(meal['imagePath']),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ),
              const Divider(),
            ],
          );
        }).toList(),
      ),
    );
  }

  // 식단 평가 점수 표시 함수
  Widget _buildAppRating(int rating) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        '평점 (5점 만점): $rating',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Quicksand',
        ),
      ),
    );
  }
}
