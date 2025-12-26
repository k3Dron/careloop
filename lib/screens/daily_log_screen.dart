import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/daily_log_model.dart';

class DailyLogScreen extends StatefulWidget {
  const DailyLogScreen({super.key});

  @override
  State<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends State<DailyLogScreen> {
  int _mood = 3;
  int _waterIntake = 0;
  final List<String> _selectedSymptoms = [];
  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> _availableSymptoms = [
    'Headache',
    'Fatigue',
    'Nausea',
    'Dizziness',
    'Fever',
    'Cough',
    'Sore Throat',
    'Body Aches',
    'Loss of Appetite',
    'Insomnia',
  ];

  @override
  void initState() {
    super.initState();
    _loadTodayLog();
  }

  Future<void> _loadTodayLog() async {
    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();
    final userId = authService.currentUser?.uid ?? '';
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final log = await firestoreService.getDailyLog(userId, today);
    if (log != null) {
      setState(() {
        _mood = log.mood;
        _waterIntake = log.waterIntake;
        _selectedSymptoms.clear();
        _selectedSymptoms.addAll(log.symptoms);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveDailyLog() async {
    setState(() {
      _isSaving = true;
    });

    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();
    final userId = authService.currentUser?.uid ?? '';
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Simulate step count (realistic range: 3000-12000 steps)
    final random = Random();
    final steps = 3000 + random.nextInt(9000);

    final log = DailyLogModel(
      date: today,
      mood: _mood,
      waterIntake: _waterIntake,
      steps: steps,
      symptoms: _selectedSymptoms,
    );

    await firestoreService.saveDailyLog(userId, log);

    setState(() {
      _isSaving = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Daily log saved successfully!')),
      );
    }
  }

  String _getMoodEmoji(int mood) {
    switch (mood) {
      case 1: return '😢';
      case 2: return '😕';
      case 3: return '😊';
      case 4: return '😄';
      case 5: return '🤩';
      default: return '😊';
    }
  }

  String _getMoodLabel(int mood) {
    switch (mood) {
      case 1: return 'Very Bad';
      case 2: return 'Bad';
      case 3: return 'Okay';
      case 4: return 'Good';
      case 5: return 'Excellent';
      default: return 'Okay';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Health Log'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, color: Color(0xFF4A90E2)),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Mood Section
            const Text(
              'How are you feeling today?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      _getMoodEmoji(_mood),
                      style: const TextStyle(fontSize: 60),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getMoodLabel(_mood),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (index) {
                        final mood = index + 1;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _mood = mood;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _mood == mood
                                  ? const Color(0xFF4A90E2).withOpacity(0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getMoodEmoji(mood),
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Water Intake Section
            const Text(
              'Water Intake',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.water_drop_rounded,
                          color: Color(0xFF00B4D8),
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$_waterIntake glasses',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton.filled(
                          onPressed: _waterIntake > 0
                              ? () {
                                  setState(() {
                                    _waterIntake--;
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.remove_rounded),
                          iconSize: 28,
                        ),
                        const SizedBox(width: 24),
                        IconButton.filled(
                          onPressed: () {
                            setState(() {
                              _waterIntake++;
                            });
                          },
                          icon: const Icon(Icons.add_rounded),
                          iconSize: 28,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Target: 8 glasses per day',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Symptoms Section
            const Text(
              'Any symptoms today?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableSymptoms.map((symptom) {
                final isSelected = _selectedSymptoms.contains(symptom);
                return FilterChip(
                  label: Text(
                    symptom,
                    style: const TextStyle(fontSize: 16),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedSymptoms.add(symptom);
                      } else {
                        _selectedSymptoms.remove(symptom);
                      }
                    });
                  },
                  showCheckmark: true,
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Note about simulated data
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Step count is simulated for demo purposes',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveDailyLog,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Save Daily Log',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}