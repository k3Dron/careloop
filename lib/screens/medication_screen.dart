import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/medication_model.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  void _showAddMedicationDialog({MedicationModel? medication}) {
    final nameController = TextEditingController(text: medication?.name ?? '');
    final dosageController = TextEditingController(text: medication?.dosage ?? '');
    final notesController = TextEditingController(text: medication?.notes ?? '');
    TimeOfDay selectedTime = medication != null
        ? TimeOfDay(
            hour: int.parse(medication.time.split(':')[0]),
            minute: int.parse(medication.time.split(':')[1]),
          )
        : TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(medication == null ? 'Add Medication' : 'Edit Medication'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  labelText: 'Medication Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: dosageController,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  labelText: 'Dosage (e.g., 500mg)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState) => ListTile(
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
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                style: const TextStyle(fontSize: 16),
                maxLines: 2,
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
              if (nameController.text.isEmpty || dosageController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in all required fields')),
                );
                return;
              }

              final authService = context.read<AuthService>();
              final firestoreService = context.read<FirestoreService>();
              final userId = authService.currentUser?.uid ?? '';

              final newMedication = MedicationModel(
                id: medication?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text,
                dosage: dosageController.text,
                time: '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                notes: notesController.text,
                isActive: medication?.isActive ?? true,
              );

              if (medication == null) {
                await firestoreService.addMedication(userId, newMedication);
              } else {
                await firestoreService.updateMedication(userId, newMedication);
              }

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(medication == null
                        ? 'Medication added successfully'
                        : 'Medication updated successfully'),
                  ),
                );
              }
            },
            child: Text(medication == null ? 'Add' : 'Update', style: const TextStyle(fontSize: 16)),
          ),
        ],
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
        title: const Text('Medications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddMedicationDialog(),
          ),
        ],
      ),
      body: StreamBuilder<List<MedicationModel>>(
        stream: firestoreService.getMedications(userId),
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
                    Icons.medication_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No medications added yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your first medication',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          final medications = snapshot.data!;
          final activeMeds = medications.where((m) => m.isActive).toList();
          final inactiveMeds = medications.where((m) => !m.isActive).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Today's Medication Timeline
              if (activeMeds.isNotEmpty) ...[
                const Text(
                  'Today\'s Schedule',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...activeMeds.map((med) => _MedicationTimelineItem(
                  medication: med,
                  onTap: () => _showAddMedicationDialog(medication: med),
                  onToggle: () async {
                    await firestoreService.updateMedication(
                      userId,
                      med.copyWith(isActive: false),
                    );
                  },
                  onDelete: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Medication'),
                        content: const Text('Are you sure you want to delete this medication?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await firestoreService.deleteMedication(userId, med.id);
                    }
                  },
                )),
              ],
              
              // Inactive medications
              if (inactiveMeds.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Inactive Medications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                ...inactiveMeds.map((med) => _MedicationTimelineItem(
                  medication: med,
                  onTap: () => _showAddMedicationDialog(medication: med),
                  onToggle: () async {
                    await firestoreService.updateMedication(
                      userId,
                      med.copyWith(isActive: true),
                    );
                  },
                  onDelete: () async {
                    await firestoreService.deleteMedication(userId, med.id);
                  },
                )),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMedicationDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Medication', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}

class _MedicationTimelineItem extends StatelessWidget {
  final MedicationModel medication;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _MedicationTimelineItem({
    required this.medication,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: medication.isActive
                ? const Color(0xFF4A90E2).withOpacity(0.1)
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.medication_rounded,
            color: medication.isActive ? const Color(0xFF4A90E2) : Colors.grey,
            size: 28,
          ),
        ),
        title: Text(
          medication.name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: medication.isActive ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${medication.dosage} at ${medication.time}',
              style: const TextStyle(fontSize: 16),
            ),
            if (medication.notes.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                medication.notes,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: onTap,
              child: const Row(
                children: [
                  Icon(Icons.edit_outlined),
                  SizedBox(width: 8),
                  Text('Edit', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: onToggle,
              child: Row(
                children: [
                  Icon(medication.isActive
                      ? Icons.pause_circle_outline
                      : Icons.play_circle_outline),
                  const SizedBox(width: 8),
                  Text(
                    medication.isActive ? 'Deactivate' : 'Activate',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: onDelete,
              child: const Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(fontSize: 16, color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}