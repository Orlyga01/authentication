# 🔄 Runtime Configuration Extraction

Now you can automatically extract OAuth client IDs from your Google Services files at runtime!

## 🚀 **Super Simple Setup**

### Step 1: Copy Google Services Files to Assets

Copy your Google Services files to the `assets/` folder in your main app:

```
your_app/
├── assets/
│   ├── google-services.json          # Copy from android/app/
│   └── GoogleService-Info.plist      # Copy from ios/Runner/
├── lib/
├── android/
└── ios/
```

### Step 2: Update pubspec.yaml

Add the files to your app's `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/google-services.json
    - assets/GoogleService-Info.plist
```

### Step 3: Initialize Automatically

Replace your manual configuration with automatic extraction:

```dart
import 'package:authentication/authentication.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🎯 AUTOMATIC EXTRACTION!
  await AuthConfig.initializeFromGoogleServices();
  
  runApp(MyApp());
}
```

## 🎨 **Optional Customization**

You can still customize scopes:

```dart
await AuthConfig.initializeFromGoogleServices(
  googleScopes: ['email', 'profile', 'openid'],
  appleScopes: ['email', 'fullname'],
);
```

## 🔍 **What Gets Extracted**

From your files, it automatically finds:

### `google-services.json` → Android & Web Client IDs
```json
{
  "client": [
    {
      "oauth_client": [
        {
          "client_id": "332126803247-e82gimi60j0dmaf6r1rr0mq3c1t3v2b9.apps.googleusercontent.com",
          "client_type": 1  // ← Android OAuth Client
        },
        {
          "client_id": "332126803247-o5vj6aq0sb6p5hfkhekn9ef05aq0t7np.apps.googleusercontent.com", 
          "client_type": 3  // ← Web OAuth Client
        }
      ]
    }
  ]
}
```

### `GoogleService-Info.plist` → iOS Client ID
```xml
<key>CLIENT_ID</key>
<string>332126803247-0gdsj46u80tls5j11e0fglun1f2jpvqd.apps.googleusercontent.com</string>
```

## ✅ **Benefits**

1. **No Hardcoding** - Client IDs are read from your existing config files
2. **Always in Sync** - If you update your Google Services files, OAuth config updates automatically
3. **Platform Aware** - Automatically uses the right client ID for each platform
4. **Error Handling** - Clear error messages if files are missing
5. **Development Friendly** - Shows extraction progress in debug console

## 🔧 **Debug Output**

In debug mode, you'll see helpful output:

```
🔍 Extracting OAuth configuration from Google Services files...
✅ Configuration extracted: GoogleServicesConfig(android: ✓, ios: ✓, web: ✓)
🚀 Authentication initialized successfully!
```

## 📱 **Platform Support**

| Platform | Uses | Source File |
|----------|------|-------------|
| **Android** | Android Client ID | `google-services.json` |
| **iOS** | iOS Client ID | `GoogleService-Info.plist` |
| **Web** | Web Client ID | `google-services.json` |

## 🚨 **Troubleshooting**

### Error: "No valid OAuth configuration found"

**Solution**: Make sure you've copied the files to `assets/` and added them to `pubspec.yaml`

### Error: "google-services.json not found"

**Solution**: 
1. Copy `android/app/google-services.json` to `assets/google-services.json`
2. Add to `pubspec.yaml` under `flutter: assets:`

### Error: "GoogleService-Info.plist not found"

**Solution**:
1. Copy `ios/Runner/GoogleService-Info.plist` to `assets/GoogleService-Info.plist`
2. Add to `pubspec.yaml` under `flutter: assets:`

## 🔄 **Migration from Manual Config**

**Before:**
```dart
await AuthConfig.initialize(
  googleServerClientId: "332126803247-e82gimi60j0dmaf6r1rr0mq3c1t3v2b9.apps.googleusercontent.com",
  googleClientId: "332126803247-0gdsj46u80tls5j11e0fglun1f2jpvqd.apps.googleusercontent.com",
);
```

**After:**
```dart
// Copy files to assets/ first!
await AuthConfig.initializeFromGoogleServices();
```

## 🎯 **Complete Example**

```dart
import 'package:flutter/material.dart';
import 'package:authentication/authentication.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // 🔄 Automatic configuration from your existing Google Services files
    await AuthConfig.initializeFromGoogleServices(
      googleScopes: ['email', 'profile'],
      appleScopes: ['email', 'fullname'],
    );
    
    runApp(MyApp());
  } catch (e) {
    print('❌ Authentication setup failed: $e');
    // Handle initialization error
    runApp(MyErrorApp(error: e.toString()));
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto-Configured Auth',
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🎉 OAuth Auto-Configured!'),
              SizedBox(height: 20),
              
              // Simple buttons - no config needed!
              GoogleLoginButton(externalContext: context),
              SizedBox(height: 10),
              AppleLoginButton(externalContext: context),
            ],
          ),
        ),
      ),
    );
  }
}
```

Now your OAuth configuration is completely automated! 🚀