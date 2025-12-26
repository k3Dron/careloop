class DailyLogModel {
  final String date; // yyyy-MM-dd format
  final int mood; // 1-5
  final int waterIntake; // number of glasses
  final int steps; // simulated step count
  final List<String> symptoms;

  DailyLogModel({
    required this.date,
    required this.mood,
    required this.waterIntake,
    required this.steps,
    required this.symptoms,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'mood': mood,
      'waterIntake': waterIntake,
      'steps': steps,
      'symptoms': symptoms,
    };
  }

  factory DailyLogModel.fromMap(Map<String, dynamic> map) {
    return DailyLogModel(
      date: map['date'] ?? '',
      mood: map['mood'] ?? 3,
      waterIntake: map['waterIntake'] ?? 0,
      steps: map['steps'] ?? 0,
      symptoms: List<String>.from(map['symptoms'] ?? []),
    );
  }
}