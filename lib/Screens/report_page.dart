import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Services/RecordService.dart';
import '../Services/ReportService.dart';
import 'profile_page.dart';

class ReportPage extends StatefulWidget {
  final int recordId;

  const ReportPage({super.key, required this.recordId});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  List<Map<String, dynamic>> _mealLogs = [];
  final RecordService _recordService = RecordService();
  final ReportService _reportService = ReportService();

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

  Future<void> _evaluateAppRating(int recordId, Function(double) onRatingReceived) async {
    try {
      double score = await _reportService.evaluateRecord(recordId);
      onRatingReceived(score);
    } catch (e) {
      print('Error evaluating meal: $e');
      // null이거나 오류가 발생하면 60점으로 처리
      onRatingReceived(60);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  return MealDetailCard(
                    mealLog: _mealLogs[index],
                    evaluateAppRating: _evaluateAppRating,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MealDetailCard extends StatefulWidget {
  final Map<String, dynamic> mealLog;
  final Future<void> Function(int, Function(double)) evaluateAppRating;

  const MealDetailCard({
    Key? key,
    required this.mealLog,
    required this.evaluateAppRating,
  }) : super(key: key);

  @override
  _MealDetailCardState createState() => _MealDetailCardState();
}

class _MealDetailCardState extends State<MealDetailCard> {
  double? _appRating;

  @override
  Widget build(BuildContext context) {
    final listFoods = (widget.mealLog['listFoods'] as Map?)?.cast<String, dynamic>() ?? {};
    final content = widget.mealLog['content'] ?? '코멘트 없음';

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('코멘트: $content'),
            const SizedBox(height: 8),
            const Text('음식 목록:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...listFoods.entries.map((entry) {
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
                    widget.evaluateAppRating(widget.mealLog['recordId'], (score) {
                      setState(() {
                        _appRating = score == null ? 0 : score; // null이면 0점
                      });
                    });
                  },
                  child: const Text('평가하기',
                      style: TextStyle(fontFamily: 'Quicksand', color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 173, 216, 230),
                  ),
                ),
              ],
            ),
            if (_appRating != null) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '평점 (5점 만점): ${_appRating!.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Quicksand',
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
