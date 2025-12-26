import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/appointment_model.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  void _showAddAppointmentDialog({AppointmentModel? appointment}) {
    final doctorNameController = TextEditingController(text: appointment?.doctorName ?? '');
    final specialtyController = TextEditingController(text: appointment?.specialty ?? '');
    final notesController = TextEditingController(text: appointment?.notes ?? '');
    DateTime selectedDate = appointment?.dateTime ?? DateTime.now();
    TimeOfDay selectedTime = appointment != null
        ? TimeOfDay(hour: appointment.dateTime.hour, minute: appointment.dateTime.minute)
        : TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(appointment == null ? 'Book Appointment' : 'Edit Appointment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: doctorNameController,
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    labelText: 'Doctor Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: specialtyController,
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    labelText: 'Specialty',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Date', style: TextStyle(fontSize: 16)),
                  subtitle: Text(
                    DateFormat('MMM d, yyyy').format(selectedDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: const Icon(Icons.calendar_today_rounded),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Time', style: TextStyle(fontSize: 16)),
                  subtitle: Text(
                    selectedTime.format(context),
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: const Icon(Icons.access_time_rounded),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setState(() {
                        selectedTime = time;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  style: const TextStyle(fontSize: 16),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(fontSize: 16)),
            ),
            FilledButton(
              onPressed: () async {
                if (doctorNameController.text.isEmpty || specialtyController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all required fields')),
                  );
                  return;
                }

                final authService = context.read<AuthService>();
                final firestoreService = context.read<FirestoreService>();
                final userId = authService.currentUser?.uid ?? '';

                final appointmentDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );

                final newAppointment = AppointmentModel(
                  id: appointment?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  doctorName: doctorNameController.text,
                  specialty: specialtyController.text,
                  dateTime: appointmentDateTime,
                  notes: notesController.text,
                  status: appointment?.status ?? 'upcoming',
                );

                if (appointment == null) {
                  await firestoreService.addAppointment(userId, newAppointment);
                } else {
                  await firestoreService.updateAppointment(userId, newAppointment);
                }

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(appointment == null
                          ? 'Appointment booked successfully'
                          : 'Appointment updated successfully'),
                    ),
                  );
                }
              },
              child: Text(appointment == null ? 'Book' : 'Update', style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();
    final userId = authService.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddAppointmentDialog(),
          ),
        ],
      ),
      body: StreamBuilder<List<AppointmentModel>>(
        stream: firestoreService.getAppointments(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No appointments scheduled',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to book your first appointment',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          final appointments = snapshot.data!;
          final now = DateTime.now();
          final upcoming = appointments
              .where((a) => a.dateTime.isAfter(now) && a.status == 'upcoming')
              .toList();
          final completed = appointments
              .where((a) => a.status == 'completed' || a.dateTime.isBefore(now))
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Upcoming appointments
              if (upcoming.isNotEmpty) ...[
                const Text(
                  'Upcoming',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...upcoming.map((appointment) => _AppointmentCard(
                  appointment: appointment,
                  onTap: () => _showAddAppointmentDialog(appointment: appointment),
                  onComplete: () async {
                    await firestoreService.updateAppointment(
                      userId,
                      appointment.copyWith(status: 'completed'),
                    );
                  },
                )),
                const SizedBox(height: 24),
              ],

              // Past/Completed appointments
              if (completed.isNotEmpty) ...[
                const Text(
                  'Past Appointments',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                ...completed.map((appointment) => _AppointmentCard(
                  appointment: appointment,
                  isPast: true,
                  onTap: () => _showAddAppointmentDialog(appointment: appointment),
                  onComplete: () {},
                )),
              ],

              // Note about simulated appointments
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Appointments are simulated for demo purposes',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAppointmentDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Book Appointment', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final bool isPast;
  final VoidCallback onTap;
  final VoidCallback onComplete;

  const _AppointmentCard({
    required this.appointment,
    this.isPast = false,
    required this.onTap,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isPast
                          ? Colors.grey.shade200
                          : const Color(0xFF4A90E2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.local_hospital_rounded,
                      color: isPast ? Colors.grey : const Color(0xFF4A90E2),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.doctorName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isPast ? Colors.grey : Colors.black,
                          ),
                        ),
                        Text(
                          appointment.specialty,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isPast)
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline),
                      onPressed: onComplete,
                      tooltip: 'Mark as completed',
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMM d, yyyy').format(appointment.dateTime),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time_rounded,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('h:mm a').format(appointment.dateTime),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              if (appointment.notes.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.notes_rounded,
                        size: 18,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          appointment.notes,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}