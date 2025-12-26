import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/daily_log_model.dart';
import '../models/medication_model.dart';

class HealthSummaryScreen extends StatefulWidget {
  const HealthSummaryScreen({super.key});

  @override
  State<HealthSummaryScreen> createState() => _HealthSummaryScreenState();
}

class _HealthSummaryScreenState extends State<HealthSummaryScreen> {
  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();
    final userId = authService.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Insights'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Your 7-Day Summary',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Logic-based insights from your health data',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),

            // Medication Adherence
            StreamBuilder<List<MedicationModel>>(
              stream: firestoreService.getMedications(userId),
              builder: (context, medSnapshot) {
                final activeMeds = medSnapshot.data?.where((m) => m.isActive).length ?? 0;
                
                return _InsightCard(
                  icon: Icons.medication_rounded,
                  title: 'Medication Tracking',
                  color: const Color(0xFF4A90E2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You have $activeMeds active medication${activeMeds != 1 ? 's' : ''}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        activeMeds > 0
                            ? 'Great job maintaining your medication routine!'
                            : 'Consider adding your medications for better tracking',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Weekly logs analysis
            StreamBuilder<List<DailyLogModel>>(
              stream: firestoreService.getRecentLogs(userId, 7),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final logs = snapshot.data!;
                
                if (logs.isEmpty) {
                  return _InsightCard(
                    icon: Icons.insights_rounded,
                    title: 'Weekly Activity',
                    color: const Color(0xFF50C878),
                    child: const Text(
                      'Start logging your daily health to see insights here!',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                // Calculate insights
                final totalLogs = logs.length;
                final avgMood = logs.map((l) => l.mood).reduce((a, b) => a + b) / totalLogs;
                final avgWater = logs.map((l) => l.waterIntake).reduce((a, b) => a + b) / totalLogs;
                final avgSteps = logs.map((l) => l.steps).reduce((a, b) => a + b) / totalLogs;
                
                // Get common symptoms
                final allSymptoms = <String>[];
                for (var log in logs) {
                  allSymptoms.addAll(log.symptoms);
                }
                final symptomCounts = <String, int>{};
                for (var symptom in allSymptoms) {
                  symptomCounts[symptom] = (symptomCounts[symptom] ?? 0) + 1;
                }
                final topSymptoms = symptomCounts.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                return Column(
                  children: [
                    // Logging consistency
                    _InsightCard(
                      icon: Icons.check_circle_rounded,
                      title: 'Logging Consistency',
                      color: const Color(0xFF50C878),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'You logged $totalLogs out of 7 days',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: totalLogs / 7,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getConsistencyMessage(totalLogs),
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Mood trend
                    _InsightCard(
                      icon: Icons.mood_rounded,
                      title: 'Mood Trend',
                      color: const Color(0xFFFFB800),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _getMoodEmoji(avgMood.round()),
                                style: const TextStyle(fontSize: 40),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Average mood: ${avgMood.toStringAsFixed(1)}/5',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      _getMoodTrendMessage(avgMood),
                                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _SimpleMoodChart(logs: logs),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Water intake
                    _InsightCard(
                      icon: Icons.water_drop_rounded,
                      title: 'Hydration',
                      color: const Color(0xFF00B4D8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Average: ${avgWater.toStringAsFixed(1)} glasses/day',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getWaterMessage(avgWater),
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          _SimpleBarChart(
                            values: logs.map((l) => l.waterIntake.toDouble()).toList(),
                            color: const Color(0xFF00B4D8),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Steps (simulated)
                    _InsightCard(
                      icon: Icons.directions_walk_rounded,
                      title: 'Activity Level',
                      color: const Color(0xFF9B59B6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Average: ${avgSteps.toStringAsFixed(0)} steps/day',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getStepsMessage(avgSteps),
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '(Simulated data for demo)',
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Common symptoms
                    if (topSymptoms.isNotEmpty)
                      _InsightCard(
                        icon: Icons.healing_rounded,
                        title: 'Reported Symptoms',
                        color: const Color(0xFFE74C3C),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Most common this week:',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            const SizedBox(height: 12),
                            ...topSymptoms.take(3).map((entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE74C3C),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '${entry.key} (${entry.value} day${entry.value > 1 ? 's' : ''})',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                            const SizedBox(height: 8),
                            const Text(
                              'Consider discussing persistent symptoms with your doctor',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // Disclaimer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.amber.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'These insights are logic-based summaries of your logged data. They are not medical diagnoses or predictions. Always consult healthcare professionals for medical advice.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

  String _getConsistencyMessage(int days) {
    if (days >= 7) return 'Perfect! Keep up the excellent tracking!';
    if (days >= 5) return 'Great consistency! Almost there!';
    if (days >= 3) return 'Good start! Try to log daily for better insights.';
    return 'Try logging daily to see meaningful patterns!';
  }

  String _getMoodTrendMessage(double avg) {
    if (avg >= 4) return 'You\'re feeling great this week!';
    if (avg >= 3) return 'Your mood has been steady this week.';
    return 'Consider activities that boost your mood.';
  }

  String _getWaterMessage(double avg) {
    if (avg >= 8) return 'Excellent hydration! Keep it up!';
    if (avg >= 6) return 'Good hydration, close to your target!';
    if (avg >= 4) return 'Try to drink more water throughout the day.';
    return 'Increase your water intake for better health.';
  }

  String _getStepsMessage(double avg) {
    if (avg >= 10000) return 'Excellent activity level!';
    if (avg >= 7000) return 'Good activity level, keep moving!';
    if (avg >= 5000) return 'Moderate activity. Try to move more!';
    return 'Consider increasing your daily activity.';
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Widget child;

  const _InsightCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _SimpleMoodChart extends StatelessWidget {
  final List<DailyLogModel> logs;

  const _SimpleMoodChart({required this.logs});

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) return const SizedBox();
    
    final sortedLogs = List<DailyLogModel>.from(logs)
      ..sort((a, b) => a.date.compareTo(b.date));

    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: sortedLogs.map((log) {
          final height = (log.mood / 5) * 60;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 30,
                height: height,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB800),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('E').format(DateTime.parse(log.date)).substring(0, 1),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SimpleBarChart extends StatelessWidget {
  final List<double> values;
  final Color color;

  const _SimpleBarChart({required this.values, required this.color});

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox();
    
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) return const SizedBox();

    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: values.map((value) {
          final height = (value / maxValue) * 60;
          return Container(
            width: 30,
            height: height > 0 ? height : 2,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          );
        }).toList(),
      ),
    );
  }
}