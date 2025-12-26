import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/medication_model.dart';
import '../models/daily_log_model.dart';
import '../models/appointment_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ===== USERS =====
  Future<void> createUser(String userId, UserModel user) async {
    await _db.collection('users').doc(userId).set(user.toMap());
  }

  Future<UserModel?> getUser(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  // ===== MEDICATIONS =====
  Future<void> addMedication(String userId, MedicationModel medication) async {
    await _db
        .collection('medications')
        .doc(userId)
        .collection('items')
        .doc(medication.id)
        .set(medication.toMap());
  }

  Future<void> updateMedication(String userId, MedicationModel medication) async {
    await _db
        .collection('medications')
        .doc(userId)
        .collection('items')
        .doc(medication.id)
        .update(medication.toMap());
  }

  Future<void> deleteMedication(String userId, String medicationId) async {
    await _db
        .collection('medications')
        .doc(userId)
        .collection('items')
        .doc(medicationId)
        .delete();
  }

  Stream<List<MedicationModel>> getMedications(String userId) {
    return _db
        .collection('medications')
        .doc(userId)
        .collection('items')
        .orderBy('time')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicationModel.fromMap(doc.data()))
            .toList());
  }

  // ===== DAILY LOGS =====
  Future<void> saveDailyLog(String userId, DailyLogModel log) async {
    await _db
        .collection('daily_logs')
        .doc(userId)
        .collection('logs')
        .doc(log.date)
        .set(log.toMap());
  }

  Future<DailyLogModel?> getDailyLog(String userId, String date) async {
    final doc = await _db
        .collection('daily_logs')
        .doc(userId)
        .collection('logs')
        .doc(date)
        .get();
    if (doc.exists) {
      return DailyLogModel.fromMap(doc.data()!);
    }
    return null;
  }

  Stream<List<DailyLogModel>> getRecentLogs(String userId, int days) {
    final DateTime cutoff = DateTime.now().subtract(Duration(days: days));
    return _db
        .collection('daily_logs')
        .doc(userId)
        .collection('logs')
        .where('date', isGreaterThanOrEqualTo: _formatDate(cutoff))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DailyLogModel.fromMap(doc.data()))
            .toList());
  }

  // ===== APPOINTMENTS =====
  Future<void> addAppointment(String userId, AppointmentModel appointment) async {
    await _db
        .collection('appointments')
        .doc(userId)
        .collection('items')
        .doc(appointment.id)
        .set(appointment.toMap());
  }

  Future<void> updateAppointment(String userId, AppointmentModel appointment) async {
    await _db
        .collection('appointments')
        .doc(userId)
        .collection('items')
        .doc(appointment.id)
        .update(appointment.toMap());
  }

  Stream<List<AppointmentModel>> getAppointments(String userId) {
    return _db
        .collection('appointments')
        .doc(userId)
        .collection('items')
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppointmentModel.fromMap(doc.data()))
            .toList());
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}