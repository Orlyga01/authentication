# 📱 Parent App Setup Instructions

**IMPORTANT**: This package cannot access your app's `android/app/` or `ios/Runner/` directories directly. The files must be accessible through your app's assets.

## 🎯 **How File Access Works**

```
❌ Package CANNOT access:
   your_app/android/app/google-services.json
   your_app/ios/Runner/GoogleService-Info.plist

✅ Package CAN access:
   your_app/assets/google-services.json        ← You copy here
   your_app/assets/GoogleService-Info.plist    ← You copy here
```

## 🔧 **Setup in Your Main App**

### Step 1: Copy Files to Your App's Assets
In your main app directory (not the package):

```bash
# Copy Google Services files to your app's assets folder
cp android/app/google-services.json assets/
cp ios/Runner/GoogleService-Info.plist assets/
```

### Step 2: Update Your App's pubspec.yaml
In your main app's `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/google-services.json
    - assets/GoogleService-Info.plist
```

### Step 3: Use the Package
In your main app's `main.dart`:

```dart
import 'package:authentication/authentication.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // The package will now find the files in YOUR app's assets
  await AutoConfigHelper.smartInitialize(
    // Fallback if files aren't found
    fallbackGoogleServerClientId: "your_android_client_id",
    fallbackGoogleClientId: "your_ios_client_id",
  );
  
  runApp(MyApp());
}
```

## 🎯 **Alternative: Zero Setup**

If you don't want to copy files, just use the fallback configuration:

```dart
await AutoConfigHelper.smartInitialize(
  fallbackGoogleServerClientId: "332126803247-e82gimi60j0dmaf6r1rr0mq3c1t3v2b9.apps.googleusercontent.com",
  fallbackGoogleClientId: "332126803247-0gdsj46u80tls5j11e0fglun1f2jpvqd.apps.googleusercontent.com",
);
```

This works immediately without any file copying!

## 🔐 **Most Secure: Environment Variables**

```bash
flutter run \
  --dart-define=GOOGLE_ANDROID_CLIENT_ID=332126803247-e82gimi60j0dmaf6r1rr0mq3c1t3v2b9.apps.googleusercontent.com \
  --dart-define=GOOGLE_WEB_CLIENT_ID=332126803247-0gdsj46u80tls5j11e0fglun1f2jpvqd.apps.googleusercontent.com
```

## 📋 **Summary**

| Method | Setup Required | Security | Maintenance |
|--------|---------------|----------|-------------|
| **Environment Variables** | Command line flags | 🟢 High | 🟢 Easy |
| **Assets Files** | Copy + pubspec.yaml | 🟡 Medium | 🟡 Manual sync |
| **Fallback Config** | None | 🔴 Low | 🟢 Easy |

**Recommendation**: Use environment variables for production, fallback config for development.

## 🚨 **Common Mistakes**

❌ **Wrong**: Expecting the package to find files automatically
❌ **Wrong**: Putting files in the package's assets
❌ **Wrong**: Not adding files to YOUR app's pubspec.yaml

✅ **Correct**: Copy files to YOUR app's assets folder
✅ **Correct**: Add files to YOUR app's pubspec.yaml
✅ **Correct**: Package reads from YOUR app's asset bundle

The package works within YOUR app's context and can only access what YOUR app makes available!