# OAuth Setup Instructions

After removing Firebase Auth, you need to configure Google Sign-In directly. Here's how to fix the configuration error:

## Google Sign-In Configuration

### 1. Get Your Client IDs from Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project (or create one)
3. Enable the **Google Sign-In API**
4. Go to **Credentials** → **Create Credentials** → **OAuth 2.0 Client IDs**

### 2. Create OAuth 2.0 Client IDs

You need to create different client IDs for different platforms:

#### For Android:
- **Application type**: Android
- **Package name**: Your app's package name (from `android/app/build.gradle`)
- **SHA-1 certificate fingerprint**: Get this by running:
  ```bash
  cd android && ./gradlew signingReport
  ```
- Copy the **Client ID** (this will be your `serverClientId`)

#### For iOS:
- **Application type**: iOS  
- **Bundle ID**: Your app's bundle identifier (from `ios/Runner.xcodeproj`)
- Download the `GoogleService-Info.plist` file

#### For Web (optional):
- **Application type**: Web application
- **Authorized JavaScript origins**: Your web domain
- Copy the **Client ID** (this will be your `clientId`)

### 3. Update Your Code

In `lib/authenticate/providers/authentication_provider.dart`, update line 91:

```dart
OAuthAuthRepository _authRepository = OAuthAuthRepository(
  // Replace with your Android OAuth 2.0 Client ID
  serverClientId: "YOUR_ANDROID_CLIENT_ID.apps.googleusercontent.com",
  // Replace with your Web OAuth 2.0 Client ID (if supporting web)
  clientId: "YOUR_WEB_CLIENT_ID.apps.googleusercontent.com", 
  // Optional: Add scopes for additional permissions
  scopes: ['email', 'profile'],
);
```

### 4. Platform-Specific Setup

#### Android Configuration:
No additional files needed! Just ensure you have the correct `serverClientId`.

#### iOS Configuration:
1. Add the downloaded `GoogleService-Info.plist` to your `ios/Runner/` directory
2. Make sure it's included in your Xcode project

### 5. Test the Configuration

Run your app and try Google Sign-In. You should now get the user's:
- Email address
- Display name  
- Profile photo URL
- Google ID (use this as your user identifier)

## Example Usage

After successful authentication, you'll receive a `LoginInfo` object with:

```dart
LoginInfo(
  email: "user@example.com",
  uid: "google_user_id_123", 
  name: "User Name",
  loginType: "google",
  externalLogin: true,
)
```

Use this data to create/authenticate the user in your own backend system.

## Troubleshooting

### Common Issues:

1. **"serverClientId must be provided on Android"**
   - Make sure you've set the `serverClientId` parameter
   - Verify the client ID is for Android application type

2. **"Sign in failed"**
   - Check that the SHA-1 fingerprint matches your debug/release certificate
   - Ensure the package name matches exactly

3. **"User cancelled"**
   - This is normal when user cancels the sign-in flow
   - Handle this in your error handling

### Getting SHA-1 Fingerprint:

```bash
# For debug builds:
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore

# For release builds:
keytool -list -v -alias your_alias_name -keystore your_keystore_file
```

The default debug keystore password is usually `android`.