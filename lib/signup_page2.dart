import 'package:flutter/material.dart';
import 'login_page.dart';

class SignupPage2 extends StatefulWidget {
  const SignupPage2({super.key});

  @override
  _SignupPage2State createState() => _SignupPage2State();
}

class _SignupPage2State extends State<SignupPage2> {
  // 입력 필드 컨트롤러
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final List<String> _conditions = ["당뇨", "고혈압", "해당 사항 없음"]; // 질환 목록
  final List<bool> _selectedConditions = [false, false, false]; // 선택된 질환 상태
  int _activityLevel = 3; // 활동량 선택 필드

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 뒤로가기 버튼
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // 아이콘 색상 흰색으로 설정
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          '회원가입',
          style: TextStyle(color: Colors.white, fontFamily: 'Quicksand'), // 제목 글자 색상 흰색으로 설정
        ),
        backgroundColor: const Color.fromARGB(255, 173, 216, 230), // AppBar 배경색 설정
      ),
      body: Container(
        color: Colors.white, // 전체 화면 배경색을 흰색으로 설정
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // 키 입력 필드
            buildTextField("키", "cm", _heightController),
            // 몸무게 입력 필드
            buildTextField("몸무게", "kg", _weightController),
            const Text(
              "갖고 있는 질환",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontFamily: 'Quicksand'),
            ),
            const SizedBox(height: 8),
            // 질환 선택 칩
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
                        // '해당 사항 없음'이 선택되면 다른 모든 선택 해제
                        for (int i = 0; i < _selectedConditions.length; i++) {
                          _selectedConditions[i] = (i == 2);
                        }
                      } else {
                        _selectedConditions[idx] = selected;
                        if (selected) {
                          _selectedConditions[2] =
                          false; // 다른 선택 시 '해당 사항 없음' 해제
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
            ), // 활동량 텍스트
            const SizedBox(height: 8),
            // 활동량 선택 버튼
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
            // 기록하기 버튼
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // 회원가입 완료 처리 로직
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                        (route) => false,
                  );
                },
                child: const Text('기록하기',
                    style: TextStyle(fontFamily: 'Quicksand', color: Colors.white)), // 버튼 텍스트 색상 흰색으로 설정
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 173, 216, 230), // 버튼 배경색을 요청하신 색상으로 설정
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 텍스트 필드 빌드 함수
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

  // 활동량 레벨 텍스트 반환 함수
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
}
