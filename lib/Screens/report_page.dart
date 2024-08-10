import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Services/RecordService.dart';
import '../Services/ReportService.dart';  // ReportService 추가
import 'profile_page.dart';

class ReportPage extends StatefulWidget {
  final int recordId;

  const ReportPage({super.key, required this.recordId});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  List<Map<String, dynamic>> _mealLogs = []; // 선택한 날짜의 모든 식단 기록 저장
  int? _appRating;
  final RecordService _recordService = RecordService();
  final ReportService _reportService = ReportService();  // ReportService 인스턴스 추가

  @override
  void initState() {
    super.initState();
    _fetchMealLogsByDate();
  }

  Future<void> _fetchMealLogsByDate() async {
    try {
      List<dynamic> logs = await _recordService.fetchMealLogsByDate(_selectedDate);
      setState(() {
        _mealLogs = logs.cast<Map<String, dynamic>>();
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

  Future<void> _evaluateAppRating(int recordId) async {
    try {
      double score = await _reportService.evaluateRecord(recordId);  // 서버에서 점수 가져오기
      setState(() {
        _appRating = score.round();  // 받아온 점수를 반영
      });
    } catch (e) {
      print('Error evaluating meal: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('식단 평가에 실패했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 전체 화면 배경색을 흰색으로 설정
      appBar: AppBar(
        title: const Text('리포트',
            style: TextStyle(color: Colors.white, fontFamily: 'Quicksand')),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 173, 216, 230),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () {
              _selectDate(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
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
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _selectDate(context);
                },
                child: Text('날짜 선택: $_selectedDate',
                    style: const TextStyle(
                        fontFamily: 'Quicksand', color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 173, 216, 230),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _mealLogs.isEmpty
                  ? const Center(child: Text('해당 날짜에 기록된 식단이 없습니다.'))
                  : ListView.builder(
                itemCount: _mealLogs.length,
                itemBuilder: (context, index) {
                  return _buildMealDetails(_mealLogs[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealDetails(Map<String, dynamic> mealLog) {
    return Card(
      color: Colors.white, // 카드 배경색을 흰색으로 설정
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        width: double.infinity, // 카드가 화면의 너비와 거의 같도록 설정
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('코멘트: ${mealLog['content'] ?? '코멘트 없음'}'),
            const SizedBox(height: 8),
            Text('음식 목록:', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...(mealLog['listFoods'] as Map<String, dynamic>).entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text('${entry.key}: ${entry.value}g'),
              );
            }).toList(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('식단 평가 점수'),
                ElevatedButton(
                  onPressed: () {
                    _evaluateAppRating(mealLog['recordId']);
                  },
                  child: const Text('평가하기',
                      style:
                      TextStyle(fontFamily: 'Quicksand', color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 173, 216, 230),
                  ),
                ),
              ],
            ),
            if (_appRating != null) ...[
              const SizedBox(height: 16),
              _buildAppRating(),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildAppRating() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        '평점 (5점 만점): $_appRating',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Quicksand',
        ),
      ),
    );
  }
}
