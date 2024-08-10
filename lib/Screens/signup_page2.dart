import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // 추가
import 'dart:convert'; // 추가
import 'login_page.dart';
//221줄에 ip주소 변경
class SignupPage2 extends StatefulWidget {
  final String userId;
  final String userName;
  final String password;
  final String gender;
  final String birthday;
  final String phone;
  final String email;
  final String address;

  const SignupPage2({
    super.key,
    required this.userId,
    required this.userName,
    required this.password,
    required this.gender,
    required this.birthday,
    required this.phone,
    required this.email,
    required this.address,
  });

  @override
  _SignupPage2State createState() => _SignupPage2State();
}

class _SignupPage2State extends State<SignupPage2> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final List<String> _conditions = ["당뇨", "고혈압", "해당 사항 없음"];
  final List<bool> _selectedConditions = [false, false, false];
  int _activityLevel = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          '회원가입',
          style: TextStyle(color: Colors.white, fontFamily: 'Quicksand'),
        ),
        backgroundColor: const Color.fromARGB(255, 173, 216, 230),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            buildTextField("키", "cm", _heightController),
            buildTextField("몸무게", "kg", _weightController),
            const Text(
              "갖고 있는 질환",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontFamily: 'Quicksand'),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10.0,
              children: _conditions.asMap().entries.map((entry) {
                int idx = entry.key;
                String condition = entry.value;
                return ChoiceChip(
                  label: Text(condition,
                      style: const TextStyle(fontFamily: 'Quicksand')),
                  selected: _selectedConditions[idx],
                  onSelected: (bool selected) {
                    setState(() {
                      if (idx == 2 && selected) {
                        for (int i = 0; i < _selectedConditions.length; i++) {
                          _selectedConditions[i] = (i == 2);
                        }
                      } else {
                        _selectedConditions[idx] = selected;
                        if (selected) {
                          _selectedConditions[2] = false;
                        }
                      }
                    });
                  },
                  selectedColor: const Color.fromARGB(255, 173, 216, 230),
                  backgroundColor: Colors.grey[200],
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              "활동량",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontFamily: 'Quicksand'),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                int level = index + 1;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _activityLevel = level;
                    });
                  },
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: _activityLevel == level
                            ? const Color.fromARGB(255, 173, 216, 230)
                            : Colors.grey[300],
                        child: Text(
                          '$level',
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            color: _activityLevel == level
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getActivityLevelText(level),
                        style: const TextStyle(
                            fontSize: 12, fontFamily: 'Quicksand'),
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _completeSignup();
                },
                child: const Text('기록하기',
                    style: TextStyle(
                        fontFamily: 'Quicksand', color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 173, 216, 230),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
      String label, String unit, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontFamily: 'Quicksand'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: unit,
            hintStyle: const TextStyle(fontFamily: 'Quicksand'),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          style: const TextStyle(fontFamily: 'Quicksand'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _getActivityLevelText(int level) {
    switch (level) {
      case 1:
        return "아주 적다";
      case 2:
        return "적다";
      case 3:
        return "보통";
      case 4:
        return "많다";
      case 5:
        return "아주 많다";
      default:
        return "";
    }
  }

  Future<void> _completeSignup() async {
    final height = _heightController.text;
    final weight = _weightController.text;
    final conditions = _selectedConditions
        .asMap()
        .entries
        .where((entry) => entry.value)
        .map((entry) => _conditions[entry.key])
        .toList();
    final activityLevel = _activityLevel;

    final response = await http.post(
      Uri.parse('http://192.168.0.12:8081/account/register'), // 회원가입 API 엔드포인트
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userId': widget.userId,
        'userName': widget.userName,
        'password': widget.password,
        'gender': widget.gender,
        'birthday': widget.birthday,
        'phone': widget.phone,
        'email': widget.email,
        'address': widget.address,
        'height': height,
        'weight': weight,
        'conditions': conditions,
        'activityLevel': activityLevel,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('회원가입 성공!'),
          duration: const Duration(seconds: 2), // 메시지 표시 시간
        ),
      );

      // 일정 시간 후 로그인 페이지로 이동
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
        );
      });
    } else {
      // 오류 처리 로직 추가 (예: 서버 오류, 입력값 오류 등)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('회원가입 실패: ${response.reasonPhrase}'),
        ),
      );
    }
  }
}
