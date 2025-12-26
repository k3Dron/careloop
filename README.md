# CARELOOP - Your Daily Health Companion

A patient-centered Flutter mobile application focused on daily self-care, medication adherence, wellness tracking, and healthcare organization.

## 🎯 Problem Statement

Patients often struggle with:
- Remembering to take medications on time
- Tracking daily health habits consistently
- Communicating symptoms clearly to healthcare providers
- Preparing adequately for doctor visits

## 💡 Solution

CARELOOP provides:
- **Guided Daily Health Flows**: Turn healthcare routines into simple, trackable activities
- **Medication Management**: Never miss a dose with organized medication schedules
- **Visual Health Summaries**: See your health patterns at a glance with logic-based insights
- **Appointment Organization**: Keep track of all doctor visits and care plans
- **Privacy-First Design**: All data stored securely with Firebase

## 🏗️ Tech Stack

- **Framework**: Flutter (Material 3)
- **Authentication**: Firebase Authentication (Email/Password)
- **Database**: Cloud Firestore
- **State Management**: Provider
- **Date Formatting**: intl package

## ✨ Features

### 1. Authentication
- Secure email/password registration and login
- Role selection (Patient/Caregiver)
- Session management with auto-navigation

### 2. Home Dashboard
- Personalized greeting based on time of day
- Real-time medication count
- Today's mood indicator
- Water intake tracking
- Quick action buttons for common tasks

### 3. Medication Manager
- Add, edit, and delete medications
- Set specific times and dosages
- Active/inactive toggle for medication management
- Visual medication timeline

### 4. Daily Health Log
- Emoji-based mood selector (1-5 scale)
- Water intake counter
- Symptom checklist (10 common symptoms)
- Simulated step count for activity tracking
- One-tap daily logging

### 5. Appointments
- Book and manage doctor appointments
- Upcoming and past appointment views
- Doctor specialty and notes tracking
- Mark appointments as completed

### 6. Health Insights
- 7-day health summary
- Medication adherence tracking
- Mood trend analysis with visual chart
- Hydration patterns
- Activity level overview
- Common symptom tracking
- Logic-based recommendations (no AI/ML)

### 7. Profile & Privacy
- User information display
- Privacy policy explanation
- Data simulation disclaimers
- Secure logout

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── routes.dart                  # Navigation routes
├── models/
│   ├── user_model.dart         # User data model
│   ├── medication_model.dart   # Medication data model
│   ├── daily_log_model.dart    # Daily health log model
│   └── appointment_model.dart  # Appointment data model
├── services/
│   ├── auth_service.dart       # Firebase Auth wrapper
│   └── firestore_service.dart  # Firestore database operations
├── screens/
│   ├── splash_screen.dart      # Initial loading screen
│   ├── login_screen.dart       # User login
│   ├── register_screen.dart    # User registration
│   ├── home_screen.dart        # Main dashboard
│   ├── medication_screen.dart  # Medication management
│   ├── daily_log_screen.dart   # Daily health logging
│   ├── appointments_screen.dart # Appointments management
│   ├── health_summary_screen.dart # Health insights
│   └── profile_screen.dart     # User profile & settings
└── widgets/                     # Reusable UI components
```

## 🔥 Firebase Setup

### Firestore Structure

```
users/
  └── {userId}/
      ├── name: string
      ├── email: string
      ├── age: number
      ├── role: string (patient/caregiver)
      └── createdAt: timestamp

medications/
  └── {userId}/
      └── items/
          └── {medicationId}/
              ├── id: string
              ├── name: string
              ├── dosage: string
              ├── time: string (HH:mm)
              ├── notes: string
              └── isActive: boolean

daily_logs/
  └── {userId}/
      └── logs/
          └── {date (yyyy-MM-dd)}/
              ├── mood: number (1-5)
              ├── waterIntake: number
              ├── steps: number
              └── symptoms: array of strings

appointments/
  └── {userId}/
      └── items/
          └── {appointmentId}/
              ├── id: string
              ├── doctorName: string
              ├── specialty: string
              ├── dateTime: timestamp
              ├── notes: string
              └── status: string (upcoming/completed)
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Firebase project set up
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd careloop
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
   - Create a Firebase project at https://console.firebase.google.com
   - Add Android/iOS apps to your Firebase project
   - Download and add configuration files:
     - `google-services.json` for Android (android/app/)
     - `GoogleService-Info.plist` for iOS (ios/Runner/)
   - Enable Email/Password authentication in Firebase Console
   - Create Firestore database in production mode

4. Run the app
```bash
flutter run
```

## 🎨 Design Principles

- **Accessibility First**: Minimum 16px font size, high contrast, large tap targets
- **Material 3**: Modern, clean design language
- **Healthcare Colors**: Calming blue and green palette
- **Clear Hierarchy**: Important information easily scannable
- **Minimal Cognitive Load**: One primary action per screen

## ⚠️ Important Notes

### Simulated Features (For Demo Only)
- **Step Count**: Generated randomly for demonstration
- **Doctor Responses**: Simulated for UI/UX showcase
- **Reminders**: UI mockups only, not actual system notifications

### No AI/ML
This app uses **logic-based insights** only:
- Simple averages and counts
- Trend analysis using basic statistics
- Pattern recognition through data aggregation
- No predictive models or machine learning

### Not a Medical Device
CARELOOP is a wellness tracking tool and does NOT:
- Diagnose medical conditions
- Predict health outcomes
- Replace professional medical advice
- Analyze health data using AI

## 🏆 Hackathon Value Proposition

### Innovation
- Privacy-first healthcare companion
- Simulated features demonstrate full product vision
- Clean architecture ready for production scaling

### Technical Excellence
- Complete CRUD operations with Firebase
- Real-time data streaming
- Proper state management
- Clean, maintainable code structure

### User Experience
- Intuitive, accessible interface
- Comprehensive feature set
- Thoughtful visual design
- Clear user flows

### Market Readiness
- Addresses real patient pain points
- Scalable architecture
- Clear data structure
- Production-ready codebase

## 📱 Demo Walkthrough

1. **Onboarding**: Splash → Register (Name, Age, Role, Email, Password)
2. **Home Dashboard**: View health summary, quick actions
3. **Add Medication**: Name, dosage, time scheduling
4. **Daily Log**: Log mood, water intake, symptoms
5. **Book Appointment**: Doctor name, specialty, date/time
6. **View Insights**: 7-day health summary with charts
7. **Profile**: View user info, privacy policy, logout

## 🔐 Security & Privacy

- Firebase Authentication for secure user management
- User data isolated by userId
- No third-party data sharing
- Local session management
- Secure logout functionality

## 📄 License

This is a hackathon project created for educational and demonstration purposes.

## 👥 Target Users

- **Young Adults**: Managing medications and wellness habits
- **Elderly Patients**: Simple interface for daily health tracking
- **Caregivers**: Monitoring patient adherence and wellness
- **Chronic Condition Patients**: Consistent health pattern tracking

## 🎯 Future Enhancements

- Push notifications for medication reminders
- Export health reports as PDF
- Family/caregiver access sharing
- Integration with wearable devices
- Telemedicine appointment booking
- Prescription scanning and OCR

---

**Built with ❤️ for healthier tomorrows**
