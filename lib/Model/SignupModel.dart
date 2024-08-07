import 'dart:convert';

// Function to convert JSON string to SignupModel
SignupModel signupModelJson(String str) =>
    SignupModel.fromJson(json.decode(str));

// Function to convert SignupModel to JSON string
String signupModelToJson(SignupModel data) => json.encode(data.toJson());

class SignupModel {
  String userId;
  String password;
  String userName;
  String gender; // Changed from Character to String
  String birthday; // Changed from LocalDate to String
  String diseaseInfo;
  double height; // Changed from Double to double
  double weight; // Changed from Double to double
  String address;
  String phone;
  String email;

  SignupModel({
    required this.userId,
    required this.userName,
    required this.password,
    required this.gender,
    required this.birthday,
    required this.diseaseInfo,
    required this.height,
    required this.weight,
    required this.phone,
    required this.email,
    required this.address,
  });

  // Factory constructor to create a SignupModel from JSON
  factory SignupModel.fromJson(Map<String, dynamic> json) => SignupModel(
        userId: json["userId"],
        userName: json["userName"],
        password: json["password"],
        gender: json["gender"],
        birthday: json["birthday"],
        diseaseInfo: json["diseaseInfo"],
        height: json["height"].toDouble(), // Ensure the value is a double
        weight: json["weight"].toDouble(), // Ensure the value is a double
        phone: json["phone"],
        email: json["email"],
        address: json["address"],
      );

  // Method to convert SignupModel to JSON
  Map<String, dynamic> toJson() => {
        "userId": userId,
        "userName": userName,
        "password": password,
        "gender": gender,
        "birthday": birthday,
        "height": height,
        "weight": weight,
        "email": email,
        "phone": phone,
        "address": address,
        "diseaseInfo": diseaseInfo,
      };
}
