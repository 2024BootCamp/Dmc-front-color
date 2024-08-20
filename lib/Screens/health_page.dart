import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../Services/HealthService.dart';
import '../Screens/profile_page.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  _HealthPageState createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  String _selectedDate =
      DateFormat('yyyy-MM-dd').format(DateTime.now()); // Selected date

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
  }; // Health data

  @override
  void initState() {
    super.initState();
    fetchHealthData();
  }

  // Fetch health data for the current user
  Future<void> fetchHealthData() async {
    try {
      final healthData = await HealthService.fetchHealthData();
      setState(() {
        for (var item in healthData) {
          final date = item['date']; // Assuming 'date' is returned as a string
          _healthData['혈압']!['high'] = item['highBlood'] ?? 0;
          _healthData['혈압']!['low'] = item['lowBlood'] ?? 0;
          _healthData['혈압']!['data'].add(BloodPressureData(
            date,
            item['highBlood'] ?? 0,
            item['lowBlood'] ?? 0,
          ));
          _healthData['혈당']!['fasting'] = item['emptySugar'] ?? 0;
          _healthData['혈당']!['postMeal'] = item['fullSugar'] ?? 0;
          _healthData['혈당']!['dataFasting'].add(BloodSugarData(
            date,
            (item['emptySugar'] ?? 0).toDouble(),
          ));
          _healthData['혈당']!['dataPostMeal'].add(BloodSugarData(
            date,
            (item['fullSugar'] ?? 0).toDouble(),
          ));
          _healthData['체중']!['value'] = (item['weigh'] ?? 0.0).toDouble();
          _healthData['체중']!['data'].add(WeightData(
            date,
            (item['weigh'] ?? 0.0).toDouble(),
          ));
        }
      });
    } catch (e) {
      throw Exception('Failed to load health data');
    }
  }

  // Update health data for the current user
  Future<void> updateHealthData() async {
    final String formattedDate =
        DateFormat('yyyy-MM-dd').format(DateTime.parse(_selectedDate));

    final updatedData = {
      'date': formattedDate,
      'highBlood': _healthData['혈압']!['high'],
      'lowBlood': _healthData['혈압']!['low'],
      'emptySugar': _healthData['혈당']!['fasting'],
      'fullSugar': _healthData['혈당']!['postMeal'],
      'weigh': _healthData['체중']!['value'],
    };

    try {
      await HealthService.updateHealthData(updatedData);
      print("Health data updated successfully");
    } catch (e) {
      throw Exception('Failed to update health data');
    }
  }

  // Date selection function
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

  // Show blood pressure input dialog
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
              onPressed: () async {
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
                await updateHealthData();
              },
            ),
          ],
        );
      },
    );
  }

  // Show blood sugar input dialog
  void _showBloodSugarDialog(BuildContext context) {
    final TextEditingController bloodSugarFastingController =
        TextEditingController();
    final TextEditingController bloodSugarPostMealController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$_selectedDate 혈당 기록',
              style: const TextStyle(fontFamily: 'Quicksand')),
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
              onPressed: () async {
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
                await updateHealthData();
              },
            ),
          ],
        );
      },
    );
  }

  // Show weight input dialog
  void _showWeightDialog(BuildContext context) {
    final TextEditingController weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$_selectedDate 체중 기록',
              style: const TextStyle(fontFamily: 'Quicksand')),
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
              onPressed: () async {
                setState(() {
                  _healthData['체중']!['value'] =
                      double.parse(weightController.text);
                  _healthData['체중']!['data'].add(WeightData(
                    _selectedDate,
                    double.parse(weightController.text),
                  ));
                });
                Navigator.of(context).pop();
                await updateHealthData();
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
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () async {
              await _selectDate(context, () async {
                await fetchHealthData(); // Fetch health data after selecting date
              });
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display date and time
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
              // Blood pressure card
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
              // Weight card
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
              // Blood sugar card
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

  // Info card widget
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
            // Card title and edit button
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
