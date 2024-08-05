import 'package:flutter/material.dart';
import 'signup_page2.dart';

class SignupPage1 extends StatefulWidget {
  const SignupPage1({super.key});

  @override
  _SignupPage1State createState() => _SignupPage1State();
}

class _SignupPage1State extends State<SignupPage1> {
  // 입력 필드 컨트롤러
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _locationController =
      TextEditingController(); // 지역 필드 컨트롤러

  // 성별 선택 변수
  String? _selectedGender;
  bool _passwordsMatch = false; // 비밀번호 일치 여부

  void _checkPasswordsMatch() {
    setState(() {
      _passwordsMatch =
          _passwordController.text == _passwordConfirmController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.white), // 뒤로가기 아이콘 색상 흰색으로 설정
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          '회원가입',
          style: TextStyle(color: Colors.white), // AppBar 제목 글자 색상 흰색으로 설정
        ),
        backgroundColor:
            const Color.fromARGB(255, 173, 216, 230), // AppBar 배경색 설정
        actions: [
          // 현재 페이지에서 다음 페이지로 이동 버튼
          IconButton(
            icon: const Icon(Icons.arrow_forward,
                color: Colors.white), // 아이콘 색상 흰색으로 설정
            onPressed: () {
              if (_selectedGender == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('성별을 선택하세요.')),
                );
                return;
              }
              if (!_passwordsMatch) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignupPage2()),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white, // 전체 화면 배경색을 흰색으로 설정
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // 아이디 입력 필드
            buildTextField("아이디", "아이디 입력", _idController, true),
            // 이메일 입력 필드 (선택)
            buildTextField("이메일", "이메일 입력(선택)", _emailController, false),
            // 비밀번호 입력 필드
            buildTextField("비밀번호", "비밀번호 입력", _passwordController, true,
                obscureText: true),
            // 비밀번호 재입력 필드
            buildTextField(
                "비밀번호 재입력", "비밀번호 재입력", _passwordConfirmController, true,
                obscureText: true, onChanged: _checkPasswordsMatch),
            // 비밀번호 일치 여부 아이콘
            if (_passwordController.text.isNotEmpty &&
                _passwordConfirmController.text.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    _passwordsMatch ? Icons.check : Icons.close,
                    color: _passwordsMatch ? Colors.green : Colors.red,
                  ),
                ],
              ),
            // 닉네임 입력 필드
            buildTextField("유저 네임", "유저 네임 입력(필수)", _nameController, false),
            // 휴대폰 번호 입력 필드
            buildTextField("휴대폰 번호", "010 0000 0000", _phoneController, false),
            // 생년월일 입력 필드
            buildTextField("생년월일", "생년월일 입력", _birthdateController, false),
            // 성별 입력 필드
            buildGenderField(),
            // 사는 지역 입력 필드
            buildTextField("사는 지역", "지역 입력", _locationController, false),
            const SizedBox(height: 24),
            // 다음 버튼
            ElevatedButton(
              onPressed: () {
                if (_selectedGender == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('성별을 선택하세요.')),
                  );
                  return;
                }
                if (!_passwordsMatch) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
                  );
                  return;
                }
                // 다음 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupPage2()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(
                    255, 173, 216, 230), // 버튼 배경색을 요청하신 색상으로 설정
                foregroundColor: Colors.white, // 버튼 텍스트 색상을 흰색으로 설정
                padding: const EdgeInsets.symmetric(vertical: 16.0), // 버튼 패딩 조정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // 버튼 모서리 둥글게
                ),
              ),
              child: const Text('다음'),
            ),
          ],
        ),
      ),
    );
  }

  // 성별 입력 필드
  Widget buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '성별',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Quicksand',
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(
                color: Colors.red,
                fontFamily: 'Quicksand',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ListTile(
                title: const Text('남자'),
                leading: Radio<String>(
                  value: '남자',
                  groupValue: _selectedGender,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                title: const Text('여자'),
                leading: Radio<String>(
                  value: '여자',
                  groupValue: _selectedGender,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // 텍스트 필드 빌드 함수
  Widget buildTextField(String label, String placeholder,
      TextEditingController controller, bool isRequired,
      {bool obscureText = false, Function()? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Quicksand',
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: 'Quicksand',
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(fontFamily: 'Quicksand'),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          obscureText: obscureText,
          style: const TextStyle(fontFamily: 'Quicksand'),
          onChanged: (text) {
            if (onChanged != null) {
              onChanged();
            }
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
