import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'login_page.dart';
import '../Services/AuthService.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String nickname = "알 수 없음"; // 닉네임
  String birthday = "지정되지 않음"; // 생년월일
  String gender = "지정되지 않음"; // 성별
  String email = "지정되지 않음"; // 이메일
  String? _profileImagePath = 'assets/profile_image.png'; // 프로필 이미지 경로
  final ImagePicker _picker = ImagePicker(); // 이미지 선택기

  @override
  void initState() {
    super.initState();
    fetchProfile(); // 페이지 로드 시 프로필 정보를 가져옵니다.
  }

  // Spring Boot API 호출
  Future<void> fetchProfile() async {
    final token = await AuthService.getToken();

    if (token == null) {
      print("토큰이 없어 사용자가 로그아웃되었습니다.");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://192.168.56.1:8081/account/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // UTF-8로 데이터를 디코딩합니다.
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        print(data); // 서버 응답을 출력하여 확인
        setState(() {
          nickname = data['userId'] ?? '알 수 없음';
          birthday = data['birthday'] ?? '지정되지 않음';
          gender = data['gender'] ?? '지정되지 않음';
          if (gender == "F") {
            gender = "남성";
          } else {
            gender = "여성";
          }
          email = data['email'] ?? '지정되지 않음';
          _profileImagePath =
              data['profileImagePath'] ?? 'assets/profile_image.png';
        });
      } else {
        print('프로필 로드 실패: ${response.statusCode}');
        throw Exception('프로필을 불러오는 데 실패했습니다.');
      }
    } catch (e) {
      print('프로필을 가져오는 중 오류 발생: $e');
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
  final AuthService _authService = AuthService();
  Future<void> _logout() async {
    try {
      final success = await _authService.logout(); // 로그아웃 API 호출

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그아웃에 실패했습니다. 다시 시도해주세요.'),
          ),
        );
      }
    } catch (e) {
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
        ),
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
                        ? (_profileImagePath!.startsWith('http')
                                ? NetworkImage(_profileImagePath!)
                                : FileImage(File(_profileImagePath!)))
                            as ImageProvider
                        : const AssetImage('assets/profile_image.png'),
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
            // 프로필 필드 (유저네임, 생년월일, 성별, 이메일)
            buildProfileField("유저네임", nickname),
            buildProfileField("생년월일", birthday),
            buildProfileField("성별", gender),
            buildProfileField("이메일", email),
            const SizedBox(height: 16),
            // 로그아웃 버튼
            ElevatedButton(
              onPressed: () async {
                await _logout(); // 로그아웃 처리
              }, // 매미매미 은혜은혜 바보 멍청이 못생긴 똥개 맨날 뚱뚱이라고 놀리고 시러! 미워!
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color.fromARGB(255, 173, 216, 230), // 앱바와 동일한 색상
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: 20, horizontal: 32), // 버튼의 수직 및 수평 여백을 늘림
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
  Widget buildProfileField(String label, String value) {
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
          color: Colors.white,
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
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}
