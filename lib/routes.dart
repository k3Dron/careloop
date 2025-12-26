import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/medication_screen.dart';
import 'screens/daily_log_screen.dart';
import 'screens/appointments_screen.dart';
import 'screens/health_summary_screen.dart';
import 'screens/profile_screen.dart';

class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String medication = '/medication';
  static const String dailyLog = '/daily-log';
  static const String appointments = '/appointments';
  static const String healthSummary = '/health-summary';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        login: (context) => const LoginScreen(),
        register: (context) => const RegisterScreen(),
        home: (context) => const HomeScreen(),
        medication: (context) => const MedicationScreen(),
        dailyLog: (context) => const DailyLogScreen(),
        appointments: (context) => const AppointmentsScreen(),
        healthSummary: (context) => const HealthSummaryScreen(),
        profile: (context) => const ProfileScreen(),
      };
}