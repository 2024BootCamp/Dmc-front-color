import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'calendar_page.dart';
import '../Screens/profile_page.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  _HealthPageState createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  String _selectedDate =
      DateFormat('yyyy-MM-dd').format(DateTime.now()); // 선택된 날짜
  final Map<String, Map<String, dynamic>> _healthData = {
    '혈압': {
      'high': 0,
      'low': 0,
      'data': <BloodPressureData>[],
    },
    '혈당': {
      'fasting': 0,
      'postMeal': 0,
      'dataFasting': <BloodSugarData>[],
      'dataPostMeal': <BloodSugarData>[],
    },
    '체중': {
      'value': 0.0,
      'data': <WeightData>[],
    },
  }; // 건강 데이터

  // 날짜 선택 함수
  Future<void> _selectDate(BuildContext context, Function onSave) async {
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
      onSave();
    }
  }

  // 혈압 입력 다이얼로그 표시
  void _showBloodPressureDialog(BuildContext context) {
    final TextEditingController bloodPressureHighController =
        TextEditingController();
    final TextEditingController bloodPressureLowController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '$_selectedDate 혈압 기록',
            style: const TextStyle(fontFamily: 'Quicksand'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bloodPressureHighController,
                decoration: const InputDecoration(
                  labelText: '혈압 (최고)',
                  hintText: 'mmHg',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: bloodPressureLowController,
                decoration: const InputDecoration(
                  labelText: '혈압 (최저)',
                  hintText: 'mmHg',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              child:
                  const Text('취소', style: TextStyle(fontFamily: 'Quicksand')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child:
                  const Text('저장', style: TextStyle(fontFamily: 'Quicksand')),
              onPressed: () {
                setState(() {
                  _healthData['혈압']!['high'] =
                      int.parse(bloodPressureHighController.text);
                  _healthData['혈압']!['low'] =
                      int.parse(bloodPressureLowController.text);
                  _healthData['혈압']!['data'].add(BloodPressureData(
                    _selectedDate,
                    int.parse(bloodPressureHighController.text),
                    int.parse(bloodPressureLowController.text),
                  ));
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // 혈당 입력 다이얼로그 표시
  void _showBloodSugarDialog(BuildContext context) {
    final TextEditingController bloodSugarFastingController =
        TextEditingController();
    final TextEditingController bloodSugarPostMealController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '$_selectedDate 혈당 기록',
            style: const TextStyle(fontFamily: 'Quicksand'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bloodSugarFastingController,
                decoration: const InputDecoration(
                  labelText: '혈당 (공복)',
                  hintText: 'mg/dL',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: bloodSugarPostMealController,
                decoration: const InputDecoration(
                  labelText: '혈당 (식후)',
                  hintText: 'mg/dL',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              child:
                  const Text('취소', style: TextStyle(fontFamily: 'Quicksand')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child:
                  const Text('저장', style: TextStyle(fontFamily: 'Quicksand')),
              onPressed: () {
                setState(() {
                  _healthData['혈당']!['fasting'] =
                      int.parse(bloodSugarFastingController.text);
                  _healthData['혈당']!['postMeal'] =
                      int.parse(bloodSugarPostMealController.text);
                  _healthData['혈당']!['dataFasting'].add(BloodSugarData(
                    _selectedDate,
                    int.parse(bloodSugarFastingController.text).toDouble(),
                  ));
                  _healthData['혈당']!['dataPostMeal'].add(BloodSugarData(
                    _selectedDate,
                    int.parse(bloodSugarPostMealController.text).toDouble(),
                  ));
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // 체중 입력 다이얼로그 표시
  void _showWeightDialog(BuildContext context) {
    final TextEditingController weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '$_selectedDate 체중 기록',
            style: const TextStyle(fontFamily: 'Quicksand'),
          ),
          content: TextField(
            controller: weightController,
            decoration: const InputDecoration(
              labelText: '체중',
              hintText: 'kg',
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              child:
                  const Text('취소', style: TextStyle(fontFamily: 'Quicksand')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child:
                  const Text('저장', style: TextStyle(fontFamily: 'Quicksand')),
              onPressed: () {
                setState(() {
                  _healthData['체중']!['value'] =
                      double.parse(weightController.text);
                  _healthData['체중']!['data'].add(WeightData(
                    _selectedDate,
                    double.parse(weightController.text),
                  ));
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  List<BloodPressureData> _getSortedBloodPressureData() {
    List<BloodPressureData> data = List.from(_healthData['혈압']!['data']);
    data.sort((a, b) => a.date.compareTo(b.date));
    return data;
  }

  List<BloodSugarData> _getSortedBloodSugarData(List<BloodSugarData> data) {
    data.sort((a, b) => a.date.compareTo(b.date));
    return data;
  }

  List<WeightData> _getSortedWeightData() {
    List<WeightData> data = List.from(_healthData['체중']!['data']);
    data.sort((a, b) => a.date.compareTo(b.date));
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR')
        .format(DateTime.now()); // 날짜 포맷팅
    final String formattedTime =
        DateFormat('HH:mm').format(DateTime.now()); // 시간 포맷팅

    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
      appBar: AppBar(
        title: const Text('내 건강',
            style: TextStyle(color: Colors.white, fontFamily: 'Quicksand')),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 173, 216, 230),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.white), //아이콘 색상 변경
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CalendarPage()), // 캘린더 페이지로 이동
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white), // 아이콘 색상 변경
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 날짜 및 시간 표시
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Quicksand',
                    ),
                  ),
                  Text(
                    formattedTime,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Quicksand',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 혈압 카드
              buildInfoCard(
                title: '혈압',
                onEdit: () {
                  _selectDate(context, () => _showBloodPressureDialog(context));
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '최고: ${_healthData['혈압']!['high']} / 최저: ${_healthData['혈압']!['low']} mmHg',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Quicksand',
                      ),
                    ),
                    SizedBox(
                      height: 150,
                      child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(),
                        series: <ChartSeries>[
                          LineSeries<BloodPressureData, String>(
                            dataSource: _getSortedBloodPressureData(),
                            xValueMapper: (BloodPressureData data, _) =>
                                data.date,
                            yValueMapper: (BloodPressureData data, _) =>
                                data.high,
                            name: '최고',
                          ),
                          LineSeries<BloodPressureData, String>(
                            dataSource: _getSortedBloodPressureData(),
                            xValueMapper: (BloodPressureData data, _) =>
                                data.date,
                            yValueMapper: (BloodPressureData data, _) =>
                                data.low,
                            name: '최저',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 체중 카드
              buildInfoCard(
                title: '체중',
                onEdit: () {
                  _selectDate(context, () => _showWeightDialog(context));
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_healthData['체중']!['value']} kg',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Quicksand',
                      ),
                    ),
                    SizedBox(
                      height: 150,
                      child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(),
                        series: <ChartSeries>[
                          LineSeries<WeightData, String>(
                            dataSource: _getSortedWeightData(),
                            xValueMapper: (WeightData data, _) => data.date,
                            yValueMapper: (WeightData data, _) => data.weight,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 혈당 카드
              buildInfoCard(
                title: '혈당',
                onEdit: () {
                  _selectDate(context, () => _showBloodSugarDialog(context));
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '공복: ${_healthData['혈당']!['fasting']} / 식후: ${_healthData['혈당']!['postMeal']} mg/dL',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Quicksand',
                      ),
                    ),
                    SizedBox(
                      height: 150,
                      child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(),
                        series: <ChartSeries>[
                          LineSeries<BloodSugarData, String>(
                            dataSource: _getSortedBloodSugarData(
                                _healthData['혈당']!['dataFasting']
                                    .cast<BloodSugarData>()),
                            xValueMapper: (BloodSugarData data, _) => data.date,
                            yValueMapper: (BloodSugarData data, _) =>
                                data.value,
                            name: '공복',
                          ),
                          LineSeries<BloodSugarData, String>(
                            dataSource: _getSortedBloodSugarData(
                                _healthData['혈당']!['dataPostMeal']
                                    .cast<BloodSugarData>()),
                            xValueMapper: (BloodSugarData data, _) => data.date,
                            yValueMapper: (BloodSugarData data, _) =>
                                data.value,
                            name: '식후',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 정보 카드 위젯 생성
  Widget buildInfoCard({
    required String title,
    required Widget child,
    required Function onEdit,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.white, // 카드 배경색을 흰색으로 설정
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카드 타이틀 및 수정 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Quicksand',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => onEdit(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

// 체중 데이터 클래스
class WeightData {
  WeightData(this.date, this.weight);
  final String date;
  final double weight;
}

// 혈당 데이터 클래스
class BloodSugarData {
  BloodSugarData(this.date, this.value);
  final String date;
  final double value;
}

// 혈압 데이터 클래스
class BloodPressureData {
  BloodPressureData(this.date, this.high, this.low);
  final String date;
  final int high;
  final int low;
}
