# Usage Examples

Now that the login buttons accept configuration parameters, here's how to use them:

## Google Login Button

```dart
GoogleLoginButton(
  externalContext: context,
  // REQUIRED: Your Android OAuth 2.0 Client ID from Google Cloud Console
  serverClientId: "123456789-abcdefg.apps.googleusercontent.com",
  
  // Optional: Web OAuth 2.0 Client ID (for web support)
  clientId: "123456789-hijklmn.apps.googleusercontent.com",
  
  // Optional: Additional scopes (default: ['email', 'profile'])
  scopes: ['email', 'profile', 'openid'],
  
  // UI customization
  buttonText: "Sign in with Google",
  mainColor: Colors.blue,
  textColor: Colors.white,
  outlined: false,
  disabled: false,
  saveToLocalStorage: true,
  
  // Optional loading spinner
  pendingSpinner: CircularProgressIndicator(color: Colors.white),
)
```

## Apple Login Button

```dart
AppleLoginButton(
  externalContext: context,
  
  // Optional: Custom scopes (default: ['email', 'fullname'])
  scopes: ['email', 'fullname'],
  
  // UI customization
  buttonText: "Sign in with Apple",
  mainColor: Colors.black,
  textColor: Colors.white,
  outlined: false,
  disabled: false,
  
  // Optional loading spinner
  pendingSpinner: CircularProgressIndicator(color: Colors.white),
)
```

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:authentication/authentication.dart';

class LoginScreen extends StatelessWidget {
  // Your Google Cloud Console OAuth client IDs
  static const String googleServerClientId = "YOUR_ANDROID_CLIENT_ID.apps.googleusercontent.com";
  static const String googleWebClientId = "YOUR_WEB_CLIENT_ID.apps.googleusercontent.com";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google Sign-In Button
            GoogleLoginButton(
              externalContext: context,
              serverClientId: googleServerClientId,
              clientId: googleWebClientId,
              scopes: ['email', 'profile'],
              buttonText: "Continue with Google",
              mainColor: Colors.white,
              textColor: Colors.black87,
              outlined: true,
            ),
            
            SizedBox(height: 16),
            
            // Apple Sign-In Button (iOS only)
            AppleLoginButton(
              externalContext: context,
              scopes: ['email', 'fullname'],
              buttonText: "Continue with Apple",
              mainColor: Colors.black,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
```

## Handling Authentication Results

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginHandler extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProviderForUser);
    
    return authState.when(
      // Authentication successful
      authenticated: (user, loginInfo) {
        // Send OAuth data to your backend
        sendToBackend(loginInfo);
        return HomeScreen();
      },
      
      // Authentication failed
      authenticationFailed: (error, loginInfo) {
        return LoginErrorScreen(error: error);
      },
      
      // Authentication in progress
      googleAuthenticationInProgress: () {
        return LoadingScreen(message: "Signing in with Google...");
      },
      
      appleAuthenticationInProgress: () {
        return LoadingScreen(message: "Signing in with Apple...");
      },
      
      // Need to login
      needToLogin: (loginInfo) {
        return LoginScreen();
      },
      
      // Default
      orElse: () => LoginScreen(),
    );
  }
  
  void sendToBackend(LoginInfo loginInfo) async {
    // Use the OAuth data to authenticate with your backend
    final response = await http.post(
      Uri.parse('https://your-api.com/auth/oauth'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'provider': loginInfo.loginType, // "google" or "apple"
        'user_id': loginInfo.uid,        // OAuth provider user ID
        'email': loginInfo.email,
        'name': loginInfo.name,
        'external_login': loginInfo.externalLogin,
      }),
    );
    
    if (response.statusCode == 200) {
      // Backend authenticated the user successfully
      final userData = jsonDecode(response.body);
      // Handle your app's user session
    }
  }
}
```

## Environment Variables (Recommended)

For better security, use environment variables:

```dart
GoogleLoginButton(
  externalContext: context,
  serverClientId: const String.fromEnvironment('GOOGLE_ANDROID_CLIENT_ID'),
  clientId: const String.fromEnvironment('GOOGLE_WEB_CLIENT_ID'),
  scopes: ['email', 'profile'],
)
```

Then run your app with:
```bash
flutter run \
  --dart-define=GOOGLE_ANDROID_CLIENT_ID=your_android_client_id \
  --dart-define=GOOGLE_WEB_CLIENT_ID=your_web_client_id
```

## Available Scopes

### Google Scopes:
- `'email'` - Email address
- `'profile'` - Basic profile info (name, picture)
- `'openid'` - OpenID Connect
- Add any other [Google OAuth scopes](https://developers.google.com/identity/protocols/oauth2/scopes)

### Apple Scopes:
- `'email'` - Email address
- `'fullname'` or `'name'` - Full name (given name + family name)

## Error Handling

```dart
try {
  // Login button was pressed
} catch (e) {
  if (e is GoogleSignInFailure) {
    print('Google Sign-In failed: ${e.message}');
  } else if (e is AppleSignInFailure) {
    print('Apple Sign-In failed: ${e.message}');
  }
}
```