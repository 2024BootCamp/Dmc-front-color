import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting
import 'signup_page2.dart';

class SignupPage1 extends StatefulWidget {
  const SignupPage1({super.key});

  @override
  _SignupPage1State createState() => _SignupPage1State();
}

class _SignupPage1State extends State<SignupPage1> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  bool _passwordsMatch = false;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordsMatch);
    _passwordConfirmController.addListener(_checkPasswordsMatch);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('회원가입', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 173, 216, 230),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: () {
              DateTime? parsedDate;
              try {
                parsedDate = DateFormat('yyyy-MM-dd')
                    .parseStrict(_birthdateController.text);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Invalid date format. Please enter in yyyy-MM-dd format.')),
                );
                return;
              }

              if (parsedDate != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignupPage2(
                      userId: _idController.text,
                      userName: _nameController.text,
                      password: _passwordController.text,
                      gender: _selectedGender == '여' ? 'F' : 'M',
                      birthday: _birthdateController.text,
                      phone: _phoneController.text,
                      email: _emailController.text,
                      address: _locationController.text,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            buildTextField("아이디", "아이디 입력", _idController, true),
            buildTextField("이메일", "이메일 입력(선택)", _emailController, false),
            buildTextField("비밀번호", "비밀번호 입력", _passwordController, true,
                obscureText: true),
            buildTextField(
                "비밀번호 재입력", "비밀번호 재입력", _passwordConfirmController, true,
                obscureText: true),
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
            buildTextField("유저 네임", "유저 네임 입력(필수)", _nameController, false),
            buildTextField("휴대폰 번호", "010 0000 0000", _phoneController, false),
            buildTextField(
                "생년월일", "생년월일 입력 (yyyy-MM-dd)", _birthdateController, false),
            buildGenderField(),
            buildTextField("사는 지역", "지역 입력", _locationController, false),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                DateTime? parsedDate;
                try {
                  parsedDate = DateFormat('yyyy-MM-dd')
                      .parseStrict(_birthdateController.text);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Invalid date format. Please enter in yyyy-MM-dd format.')),
                  );
                  return;
                }

                if (parsedDate != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignupPage2(
                        userId: _idController.text,
                        userName: _nameController.text,
                        password: _passwordController.text,
                        gender: _selectedGender == '여' ? 'F' : 'M',
                        birthday: _birthdateController.text,
                        phone: _phoneController.text,
                        email: _emailController.text,
                        address: _locationController.text,
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 173, 216, 230),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text('다음'),
            ),
          ],
        ),
      ),
    );
  }

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

  Widget buildTextField(String label, String placeholder,
      TextEditingController controller, bool isRequired,
      {bool obscureText = false}) {
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
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
