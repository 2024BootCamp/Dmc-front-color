import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data'; // 이미지 데이터를 메모리에 저장하기 위해 필요
import 'dart:io' if (dart.library.html) 'dart:html'; // 웹과 모바일 구분
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
  final List<Map<String, dynamic>> _foodItems = [];
  Uint8List? _selectedImageBytes;
  List<Map<String, dynamic>> _mealLogs = [];

  final RecordService _recordService = RecordService();

  @override
  void initState() {
    super.initState();
    _fetchMealLogsByDate();
    _clearLogsAtMidnight();
  }

  void _clearLogsAtMidnight() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final duration = nextMidnight.difference(now);

    Future.delayed(duration, () {
      setState(() {
        _foodItems.clear();
        _selectedImageBytes = null;
      });
      _clearLogsAtMidnight();
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      if (pickedFile.path.endsWith('.jpg') || pickedFile.path.endsWith('.png')) {
        final imageBytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImageBytes = imageBytes;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('사진이 추가되었습니다.')),
          );
        });
      } else {
        setState(() {
          _selectedImageBytes = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('지원되지 않는 이미지 형식입니다.')),
        );
      }
    }
  }

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

  void _editFoodItem(int index) {
    final item = _foodItems[index];
    _foodController.text = item['food'];
    _gramsController.text = item['grams'];
    _removeFoodItem(index);
  }

  void _removeFoodItem(int index) {
    setState(() {
      _foodItems.removeAt(index);
    });
  }

  Future<void> _saveMealRecord() async {
    final Map<String, double> listMeal = {};

    for (var item in _foodItems) {
      String foodName = item['food'] as String;
      double grams = double.tryParse(item['grams'] ?? '0') ?? 0.0;
      listMeal[foodName] = grams;
    }

    final mealRecord = {
      'date': _selectedDate,
      'image': _selectedImageBytes != null ? '이미지 있음' : '사진 없음',
      'content': _commentController.text.isNotEmpty
          ? _commentController.text
          : '코멘트 없음',
      'listMeal': listMeal,
    };

    try {
      await _recordService.addMealRecord(mealRecord);
      setState(() {
        _foodItems.clear();
        _commentController.clear();
        _selectedImageBytes = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('식단이 저장되었습니다.')),
      );
      _fetchMealLogsByDate();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('식단 저장에 실패했습니다: $e')),
      );
    }
  }

  Future<void> _fetchMealLogsByDate() async {
    try {
      List<dynamic> logs = await _recordService.fetchMealLogsByDate(_selectedDate);
      setState(() {
        _mealLogs = List<Map<String, dynamic>>.from(logs.map((log) {
          Map<String, dynamic> logMap = Map<String, dynamic>.from(log);
          if (logMap['listFoods'] != null && logMap['listFoods'] is Map) {
            logMap['listFoods'] = Map<String, double>.from(logMap['listFoods']);
          }
          return logMap;
        }));
      });
    } catch (e) {
      print('Error fetching meal logs: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('식단 기록을 불러오는 데 실패했습니다: $e')),
      );
    }
  }

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
      _fetchMealLogsByDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            if (_selectedImageBytes != null)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: Image.memory(_selectedImageBytes!, fit: BoxFit.cover),
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
                      _addFoodItem();
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
                onPressed: _saveMealRecord,
                child: const Text('기록하기',
                    style: TextStyle(fontFamily: 'Quicksand')),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 173, 216, 230),
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (_mealLogs.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '기록된 식단',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Quicksand',
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _mealLogs.length,
                  itemBuilder: (context, index) {
                    final mealLog = _mealLogs[index];
                    final listFoods = mealLog['listFoods'] as Map<String, double>;

                    return Card(
                      elevation: 2.0,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      color: Colors.white, // 카드의 배경색을 흰색으로 설정
                      child: ListTile(
                        title: Text(
                          '코멘트: ${mealLog['content']}',
                          style: const TextStyle(fontFamily: 'Quicksand'),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: listFoods.entries.map((entry) {
                            return Text(
                              '${entry.key}: ${entry.value}g',
                              style: const TextStyle(fontFamily: 'Quicksand'),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
