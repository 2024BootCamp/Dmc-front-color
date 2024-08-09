import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/login_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/AuthService.dart'; // AuthService를 import 합니다.

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String nickname = "매미매미"; // 닉네임
  String birthdate = "2002년 10월 28일"; // 생년월일
  String gender = "여성"; // 성별
  final ImagePicker _picker = ImagePicker(); // 이미지 선택기
  String? _profileImagePath = 'assets/profile_image.png'; // 프로필 이미지 경로

  // 날짜 선택 함수
  Future<void> _selectDate(BuildContext context, Function onSave) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      onSave(picked);
    }
  }

  // 프로필 이미지 선택 함수
  Future<void> _pickProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImagePath = pickedFile.path;
      });
    }
  }

  // 로그아웃 함수
  Future<void> _logout() async {
    try {
      final authService =
          AuthService('http://192.168.56.1:8081/account/logout');
      await AuthService.clearToken();
      // 로그아웃 후 적절한 화면으로 리디렉션
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('로그아웃 실패: ${e.toString()}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          '마이페이지',
          style: TextStyle(fontFamily: 'Quicksand', color: Colors.white),
        ), // 마이페이지 글자 흰색
        backgroundColor: const Color.fromARGB(255, 173, 216, 230), // 앱바 색상 설정
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  // 프로필 이미지
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: _profileImagePath != null
                        ? FileImage(File(_profileImagePath!))
                        : const AssetImage('assets/profile_image.png')
                            as ImageProvider,
                  ),
                  // 프로필 이미지 변경 아이콘
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickProfileImage,
                      child: const CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 프로필 필드 (닉네임, 생년월일, 성별)
            buildProfileField("이름 또는 닉네임", nickname, (newValue) {
              setState(() {
                nickname = newValue;
              });
            }),
            buildProfileField("생년월일", birthdate, (newValue) {
              setState(() {
                birthdate = newValue;
              });
            }),
            buildProfileField("성별", gender, (newValue) {
              setState(() {
                gender = newValue;
              });
            }),
            const SizedBox(height: 16),
            // 로그아웃 버튼
            ElevatedButton(
              onPressed: () async {
                await _logout(); // 로그아웃 처리
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 173, 216, 230), // 앱바와 동일한 색상
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32), // 버튼의 수직 및 수평 여백을 늘림
              ),
              child: const Text(
                '로그아웃',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Quicksand',
                  fontSize: 18, // 폰트 크기를 약간 늘림
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 프로필 필드 위젯 생성
  Widget buildProfileField(
      String label, String value, Function(String) onEdit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontFamily: 'Quicksand',
          ),
        ),
        const SizedBox(height: 4),
        Container(
          color: Colors.white, // 필드 배경색을 흰색으로 설정
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Quicksand',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _showEditDialog(context, label, value, onEdit); // 수정 다이얼로그 표시
                },
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }

  // 수정 다이얼로그 표시 함수
  void _showEditDialog(BuildContext context, String label, String value,
      Function(String) onEdit) {
    TextEditingController controller = TextEditingController(text: value);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$label 수정',
              style: const TextStyle(fontFamily: 'Quicksand')),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: label,
              hintStyle: const TextStyle(fontFamily: 'Quicksand'),
            ),
            style: const TextStyle(fontFamily: 'Quicksand'),
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
                onEdit(controller.text); // 변경된 값 저장
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
