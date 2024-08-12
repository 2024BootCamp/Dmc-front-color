import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'calendar_page.dart';
import '../Screens/profile_page.dart';
import '../Services/RecordService.dart';

class FoodLogPage extends StatefulWidget {
  const FoodLogPage({super.key});

  @override
  FoodLogPageState createState() => FoodLogPageState();
}

class FoodLogPageState extends State<FoodLogPage> {
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _gramsController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final ImagePicker _picker = ImagePicker();
  final List<Map<String, dynamic>> _foodItems = []; // 음식 리스트

  final RecordService _recordService = RecordService(); // RecordService 인스턴스

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
        _foodItems.clear();
      });
      _clearLogsAtMidnight();
    });
  }

  // 이미지를 선택하는 함수
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        // 사용자가 사진을 선택하면 이를 화면에 보여주고 싶다면 추가 로직 필요
      });
    }
  }

  // 음식 아이템을 추가하는 함수
  void _addFoodItem() {
    setState(() {
      _foodItems.add({
        'food': _foodController.text,
        'grams': _gramsController.text,
      });
      _foodController.clear();
      _gramsController.clear();
    });
    print("현재 추가된 음식들: $_foodItems");
  }

  // 음식 아이템을 수정하는 함수
  void _editFoodItem(int index) {
    final item = _foodItems[index];
    _foodController.text = item['food'];
    _gramsController.text = item['grams'];
    _removeFoodItem(index);
  }

  // 음식 아이템을 제거하는 함수
  void _removeFoodItem(int index) {
    setState(() {
      _foodItems.removeAt(index);
    });
  }

  // 식단을 서버에 저장하는 함수 (기록 버튼 누를 때 호출)
  Future<void> _saveMealRecord() async {
    final Map<String, double> listMeal = {};

    for (var item in _foodItems) {
      String foodName = item['food'] as String;
      double grams = double.tryParse(item['grams'] ?? '0') ?? 0.0;
      listMeal[foodName] = grams;
    }

    print("전송될 listMeal: $listMeal");

    final mealRecord = {
      'date': _selectedDate,
      'image': '사진 없음', // 필요에 따라 변경
      'content': _commentController.text.isNotEmpty
          ? _commentController.text
          : '코멘트 없음',
      'listMeal': listMeal, // RecordRequest의 listMeal 필드에 맞춰 수정
    };

    try {
      await _recordService.addMealRecord(mealRecord);
      setState(() {
        _foodItems.clear(); // 저장 후 음식 리스트 초기화
        _commentController.clear(); // 코멘트 초기화
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('식단이 저장되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('식단 저장에 실패했습니다: $e')),
      );
    }
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _selectDate(context);
                  },
                  child: Text('날짜 선택: $_selectedDate',
                      style: const TextStyle(fontFamily: 'Quicksand')),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 102, 102, 102),
                    backgroundColor: const Color.fromARGB(255, 240, 240, 240),
                  ),
                ),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('사진 추가',
                      style: TextStyle(fontFamily: 'Quicksand')),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 102, 102, 102),
                    backgroundColor: const Color.fromARGB(255, 240, 240, 240),
                  ),
                ),
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
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
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
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_foodController.text.isNotEmpty &&
                        _gramsController.text.isNotEmpty) {
                      _addFoodItem(); // 음식 추가
                    }
                  },
                  child: const Text('추가',
                      style: TextStyle(fontFamily: 'Quicksand')),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 173, 216, 230),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_foodItems.isNotEmpty) ...[
              Expanded(
                child: ListView.builder(
                  itemCount: _foodItems.length,
                  itemBuilder: (context, index) {
                    final item = _foodItems[index];
                    return Dismissible(
                      key: Key(item['food']),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        _removeFoodItem(index);
                      },
                      background: Container(color: Colors.red),
                      child: ListTile(
                        title: Text('${item['food']}',
                            style: const TextStyle(fontFamily: 'Quicksand')),
                        subtitle: Text('그램: ${item['grams']}',
                            style: const TextStyle(fontFamily: 'Quicksand')),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _editFoodItem(index);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _removeFoodItem(index);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: '전체 식단에 대한 코멘트 입력',
                  hintStyle: const TextStyle(fontFamily: 'Quicksand'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.newline,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveMealRecord, // 식단 기록
                child: const Text('기록하기',
                    style: TextStyle(fontFamily: 'Quicksand')),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 173, 216, 230),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
