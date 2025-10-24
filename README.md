# 🚀 Multi-Admin Task Management App

A comprehensive, enterprise-level task management application built with Flutter, GetX, and Firebase.

## 📱 Features

### 🔐 Authentication & Security
- Multi-level role-based access control (Super Admin, Admin, Team Member, Viewer)
- Firebase Authentication with email/password and Google Sign-In
- Secure session management and token refresh

### 📝 Task Management
- Complete CRUD operations for tasks
- Real-time task synchronization
- Advanced filtering and search capabilities
- Task assignment and collaboration
- Priority and status management
- Due date and reminder system

### 💬 Team Collaboration
- Real-time threaded comments
- Mention system with @username notifications
- Activity feed and tracking
- File sharing and attachments
- Live collaboration updates

### 📊 Advanced Project Management
- Task dependency management (finish-to-start, start-to-start, etc.)
- Project milestone tracking
- Timeline calculation and critical path analysis
- File management with version control
- Project progress visualization

### 🔔 Multi-Channel Notifications
- Firebase Cloud Messaging for push notifications
- Professional email automation with HTML templates
- Slack and Microsoft Teams integration
- Custom webhook system
- Calendar synchronization (Google Calendar, Outlook)

### 📱 Mobile Experience
- Cross-platform (iOS/Android) support
- Material 3 design system
- Dark/Light theme support
- Responsive mobile-first UI
- Offline capabilities with real-time sync

## 🛠️ Technology Stack

- **Frontend**: Flutter 3.x
- **State Management**: GetX
- **Backend**: Firebase (Firestore, Authentication, Cloud Storage, Cloud Messaging)
- **Architecture**: Clean Architecture with feature-first modular design

## 📋 Prerequisites

### Required Software
- Flutter SDK 3.10.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code
- Git

### Firebase Setup Required
- Firebase project with the following services enabled:
  - Authentication
  - Firestore Database
  - Cloud Storage
  - Cloud Messaging
  - Cloud Functions (optional)

## 🚀 Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/maniraj0007/task_management_app.git
cd task_management_app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Configuration

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable the following services:
   - Authentication (Email/Password, Google)
   - Firestore Database
   - Cloud Storage
   - Cloud Messaging

#### Add Firebase Configuration Files

**For Android:**
1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/google-services.json`

**For iOS:**
1. Download `GoogleService-Info.plist` from Firebase Console
2. Place it in `ios/Runner/GoogleService-Info.plist`

#### Update Firebase Configuration
Create `lib/core/config/firebase_config.dart`:
```dart
class FirebaseConfig {
  static const String projectId = 'your-project-id';
  static const String apiKey = 'your-api-key';
  static const String appId = 'your-app-id';
  static const String messagingSenderId = 'your-sender-id';
}
```

### 4. Environment Configuration

Create `.env` file in the root directory:
```env
# Firebase Configuration
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_API_KEY=your-api-key
FIREBASE_APP_ID=your-app-id
FIREBASE_MESSAGING_SENDER_ID=your-sender-id

# Email Service (Optional)
EMAIL_API_KEY=your-email-api-key
EMAIL_API_URL=https://api.emailservice.com/v1/send

# Third-party Integrations (Optional)
SLACK_WEBHOOK_URL=your-slack-webhook-url
TEAMS_WEBHOOK_URL=your-teams-webhook-url
```

### 5. Run the Application

#### Debug Mode
```bash
flutter run
```

#### Release Mode
```bash
flutter run --release
```

## 📁 Project Structure

```
lib/
├── core/                          # Core application logic
│   ├── models/                    # Data models
│   ├── services/                  # Core services
│   ├── theme/                     # UI theming
│   └── routes/                    # Navigation
├── modules/                       # Feature modules
│   ├── auth/                      # Authentication
│   ├── tasks/                     # Task management
│   ├── notifications/             # Notifications
│   └── integrations/             # Third-party integrations
└── shared/                        # Shared components
    ├── widgets/                   # Reusable UI components
    └── utils/                     # Utility functions
```

## 🔧 Configuration

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Tasks are readable by team members, writable by assigned users
    match /tasks/{taskId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (request.auth.uid in resource.data.assignees || 
         request.auth.uid == resource.data.createdBy);
    }
    
    // Comments are readable by all authenticated users
    match /task_comments/{commentId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Activities are readable by all authenticated users
    match /task_activities/{activityId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

### Cloud Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /task_attachments/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 🧪 Testing

### Run Unit Tests
```bash
flutter test
```

### Run Integration Tests
```bash
flutter test integration_test/
```

## 📦 Building for Production

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🔐 Security Considerations

1. **Firebase Security Rules**: Ensure proper Firestore and Storage rules are configured
2. **API Keys**: Keep all API keys secure and use environment variables
3. **Authentication**: Implement proper session management and token refresh
4. **Data Validation**: Validate all user inputs on both client and server side
5. **HTTPS**: Ensure all API communications use HTTPS

## 📊 Performance Optimization

1. **Lazy Loading**: Implement pagination for large data sets
2. **Caching**: Use appropriate caching strategies for frequently accessed data
3. **Image Optimization**: Compress and optimize images before upload
4. **Database Queries**: Use compound indexes for complex queries
5. **Memory Management**: Properly dispose of controllers and streams

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For support and questions, please contact:
- Email: support@taskmanagementapp.com
- GitHub Issues: [Create an issue](https://github.com/maniraj0007/task_management_app/issues)

## 🎯 Roadmap

- [ ] Advanced Analytics Dashboard
- [ ] AI-Powered Task Management
- [ ] Web Application
- [ ] Desktop Applications
- [ ] Advanced Collaboration Features
- [ ] Enterprise Features

---

**Built with ❤️ using Flutter, GetX, and Firebase**
# task_management_flutter
# task_management_app
