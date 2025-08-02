# 🚀 Pass File Content Directly

The best approach! No file copying, no assets setup. Just pass the content directly.

## 🎯 **Simple Example**

```dart
import 'dart:io';
import 'package:authentication/authentication.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Read your Google Services files directly
  final googleServicesJson = await File('android/app/google-services.json').readAsString();
  final googleServicesPlist = await File('ios/Runner/GoogleService-Info.plist').readAsString();
  
  // Pass the content directly - no file copying needed!
  await AutoConfigHelper.smartInitialize(
    googleServicesJsonContent: googleServicesJson,
    googleServicesPlistContent: googleServicesPlist,
    googleScopes: ['email', 'profile'],
    appleScopes: ['email', 'fullname'],
  );
  
  runApp(MyApp());
}
```

## 🔧 **Alternative: Only One Platform**

```dart
// Android only
await AutoConfigHelper.smartInitialize(
  googleServicesJsonContent: await File('android/app/google-services.json').readAsString(),
  fallbackGoogleClientId: "your_ios_client_id", // For iOS support
);

// iOS only
await AutoConfigHelper.smartInitialize(
  googleServicesPlistContent: await File('ios/Runner/GoogleService-Info.plist').readAsString(),
  fallbackGoogleServerClientId: "your_android_client_id", // For Android support
);
```

## 🛡️ **With Error Handling**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  String? googleServicesContent;
  String? googleServicesPlistContent;
  
  // Try to read files (they might not exist in all environments)
  try {
    googleServicesContent = await File('android/app/google-services.json').readAsString();
  } catch (e) {
    print('📱 Android google-services.json not found: $e');
  }
  
  try {
    googleServicesPlistContent = await File('ios/Runner/GoogleService-Info.plist').readAsString();
  } catch (e) {
    print('🍎 iOS GoogleService-Info.plist not found: $e');
  }
  
  await AutoConfigHelper.smartInitialize(
    googleServicesJsonContent: googleServicesContent,
    googleServicesPlistContent: googleServicesPlistContent,
    
    // Fallback for missing files
    fallbackGoogleServerClientId: "332126803247-e82gimi60j0dmaf6r1rr0mq3c1t3v2b9.apps.googleusercontent.com",
    fallbackGoogleClientId: "332126803247-0gdsj46u80tls5j11e0fglun1f2jpvqd.apps.googleusercontent.com",
  );
  
  runApp(MyApp());
}
```

## 🎨 **Advanced: Build-Time Integration**

You can even create a build script that reads the files and generates Dart code:

```dart
// This could be generated at build time
const googleServicesJson = '''
{
  "project_info": {
    "project_number": "332126803247",
    ...
  },
  "client": [
    {
      "oauth_client": [
        {
          "client_id": "332126803247-e82gimi60j0dmaf6r1rr0mq3c1t3v2b9.apps.googleusercontent.com",
          "client_type": 1
        }
      ]
    }
  ]
}
''';

await AutoConfigHelper.smartInitialize(
  googleServicesJsonContent: googleServicesJson,
);
```

## ✅ **Benefits**

- ✅ **No asset copying** - Files stay in their original locations
- ✅ **No pubspec.yaml changes** - No need to modify asset declarations
- ✅ **Always in sync** - Reads the actual files from your project
- ✅ **Build-time safe** - Can be integrated into build processes
- ✅ **Platform flexible** - Works with any platform setup
- ✅ **Error resilient** - Falls back gracefully if files don't exist

## 🎯 **When to Use This**

- ✅ When you don't want to modify your project structure
- ✅ When you want the configuration to always stay in sync
- ✅ When you're building a reusable package or template
- ✅ When you want to avoid asset management complexity

This is the **recommended approach** for most use cases!