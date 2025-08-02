import 'package:flutter/services.dart';
import 'package:authentication/authenticate/auth_config.dart';

/// Helper to automatically set up OAuth configuration with minimal user intervention
class AutoConfigHelper {
  /// Try to automatically configure OAuth from any available source
  ///
  /// This method tries multiple approaches:
  /// 1. Use environment variables (most secure)
  /// 2. Use provided file content (if available)
  /// 3. Extract from Google Services files (if available)
  /// 4. Use provided fallback configuration
  static Future<void> smartInitialize({
    // Direct file content (recommended approach)
    String? googleServicesJsonContent,
    String? googleServicesPlistContent,

    // Fallback manual configuration
    String? fallbackGoogleServerClientId,
    String? fallbackGoogleClientId,
    List<String>? googleScopes,
    List<String>? appleScopes,

    // Environment variable names (optional)
    String googleServerClientIdEnvVar = 'GOOGLE_ANDROID_CLIENT_ID',
    String googleClientIdEnvVar = 'GOOGLE_WEB_CLIENT_ID',
  }) async {
    print('🔍 Starting smart OAuth configuration...');

    // Step 1: Try environment variables first (most secure)
    final envGoogleServerClientId =
        const String.fromEnvironment('GOOGLE_ANDROID_CLIENT_ID');
    final envGoogleClientId =
        const String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

    if (envGoogleServerClientId.isNotEmpty) {
      print('✅ Using OAuth configuration from environment variables');
      await AuthConfig.initialize(
        googleServerClientId: envGoogleServerClientId,
        googleClientId: envGoogleClientId.isNotEmpty ? envGoogleClientId : null,
        googleScopes: googleScopes,
        appleScopes: appleScopes,
      );
      return;
    }

    // Step 2: Try using provided file content
    if (googleServicesJsonContent != null ||
        googleServicesPlistContent != null) {
      try {
        print('🔍 Trying to extract from provided file content...');
        await AuthConfig.initializeFromContent(
          googleServicesJsonContent: googleServicesJsonContent,
          googleServicesPlistContent: googleServicesPlistContent,
          googleScopes: googleScopes,
          appleScopes: appleScopes,
        );
        print('✅ Successfully configured from provided content');
        return;
      } catch (e) {
        print('⚠️ Content extraction failed: $e');
      }
    }

    // Step 3: Try extracting from Google Services files in assets
    try {
      print('🔍 Trying to extract from Google Services files in assets...');
      await AuthConfig.initializeFromGoogleServices(
        googleScopes: googleScopes,
        appleScopes: appleScopes,
      );
      print('✅ Successfully configured from Google Services files');
      return;
    } catch (e) {
      print('⚠️ Google Services extraction failed: $e');
    }

    // Step 4: Use provided fallback configuration
    if (fallbackGoogleServerClientId != null) {
      print('✅ Using provided fallback configuration');
      await AuthConfig.initialize(
        googleServerClientId: fallbackGoogleServerClientId,
        googleClientId: fallbackGoogleClientId,
        googleScopes: googleScopes,
        appleScopes: appleScopes,
      );
      return;
    }

    // Step 5: Final fallback - show helpful error
    throw Exception(
        'OAuth configuration failed. Please use one of these options:\n'
        '1. Provide file content directly (googleServicesJsonContent, googleServicesPlistContent)\n'
        '2. Use environment variables (GOOGLE_ANDROID_CLIENT_ID, GOOGLE_WEB_CLIENT_ID)\n'
        '3. Copy google-services.json and GoogleService-Info.plist to assets/\n'
        '4. Provide fallback client IDs\n'
        '5. Call AuthConfig.initialize() manually');
  }

  /// Check if Google Services files are available in the bundle
  static Future<GoogleServicesAvailability>
      checkGoogleServicesAvailability() async {
    bool hasAndroidConfig = false;
    bool hasIOSConfig = false;

    // Check for Android configuration
    try {
      final locations = [
        'assets/google-services.json',
        'google-services.json',
        'android/app/google-services.json',
      ];

      for (String location in locations) {
        try {
          await rootBundle.loadString(location);
          hasAndroidConfig = true;
          break;
        } catch (e) {
          continue;
        }
      }
    } catch (e) {
      // Android config not available
    }

    // Check for iOS configuration
    try {
      final locations = [
        'assets/GoogleService-Info.plist',
        'GoogleService-Info.plist',
        'ios/Runner/GoogleService-Info.plist',
      ];

      for (String location in locations) {
        try {
          await rootBundle.loadString(location);
          hasIOSConfig = true;
          break;
        } catch (e) {
          continue;
        }
      }
    } catch (e) {
      // iOS config not available
    }

    return GoogleServicesAvailability(
      hasAndroidConfig: hasAndroidConfig,
      hasIOSConfig: hasIOSConfig,
    );
  }
}

/// Information about Google Services file availability
class GoogleServicesAvailability {
  final bool hasAndroidConfig;
  final bool hasIOSConfig;

  const GoogleServicesAvailability({
    required this.hasAndroidConfig,
    required this.hasIOSConfig,
  });

  bool get hasAnyConfig => hasAndroidConfig || hasIOSConfig;
  bool get hasCompleteConfig => hasAndroidConfig && hasIOSConfig;

  @override
  String toString() {
    return 'GoogleServicesAvailability('
        'android: ${hasAndroidConfig ? "✓" : "✗"}, '
        'ios: ${hasIOSConfig ? "✓" : "✗"})';
  }
}
