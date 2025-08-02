import 'package:flutter/material.dart';
import 'package:authentication/authentication.dart';

/// Example showing automatic OAuth configuration extraction from Google Services files
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🎯 SMART AUTO-CONFIGURATION!
  // This tries multiple methods automatically:
  // 1. Environment variables (most secure)
  // 2. File content (if provided)
  // 3. Google Services files extraction from assets
  // 4. Fallback to manual configuration
  try {
    await AutoConfigHelper.smartInitialize(
      // OPTION: Pass file content directly (recommended!)
      // googleServicesJsonContent: await File('android/app/google-services.json').readAsString(),
      // googleServicesPlistContent: await File('ios/Runner/GoogleService-Info.plist').readAsString(),

      // Fallback configuration (used if automatic extraction fails)
      fallbackGoogleServerClientId:
          "332126803247-e82gimi60j0dmaf6r1rr0mq3c1t3v2b9.apps.googleusercontent.com",
      fallbackGoogleClientId:
          "332126803247-0gdsj46u80tls5j11e0fglun1f2jpvqd.apps.googleusercontent.com",

      // Optional: Customize scopes
      googleScopes: ['email', 'profile'],
      appleScopes: ['email', 'fullname'],
    );

    print('✅ OAuth configuration completed successfully!');
    runApp(MyApp());
  } catch (e) {
    print('❌ OAuth configuration failed: $e');
    runApp(ConfigErrorApp(error: e.toString()));
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OAuth Authentication Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ExampleLoginScreen(),
    );
  }
}

class ExampleLoginScreen extends StatelessWidget {
  const ExampleLoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication Example'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Configuration status indicator
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green[700],
                    size: 48,
                  ),
                  SizedBox(height: 12),
                  Text(
                    '🔄 OAuth Auto-Configured!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Configuration extracted from Google Services files',
                    style: TextStyle(
                      color: Colors.green[600],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            const Text(
              'Sign in to continue',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),

            // 🚀 SUPER SIMPLE - No configuration needed!
            GoogleLoginButton(
              externalContext: context,
              buttonText: "Continue with Google",
              mainColor: Colors.white,
              textColor: Colors.black87,
              outlined: true,
              saveToLocalStorage: true,

              // Optional custom loading spinner
              pendingSpinner: const CircularProgressIndicator(
                color: Colors.blue,
                strokeWidth: 2,
              ),
            ),

            const SizedBox(height: 16),

            // 🍎 SUPER SIMPLE - No configuration needed!
            AppleLoginButton(
              externalContext: context,
              buttonText: "Continue with Apple",
              mainColor: Colors.black,
              textColor: Colors.white,

              // Optional custom loading spinner
              pendingSpinner: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),

            const SizedBox(height: 30),

            // Info section
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Client IDs automatically extracted from your Google Services files',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'After successful login, you\'ll receive a LoginInfo object with OAuth data to send to your backend.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontSize: 11,
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
}

/// Example of how to handle authentication state changes
/* 
To handle authentication state changes in your app, use this pattern:

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthenticationHandler extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProviderForUser);
    
    return authState.when(
      authenticated: (user, loginInfo) {
        // Success! Send OAuth data to your backend
        print('✅ Logged in as: ${loginInfo.email}');
        print('Provider: ${loginInfo.loginType}'); // "google" or "apple"
        print('User ID: ${loginInfo.uid}'); // OAuth provider user ID
        
        // Send to your backend API for authentication
        _authenticateWithBackend(loginInfo);
        
        return HomeScreen();
      },
      
      authenticationFailed: (error, loginInfo) {
        print('❌ Authentication failed: $error');
        return LoginErrorScreen(error: error);
      },
      
      googleAuthenticationInProgress: () {
        return LoadingScreen(message: "Signing in with Google...");
      },
      
      appleAuthenticationInProgress: () {
        return LoadingScreen(message: "Signing in with Apple...");
      },
      
      needToLogin: (loginInfo) {
        return ExampleLoginScreen();
      },
      
      orElse: () => ExampleLoginScreen(),
    );
  }
  
  // Example of sending OAuth data to your backend
  void _authenticateWithBackend(LoginInfo loginInfo) async {
    try {
      // Use the OAuth data from Google/Apple to authenticate with your own backend
      final response = await http.post(
        Uri.parse('https://your-api.com/auth/oauth'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'provider': loginInfo.loginType, // "google" or "apple"
          'user_id': loginInfo.uid,        // OAuth provider user ID
          'email': loginInfo.email,
          'name': loginInfo.name,
          'external_login': loginInfo.externalLogin, // true
        }),
      );
      
      if (response.statusCode == 200) {
        // Your backend authenticated the user successfully
        final userData = jsonDecode(response.body);
        print('✅ Backend authentication successful');
        // Handle your app's user session here
      } else {
        print('❌ Backend authentication failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Backend authentication error: $e');
    }
  }
}
*/

// Configuration error app
class ConfigErrorApp extends StatelessWidget {
  final String error;

  const ConfigErrorApp({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Setup Required'),
          backgroundColor: Colors.red[700],
        ),
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber, size: 80, color: Colors.orange[700]),
              SizedBox(height: 20),
              Text('OAuth Setup Required',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(error, style: TextStyle(color: Colors.red[700])),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
📋 IMPORTANT: File Access Clarification

❌ The package CANNOT automatically access:
   - android/app/google-services.json
   - ios/Runner/GoogleService-Info.plist
   
✅ The package CAN access files that YOUR APP includes in assets

📋 Smart Setup Options (in order of preference):

🥇 OPTION 1: Environment Variables (Most Secure)
   Run your app with:
   flutter run --dart-define=GOOGLE_ANDROID_CLIENT_ID=your_android_client_id

🥈 OPTION 2: Pass File Content Directly (Recommended!)
   await AutoConfigHelper.smartInitialize(
     googleServicesJsonContent: await File('android/app/google-services.json').readAsString(),
     googleServicesPlistContent: await File('ios/Runner/GoogleService-Info.plist').readAsString(),
   );

🥉 OPTION 3: Copy Google Services Files to YOUR APP
   In YOUR main app (not this package):
   1. Copy android/app/google-services.json → assets/google-services.json
   2. Copy ios/Runner/GoogleService-Info.plist → assets/GoogleService-Info.plist
   3. Add to YOUR app's pubspec.yaml assets section

🏅 OPTION 4: Automatic Fallback (Works Out of the Box)
   The example already includes your actual client IDs as fallback

🎯 The package tries all methods automatically!
- ✅ Tries environment variables first
- ✅ Uses provided file content (if passed)
- ✅ Falls back to Google Services file extraction (from YOUR app's assets)
- ✅ Uses manual fallback configuration if needed
- ✅ Shows helpful error if nothing works

🚀 No setup required for basic testing - fallback config included!

📌 KEY POINT: You can pass file content directly or the package reads from YOUR app's assets.
*/
