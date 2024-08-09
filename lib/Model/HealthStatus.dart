class HealthStatus {
  double highBlood;
  double lowBlood;
  double emptySugar;
  double fullSugar;
  double weight; // Add this line
  final String userId;
  final DateTime date;
  final int statusId;

  HealthStatus({
    required this.highBlood,
    required this.lowBlood,
    required this.emptySugar,
    required this.fullSugar,
    required this.weight, // Add this line
    required this.userId,
    required this.date,
    required this.statusId,
  });

  factory HealthStatus.fromJson(Map<String, dynamic> json) {
    return HealthStatus(
      highBlood: json['highBlood']?.toDouble() ?? 0.0,
      lowBlood: json['lowBlood']?.toDouble() ?? 0.0,
      emptySugar: json['emptySugar']?.toDouble() ?? 0.0,
      fullSugar: json['fullSugar']?.toDouble() ?? 0.0,
      weight: json['weight']?.toDouble() ?? 0.0, // Add this line
      userId: json['userId'] ?? '',
      date: DateTime.parse(json['date']),
      statusId: json['statusId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'highBlood': highBlood,
      'lowBlood': lowBlood,
      'emptySugar': emptySugar,
      'fullSugar': fullSugar,
      'weight': weight, // Add this line
      'userId': userId,
      'date': date.toIso8601String(),
      'statusId': statusId,
    };
  }
}
