class AppointmentModel {
  final String id;
  final String doctorName;
  final String specialty;
  final DateTime dateTime;
  final String notes;
  final String status; // 'upcoming' or 'completed'

  AppointmentModel({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.dateTime,
    this.notes = '',
    this.status = 'upcoming',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorName': doctorName,
      'specialty': specialty,
      'dateTime': dateTime.toIso8601String(),
      'notes': notes,
      'status': status,
    };
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    return AppointmentModel(
      id: map['id'] ?? '',
      doctorName: map['doctorName'] ?? '',
      specialty: map['specialty'] ?? '',
      dateTime: DateTime.parse(map['dateTime']),
      notes: map['notes'] ?? '',
      status: map['status'] ?? 'upcoming',
    );
  }

  AppointmentModel copyWith({
    String? id,
    String? doctorName,
    String? specialty,
    DateTime? dateTime,
    String? notes,
    String? status,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      doctorName: doctorName ?? this.doctorName,
      specialty: specialty ?? this.specialty,
      dateTime: dateTime ?? this.dateTime,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }
}