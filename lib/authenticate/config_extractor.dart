import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';

/// Extracts OAuth configuration from Google Services files
class GoogleServicesConfigExtractor {
  /// Extract configuration from Google Services files automatically
  ///
  /// This reads your existing google-services.json and GoogleService-Info.plist files
  /// to automatically get the OAuth client IDs without hardcoding them.
  static Future<GoogleServicesConfig> extractConfig() async {
    String? androidClientId;
    String? iosClientId;
    String? webClientId;

    // Try to extract Android configuration
    try {
      androidClientId = await _extractAndroidClientId();
    } catch (e) {
      if (kDebugMode) {
        print('Warning: Could not extract Android client ID: $e');
      }
    }

    // Try to extract iOS configuration
    try {
      iosClientId = await _extractiOSClientId();
    } catch (e) {
      if (kDebugMode) {
        print('Warning: Could not extract iOS client ID: $e');
      }
    }

    // Try to extract Web configuration (from Android file)
    try {
      webClientId = await _extractWebClientId();
    } catch (e) {
      if (kDebugMode) {
        print('Warning: Could not extract Web client ID: $e');
      }
    }

    return GoogleServicesConfig(
      androidClientId: androidClientId,
      iosClientId: iosClientId,
      webClientId: webClientId,
    );
  }

  /// Extract configuration from Google Services file content directly
  ///
  /// Pass the content of your files directly without needing file system access.
  static Future<GoogleServicesConfig> extractFromContent({
    String? googleServicesJsonContent,
    String? googleServicesPlistContent,
  }) async {
    String? androidClientId;
    String? iosClientId;
    String? webClientId;

    // Extract from JSON content
    if (googleServicesJsonContent != null) {
      try {
        androidClientId =
            await _extractAndroidClientIdFromContent(googleServicesJsonContent);
      } catch (e) {
        if (kDebugMode) {
          print(
              'Warning: Could not extract Android client ID from content: $e');
        }
      }

      try {
        webClientId =
            await _extractWebClientIdFromContent(googleServicesJsonContent);
      } catch (e) {
        if (kDebugMode) {
          print('Warning: Could not extract Web client ID from content: $e');
        }
      }
    }

    // Extract from plist content
    if (googleServicesPlistContent != null) {
      try {
        iosClientId =
            await _extractiOSClientIdFromContent(googleServicesPlistContent);
      } catch (e) {
        if (kDebugMode) {
          print('Warning: Could not extract iOS client ID from content: $e');
        }
      }
    }

    return GoogleServicesConfig(
      androidClientId: androidClientId,
      iosClientId: iosClientId,
      webClientId: webClientId,
    );
  }

  /// Extract Android OAuth client ID from google-services.json
  static Future<String?> _extractAndroidClientId() async {
    try {
      String? jsonString;

      // Try multiple locations in order of preference
      final locations = [
        'assets/google-services.json', // Primary: assets folder
        'google-services.json', // Alternative: root assets
        'android/app/google-services.json', // Try app directory (may not work)
      ];

      for (String location in locations) {
        try {
          jsonString = await rootBundle.loadString(location);
          print('✅ Found google-services.json at: $location');
          break;
        } catch (e) {
          // Continue to next location
          continue;
        }
      }

      if (jsonString == null) {
        throw Exception(
            'google-services.json not found in any expected location');
      }

      final Map<String, dynamic> config = json.decode(jsonString);
      final List<dynamic> clients = config['client'] ?? [];

      for (final client in clients) {
        final List<dynamic> oauthClients = client['oauth_client'] ?? [];
        for (final oauthClient in oauthClients) {
          // Look for Android client (client_type: 1)
          if (oauthClient['client_type'] == 1) {
            return oauthClient['client_id'] as String?;
          }
        }
      }

      throw Exception('Android OAuth client not found in google-services.json');
    } catch (e) {
      throw Exception('Failed to extract Android client ID: $e');
    }
  }

  /// Extract Web OAuth client ID from google-services.json
  static Future<String?> _extractWebClientId() async {
    try {
      String? jsonString;

      // Try the same locations as Android client ID
      final locations = [
        'assets/google-services.json',
        'google-services.json',
        'android/app/google-services.json',
      ];

      for (String location in locations) {
        try {
          jsonString = await rootBundle.loadString(location);
          break;
        } catch (e) {
          continue;
        }
      }

      if (jsonString == null) return null;

      final Map<String, dynamic> config = json.decode(jsonString);
      final List<dynamic> clients = config['client'] ?? [];

      for (final client in clients) {
        final List<dynamic> oauthClients = client['oauth_client'] ?? [];
        for (final oauthClient in oauthClients) {
          // Look for Web client (client_type: 3)
          if (oauthClient['client_type'] == 3) {
            return oauthClient['client_id'] as String?;
          }
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Extract iOS OAuth client ID from GoogleService-Info.plist
  static Future<String?> _extractiOSClientId() async {
    try {
      String? plistString;

      // Try multiple locations for the plist file
      final locations = [
        'assets/GoogleService-Info.plist', // Primary: assets folder
        'GoogleService-Info.plist', // Alternative: root assets
        'ios/Runner/GoogleService-Info.plist', // Try iOS directory (may not work)
      ];

      for (String location in locations) {
        try {
          plistString = await rootBundle.loadString(location);
          print('✅ Found GoogleService-Info.plist at: $location');
          break;
        } catch (e) {
          continue;
        }
      }

      if (plistString == null) {
        throw Exception(
            'GoogleService-Info.plist not found in any expected location');
      }

      // Parse the plist XML
      final document = XmlDocument.parse(plistString);
      final dict = document.findAllElements('dict').first;
      final keys = dict.findAllElements('key');
      final values = dict.findAllElements('string');

      // Find CLIENT_ID key
      for (int i = 0; i < keys.length; i++) {
        if (keys.elementAt(i).text == 'CLIENT_ID') {
          // The value should be the next string element
          if (i < values.length) {
            return values.elementAt(i).text;
          }
        }
      }

      throw Exception('CLIENT_ID not found in GoogleService-Info.plist');
    } catch (e) {
      throw Exception('Failed to extract iOS client ID: $e');
    }
  }

  /// Extract Android OAuth client ID from JSON content
  static Future<String?> _extractAndroidClientIdFromContent(
      String jsonContent) async {
    try {
      final Map<String, dynamic> config = json.decode(jsonContent);
      final List<dynamic> clients = config['client'] ?? [];

      for (final client in clients) {
        final List<dynamic> oauthClients = client['oauth_client'] ?? [];
        for (final oauthClient in oauthClients) {
          // Look for Android client (client_type: 1)
          if (oauthClient['client_type'] == 1) {
            return oauthClient['client_id'] as String?;
          }
        }
      }

      throw Exception('Android OAuth client not found in JSON content');
    } catch (e) {
      throw Exception('Failed to extract Android client ID from content: $e');
    }
  }

  /// Extract Web OAuth client ID from JSON content
  static Future<String?> _extractWebClientIdFromContent(
      String jsonContent) async {
    try {
      final Map<String, dynamic> config = json.decode(jsonContent);
      final List<dynamic> clients = config['client'] ?? [];

      for (final client in clients) {
        final List<dynamic> oauthClients = client['oauth_client'] ?? [];
        for (final oauthClient in oauthClients) {
          // Look for Web client (client_type: 3)
          if (oauthClient['client_type'] == 3) {
            return oauthClient['client_id'] as String?;
          }
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Extract iOS OAuth client ID from plist content
  static Future<String?> _extractiOSClientIdFromContent(
      String plistContent) async {
    try {
      // Parse the plist XML
      final document = XmlDocument.parse(plistContent);
      final dict = document.findAllElements('dict').first;
      final keys = dict.findAllElements('key');
      final values = dict.findAllElements('string');

      // Find CLIENT_ID key
      for (int i = 0; i < keys.length; i++) {
        if (keys.elementAt(i).text == 'CLIENT_ID') {
          // The value should be the next string element
          if (i < values.length) {
            return values.elementAt(i).text;
          }
        }
      }

      throw Exception('CLIENT_ID not found in plist content');
    } catch (e) {
      throw Exception('Failed to extract iOS client ID from content: $e');
    }
  }
}

/// Configuration extracted from Google Services files
class GoogleServicesConfig {
  final String? androidClientId;
  final String? iosClientId;
  final String? webClientId;

  const GoogleServicesConfig({
    this.androidClientId,
    this.iosClientId,
    this.webClientId,
  });

  /// Get the appropriate server client ID for the current platform
  String? get serverClientId {
    if (!kIsWeb && Platform.isAndroid) {
      return androidClientId;
    }
    return androidClientId; // Fallback to Android client ID
  }

  /// Get the appropriate client ID for the current platform
  String? get clientId {
    if (!kIsWeb && Platform.isIOS) {
      return iosClientId;
    }
    if (kIsWeb) {
      return webClientId ?? iosClientId;
    }
    return iosClientId ?? webClientId;
  }

  bool get hasValidConfig {
    return androidClientId != null ||
        iosClientId != null ||
        webClientId != null;
  }

  @override
  String toString() {
    return 'GoogleServicesConfig('
        'android: ${androidClientId != null ? "✓" : "✗"}, '
        'ios: ${iosClientId != null ? "✓" : "✗"}, '
        'web: ${webClientId != null ? "✓" : "✗"})';
  }
}
