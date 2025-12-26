class MedicationModel {
  final String id;
  final String name;
  final String dosage;
  final String time; // HH:mm format
  final String notes;
  final bool isActive;

  MedicationModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
    this.notes = '',
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'time': time,
      'notes': notes,
      'isActive': isActive,
    };
  }

  factory MedicationModel.fromMap(Map<String, dynamic> map) {
    return MedicationModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      time: map['time'] ?? '',
      notes: map['notes'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }

  MedicationModel copyWith({
    String? id,
    String? name,
    String? dosage,
    String? time,
    String? notes,
    bool? isActive,
  }) {
    return MedicationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      time: time ?? this.time,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
    );
  }
}