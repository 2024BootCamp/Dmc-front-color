import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'calendar_page.dart';
import '../Screens/profile_page.dart';
import '../Screens/report_page.dart';

class FoodLogPage extends StatefulWidget {
  const FoodLogPage({super.key});

  @override
  FoodLogPageState createState() => FoodLogPageState();
}

class FoodLogPageState extends State<FoodLogPage> {
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _gramsController = TextEditingController();
  String _selectedMeal = '아침';
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final ImagePicker _picker = ImagePicker();
  final List<String> _foodItems = [];
  Map<String, List<Map<String, dynamic>>> _mealLogs = {
    '아침': [],
    '점심': [],
    '저녁': [],
  };

  Map<String, List<Map<String, dynamic>>> get mealLogs => _mealLogs;

  @override
  void initState() {
    super.initState();
    _clearLogsAtMidnight();
  }

  // 자정에 기록을 초기화하는 함수
  void _clearLogsAtMidnight() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final duration = nextMidnight.difference(now);

    Future.delayed(duration, () {
      setState(() {
        _mealLogs = {
          '아침': [],
          '점심': [],
          '저녁': [],
        };
      });
      _clearLogsAtMidnight();
    });
  }

  // 이미지를 선택하는 함수
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _foodItems.add(pickedFile.path);
      });
    }
  }

  // 음식 아이템을 추가하는 함수
  void _addFoodItem(String food, String grams, [String? comment]) {
    setState(() {
      _mealLogs[_selectedMeal]?.add({
        'food': food,
        'comment': comment,
        'grams': grams,
        'date': _selectedDate,
        'imagePath': _foodItems.isNotEmpty ? _foodItems.last : null,
        'time': DateFormat('HH:mm:ss').format(DateTime.now()),
      });
      _foodController.clear();
      _commentController.clear();
      _gramsController.clear();
      _foodItems.clear();
    });
  }

  // 음식 아이템을 제거하는 함수
  void _removeFoodItem(String meal, int index) {
    setState(() {
      _mealLogs[meal]?.removeAt(index);
    });
  }

  // 날짜 선택하는 함수
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

  // 음식 아이템을 수정하는 함수
  void _editFoodItem(String meal, int index) {
    final item = _mealLogs[meal]![index];
    _foodController.text = item['food'];
    _gramsController.text = item['grams'];
    _commentController.text = item['comment'] ?? '';
    _removeFoodItem(meal, index);
  }

  // 음식 기록을 평가하는 함수 (백엔드 연동)
  Future<void> _evaluateMeals() async {
    try {
      final response = await http.post(
        Uri.parse('https://yourbackend.com/evaluate'), // 여기에 실제 백엔드 URL 입력
        headers: {'Content-Type': 'application/json'},
        body: json.encode(_mealLogs),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportPage(result: result),
          ),
        );
      } else {
        throw Exception('Failed to evaluate meals');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to evaluate meals: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
      appBar: AppBar(
        title: const Text('음식 기록',
            style: TextStyle(color: Colors.white, fontFamily: 'Quicksand')),
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
            //profile
            icon: Icon(Icons.account_circle, color: Colors.white), // 아이콘 색상 변경
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildMealButton('아침'),
                buildMealButton('점심'),
                buildMealButton('저녁'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _foodController,
                    decoration: InputDecoration(
                      hintText: '음식 입력',
                      hintStyle: const TextStyle(fontFamily: 'Quicksand'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: _pickImage,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _gramsController,
              decoration: InputDecoration(
                hintText: '그램 입력',
                hintStyle: const TextStyle(fontFamily: 'Quicksand'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            if (_foodItems.isNotEmpty) const SizedBox(height: 16),
            if (_foodItems.isNotEmpty)
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: '코멘트 입력',
                  hintStyle: const TextStyle(fontFamily: 'Quicksand'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.newline,
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_foodController.text.isNotEmpty &&
                        _gramsController.text.isNotEmpty &&
                        (_foodItems.isEmpty ||
                            _commentController.text.isNotEmpty)) {
                      _addFoodItem(
                          _foodController.text,
                          _gramsController.text,
                          _foodItems.isNotEmpty
                              ? _commentController.text
                              : null);
                    }
                  },
                  child: const Text('추가하기',
                      style: TextStyle(fontFamily: 'Quicksand')),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor:
                        Color.fromARGB(255, 173, 216, 230), // 버튼 텍스트 색상
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _evaluateMeals,
                  child: const Text('기록하기',
                      style: TextStyle(fontFamily: 'Quicksand')),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor:
                        Color.fromARGB(255, 173, 216, 230), // 버튼 텍스트 색상
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _selectDate(context);
              },
              child: Text('날짜 선택: $_selectedDate',
                  style: const TextStyle(fontFamily: 'Quicksand')),
              style: ElevatedButton.styleFrom(
                foregroundColor: Color.fromARGB(255, 102, 102, 102),
                backgroundColor: Color.fromARGB(255, 240, 240, 240), // 버튼 배경색
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _mealLogs[_selectedMeal]?.length ?? 0,
                itemBuilder: (context, index) {
                  final item = _mealLogs[_selectedMeal]![index];
                  return Dismissible(
                    key: Key(item['time']),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      _removeFoodItem(_selectedMeal, index);
                    },
                    background: Container(color: Colors.red),
                    child: ListTile(
                      title: Text('${item['food']}',
                          style: const TextStyle(fontFamily: 'Quicksand')),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item['comment'] != null)
                            Text(
                                '코멘트: ${item['comment']} (그램: ${item['grams']})',
                                style:
                                    const TextStyle(fontFamily: 'Quicksand')),
                          if (item['comment'] == null)
                            Text('그램: ${item['grams']}',
                                style:
                                    const TextStyle(fontFamily: 'Quicksand')),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _editFoodItem(_selectedMeal, index);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _removeFoodItem(_selectedMeal, index);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 식사 선택 버튼을 생성하는 함수
  Widget buildMealButton(String meal) {
    return ChoiceChip(
      label: Text(meal, style: const TextStyle(fontFamily: 'Quicksand')),
      selected: _selectedMeal == meal,
      onSelected: (selected) {
        setState(() {
          _selectedMeal = meal;
        });
      },
      selectedColor: Color.fromARGB(255, 173, 216, 230), // 선택된 버튼 배경색
      backgroundColor: Colors.white, // 선택되지 않은 버튼 배경색을 흰색으로 변경
      labelStyle: TextStyle(
        color: _selectedMeal == meal
            ? Colors.white
            : Color.fromARGB(255, 102, 102, 102), // 텍스트 색상
      ),
    );
  }
}
