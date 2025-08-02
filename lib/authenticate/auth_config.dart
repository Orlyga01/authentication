import 'package:google_sign_in/google_sign_in.dart';
import 'package:authentication/authenticate/config_extractor.dart';

/// Global authentication configuration for OAuth providers
class AuthConfig {
  static AuthConfig? _instance;
  static AuthConfig get instance => _instance ??= AuthConfig._internal();

  AuthConfig._internal();

  // Google OAuth Configuration
  String? _googleServerClientId;
  String? _googleClientId;
  List<String> _googleScopes = ['email', 'profile'];

  // Apple OAuth Configuration
  List<String> _appleScopes = ['email', 'fullname'];

  bool _isInitialized = false;

  /// Initialize authentication with OAuth provider configurations
  ///
  /// Call this once in your app's main() function or before using login buttons
  ///
  /// Example:
  /// ```dart
  /// await AuthConfig.initialize(
  ///   googleServerClientId: "your-android-client-id.apps.googleusercontent.com",
  ///   googleClientId: "your-web-client-id.apps.googleusercontent.com", // optional
  ///   googleScopes: ['email', 'profile'], // optional
  ///   appleScopes: ['email', 'fullname'], // optional
  /// );
  /// ```
  static Future<void> initialize({
    String? googleServerClientId,
    String? googleClientId,
    List<String>? googleScopes,
    List<String>? appleScopes,
  }) async {
    final config = instance;

    // Set Google configuration
    config._googleServerClientId = googleServerClientId;
    config._googleClientId = googleClientId;
    if (googleScopes != null) {
      config._googleScopes = googleScopes;
    }

    // Set Apple configuration
    if (appleScopes != null) {
      config._appleScopes = appleScopes;
    }

    config._isInitialized = true;

    // Pre-initialize Google Sign-In if configuration is provided
    if (googleServerClientId != null) {
      try {
        await config._initializeGoogleSignIn();
      } catch (e) {
        print('Warning: Google Sign-In initialization failed: $e');
      }
    }
  }

  /// Automatically initialize from Google Services files
  ///
  /// This method reads your google-services.json and GoogleService-Info.plist files
  /// to automatically extract the OAuth client IDs.
  ///
  /// Usage:
  /// ```dart
  /// await AuthConfig.initializeFromGoogleServices();
  /// ```
  ///
  /// Optional parameters:
  /// ```dart
  /// await AuthConfig.initializeFromGoogleServices(
  ///   googleScopes: ['email', 'profile', 'openid'],
  ///   appleScopes: ['email', 'fullname'],
  /// );
  /// ```
  static Future<void> initializeFromGoogleServices({
    List<String>? googleScopes,
    List<String>? appleScopes,
  }) async {
    print('🔍 Extracting OAuth configuration from Google Services files...');

    try {
      final extractedConfig =
          await GoogleServicesConfigExtractor.extractConfig();

      if (!extractedConfig.hasValidConfig) {
        throw Exception(
            'No valid OAuth configuration found in Google Services files. '
            'Make sure google-services.json or GoogleService-Info.plist are accessible.');
      }

      print('✅ Configuration extracted: $extractedConfig');

      await initialize(
        googleServerClientId: extractedConfig.serverClientId,
        googleClientId: extractedConfig.clientId,
        googleScopes: googleScopes,
        appleScopes: appleScopes,
      );

      print('🚀 Authentication initialized successfully!');
    } catch (e) {
      print('❌ Failed to initialize from Google Services: $e');
      print(
          '💡 Tip: Copy google-services.json and GoogleService-Info.plist to assets/ folder');
      rethrow;
    }
  }

  /// Initialize from Google Services file content directly
  ///
  /// Pass the content of your Google Services files directly without needing to copy files.
  ///
  /// Usage:
  /// ```dart
  /// final googleServicesJson = await File('android/app/google-services.json').readAsString();
  /// final googleServicesPlist = await File('ios/Runner/GoogleService-Info.plist').readAsString();
  ///
  /// await AuthConfig.initializeFromContent(
  ///   googleServicesJsonContent: googleServicesJson,
  ///   googleServicesPlistContent: googleServicesPlist,
  /// );
  /// ```
  static Future<void> initializeFromContent({
    String? googleServicesJsonContent,
    String? googleServicesPlistContent,
    List<String>? googleScopes,
    List<String>? appleScopes,
  }) async {
    print('🔍 Extracting OAuth configuration from provided content...');

    try {
      final extractedConfig =
          await GoogleServicesConfigExtractor.extractFromContent(
        googleServicesJsonContent: googleServicesJsonContent,
        googleServicesPlistContent: googleServicesPlistContent,
      );

      if (!extractedConfig.hasValidConfig) {
        throw Exception(
            'No valid OAuth configuration found in provided content. '
            'Make sure to provide valid google-services.json and/or GoogleService-Info.plist content.');
      }

      print('✅ Configuration extracted from content: $extractedConfig');

      await initialize(
        googleServerClientId: extractedConfig.serverClientId,
        googleClientId: extractedConfig.clientId,
        googleScopes: googleScopes,
        appleScopes: appleScopes,
      );

      print('🚀 Authentication initialized successfully from content!');
    } catch (e) {
      print('❌ Failed to initialize from content: $e');
      rethrow;
    }
  }

  /// Pre-initialize Google Sign-In with stored configuration
  Future<void> _initializeGoogleSignIn() async {
    if (_googleServerClientId != null) {
      await GoogleSignIn.instance.initialize(
        clientId: _googleClientId,
        serverClientId: _googleServerClientId,
      );
    }
  }

  /// Check if authentication has been initialized
  static bool get isInitialized => instance._isInitialized;

  /// Get Google OAuth configuration
  GoogleAuthConfig get googleConfig => GoogleAuthConfig(
        serverClientId: _googleServerClientId,
        clientId: _googleClientId,
        scopes: _googleScopes,
      );

  /// Get Apple OAuth configuration
  AppleAuthConfig get appleConfig => AppleAuthConfig(
        scopes: _appleScopes,
      );

  /// Reset configuration (useful for testing)
  static void reset() {
    _instance = null;
  }
}

/// Google OAuth configuration container
class GoogleAuthConfig {
  final String? serverClientId;
  final String? clientId;
  final List<String> scopes;

  const GoogleAuthConfig({
    this.serverClientId,
    this.clientId,
    required this.scopes,
  });

  bool get isConfigured => serverClientId != null;
}

/// Apple OAuth configuration container
class AppleAuthConfig {
  final List<String> scopes;

  const AppleAuthConfig({
    required this.scopes,
  });
}
