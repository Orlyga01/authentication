# 🚀 Simple Usage Guide

Now you can initialize OAuth authentication with just one function call!

## 1. Initialize Once in Your App

In your app's `main()` function or before using any login buttons:

```dart
import 'package:authentication/authentication.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize authentication with your OAuth configuration
  await AuthConfig.initialize(
    // REQUIRED for Google Sign-In on Android
    googleServerClientId: "123456789-abcdefg.apps.googleusercontent.com",
    
    // Optional: for Google Sign-In on Web
    googleClientId: "123456789-hijklmn.apps.googleusercontent.com",
    
    // Optional: Custom scopes (defaults shown)
    googleScopes: ['email', 'profile'],
    appleScopes: ['email', 'fullname'],
  );
  
  runApp(MyApp());
}
```

## 2. Use Login Buttons Anywhere

Now your login buttons are super simple to use:

```dart
import 'package:flutter/material.dart';
import 'package:authentication/authentication.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Google Login - No configuration needed!
          GoogleLoginButton(
            externalContext: context,
            buttonText: "Continue with Google",
            mainColor: Colors.white,
            textColor: Colors.black87,
            outlined: true,
          ),
          
          SizedBox(height: 16),
          
          // Apple Login - No configuration needed!
          AppleLoginButton(
            externalContext: context,
            buttonText: "Continue with Apple",
            mainColor: Colors.black,
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
```

## 3. Handle Authentication Results

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthenticationHandler extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProviderForUser);
    
    return authState.when(
      authenticated: (user, loginInfo) {
        // Success! User is authenticated
        print('✅ Logged in as: ${loginInfo.email}');
        print('Provider: ${loginInfo.loginType}'); // "google" or "apple"
        print('User ID: ${loginInfo.uid}'); // Use this as your user identifier
        
        // Send OAuth data to your backend
        authenticateWithYourBackend(loginInfo);
        
        return HomeScreen();
      },
      
      authenticationFailed: (error, loginInfo) {
        return ErrorScreen(error: error);
      },
      
      googleAuthenticationInProgress: () {
        return LoadingScreen(message: "Signing in with Google...");
      },
      
      appleAuthenticationInProgress: () {
        return LoadingScreen(message: "Signing in with Apple...");
      },
      
      orElse: () => LoginScreen(),
    );
  }
  
  void authenticateWithYourBackend(LoginInfo loginInfo) async {
    // Send the OAuth data to your backend API
    final response = await http.post(
      Uri.parse('https://your-api.com/auth/oauth'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'provider': loginInfo.loginType, // "google" or "apple"
        'user_id': loginInfo.uid,        // OAuth provider user ID
        'email': loginInfo.email,
        'name': loginInfo.name,
      }),
    );
    
    if (response.statusCode == 200) {
      // Your backend authenticated the user successfully
      print('✅ Backend authentication successful');
    }
  }
}
```

## 4. Environment Variables (Recommended)

For better security, use environment variables:

```dart
await AuthConfig.initialize(
  googleServerClientId: const String.fromEnvironment('GOOGLE_ANDROID_CLIENT_ID'),
  googleClientId: const String.fromEnvironment('GOOGLE_WEB_CLIENT_ID'),
);
```

Then run your app with:
```bash
flutter run \
  --dart-define=GOOGLE_ANDROID_CLIENT_ID=your_android_client_id \
  --dart-define=GOOGLE_WEB_CLIENT_ID=your_web_client_id
```

## 🔑 Where to Get Your Client IDs

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project → **APIs & Services** → **Credentials**
3. Create **OAuth 2.0 Client ID** for Android:
   - Application type: **Android**
   - Package name: Your app's package name
   - SHA-1 fingerprint: Get from `cd android && ./gradlew signingReport`

## ✅ Benefits

- **One-time setup**: Configure once, use everywhere
- **Simple buttons**: No need to pass configuration to each button
- **Automatic initialization**: Google Sign-In is pre-initialized
- **Type safety**: Configuration is validated at initialization
- **Clean separation**: UI code is separate from configuration

## 🎯 Migration from Previous Version

If you were using the previous version with configuration parameters:

**Before:**
```dart
GoogleLoginButton(
  externalContext: context,
  serverClientId: "your_client_id",
  clientId: "your_web_id",
  // ... other params
)
```

**After:**
```dart
// In main()
await AuthConfig.initialize(
  googleServerClientId: "your_client_id",
  googleClientId: "your_web_id",
);

// In your widget
GoogleLoginButton(
  externalContext: context,
  // No configuration needed!
)
```

That's it! Much simpler and cleaner! 🎉