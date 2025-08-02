# 🔑 Your OAuth Configuration

I've extracted the OAuth client IDs from your Google Services files. Here's what you need:

## 📱 **Extracted Client IDs**

### Android (from `google-services.json`)
```json
Package: com.familyMenu
OAuth Client ID: 332126803247-e82gimi60j0dmaf6r1rr0mq3c1t3v2b9.apps.googleusercontent.com
Client Type: 1 (Android Application)
SHA-1 Certificate: c97f9032f76091e46d0bb32a5e694ecdfd1a7896
```

### iOS (from `GoogleService-Info.plist`)
```xml
Bundle ID: com.familymenu
Client ID: 332126803247-0gdsj46u80tls5j11e0fglun1f2jpvqd.apps.googleusercontent.com
Project ID: taroting-78a04
```

### Web (also available)
```json
Web Client ID: 332126803247-o5vj6aq0sb6p5hfkhekn9ef05aq0t7np.apps.googleusercontent.com
Client Type: 3 (Web Application)
```

## 🚀 **Ready-to-Use Configuration**

Add this to your app's `main()` function:

```dart
await AuthConfig.initialize(
  // Android OAuth Client ID (required for Android)
  googleServerClientId: "332126803247-e82gimi60j0dmaf6r1rr0mq3c1t3v2b9.apps.googleusercontent.com",
  
  // iOS OAuth Client ID (for cross-platform support)
  googleClientId: "332126803247-0gdsj46u80tls5j11e0fglun1f2jpvqd.apps.googleusercontent.com",
  
  // Optional: Custom scopes
  googleScopes: ['email', 'profile'],
  appleScopes: ['email', 'fullname'],
);
```

## 🔐 **Environment Variables (Recommended)**

For production apps, use environment variables:

```dart
await AuthConfig.initialize(
  googleServerClientId: const String.fromEnvironment(
    'GOOGLE_ANDROID_CLIENT_ID',
    defaultValue: "332126803247-e82gimi60j0dmaf6r1rr0mq3c1t3v2b9.apps.googleusercontent.com",
  ),
  googleClientId: const String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID', 
    defaultValue: "332126803247-0gdsj46u80tls5j11e0fglun1f2jpvqd.apps.googleusercontent.com",
  ),
);
```

Run with:
```bash
flutter run \
  --dart-define=GOOGLE_ANDROID_CLIENT_ID=332126803247-e82gimi60j0dmaf6r1rr0mq3c1t3v2b9.apps.googleusercontent.com \
  --dart-define=GOOGLE_IOS_CLIENT_ID=332126803247-0gdsj46u80tls5j11e0fglun1f2jpvqd.apps.googleusercontent.com
```

## 🎯 **What Each ID is For**

| Client ID | Purpose | When Used |
|-----------|---------|-----------|
| **Android Client ID** | `googleServerClientId` | Required for Android Google Sign-In |
| **iOS Client ID** | `googleClientId` | For iOS/Web Google Sign-In |
| **Web Client ID** | `googleClientId` | For Web Google Sign-In |

## ✅ **Platform Support**

Your configuration supports:
- ✅ **Android** - Using Android OAuth Client ID
- ✅ **iOS** - Using iOS OAuth Client ID  
- ✅ **Web** - Using Web OAuth Client ID
- ✅ **Apple Sign-In** - No additional configuration needed

## 🚫 **No More Errors!**

This configuration will fix:
- ❌ `serverClientId must be provided on Android`
- ❌ `Google Sign-In not configured`
- ❌ `ClientConfigurationError`

## 📋 **File Mapping**

| Source File | Client ID Location | Purpose |
|-------------|-------------------|---------|
| `android/app/google-services.json` | `client[1].oauth_client[0].client_id` | Android OAuth |
| `ios/Runner/GoogleService-Info.plist` | `CLIENT_ID` | iOS OAuth |
| Both files | Various | Project configuration |

Your authentication package is now ready to go with your actual Google Services configuration! 🎉