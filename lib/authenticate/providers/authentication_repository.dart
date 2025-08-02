import 'dart:async';

import 'package:authentication/authenticate/models/oauth_models.dart';
import 'package:authentication/authenticate/auth_config.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class GoogleSignInFailure implements Exception {
  final String message;
  GoogleSignInFailure(this.message);
}

class AppleSignInFailure implements Exception {
  final String message;
  AppleSignInFailure(this.message);
}

class OAuthAuthRepository {
  /// OAuth-based authentication repository without Firebase
  /// Configuration is now automatically loaded from AuthConfig.
  /// Make sure to call AuthConfig.initialize() before using this repository.
  OAuthAuthRepository();

  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;

  /// Get Google configuration from global AuthConfig
  GoogleAuthConfig get _googleConfig {
    if (!AuthConfig.isInitialized) {
      throw Exception(
          'AuthConfig not initialized. Call AuthConfig.initialize() first.');
    }
    return AuthConfig.instance.googleConfig;
  }

  /// Get Apple configuration from global AuthConfig
  AppleAuthConfig get _appleConfig {
    if (!AuthConfig.isInitialized) {
      throw Exception(
          'AuthConfig not initialized. Call AuthConfig.initialize() first.');
    }
    return AuthConfig.instance.appleConfig;
  }

  /// Signs in with Google and returns Google OAuth data
  ///
  /// Throws a [GoogleSignInFailure] if an exception occurs.
  Future<GoogleOAuthResult> signInWithGoogle() async {
    try {
      final config = _googleConfig;
      if (!config.isConfigured) {
        throw GoogleSignInFailure(
            'Google Sign-In not configured. Provide serverClientId in AuthConfig.initialize()');
      }

      final GoogleSignInAccount? googleUser =
          await _googleSignIn.authenticate();

      if (googleUser == null) {
        throw GoogleSignInFailure('Google Sign-In was cancelled by user');
      }

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // For access tokens, you would need to use the authorization client
      // For now, we'll set accessToken to null since it requires additional scopes
      return GoogleOAuthResult(
        accessToken:
            null, // Access token requires authorization client with specific scopes
        idToken: googleAuth.idToken,
        email: googleUser.email,
        displayName: googleUser.displayName,
        photoUrl: googleUser.photoUrl,
        id: googleUser.id,
      );
    } catch (e) {
      if (e is GoogleSignInFailure) {
        rethrow;
      }
      throw GoogleSignInFailure('Google Sign-In failed: ${e.toString()}');
    }
  }

  /// Signs in with Apple and returns Apple OAuth data
  ///
  /// Throws an [AppleSignInFailure] if an exception occurs.
  Future<AppleOAuthResult> signInWithApple() async {
    try {
      // Convert string scopes to Apple ID authorization scopes
      final appleScopes = <AppleIDAuthorizationScopes>[];
      final scopesToUse = _appleConfig.scopes;

      for (String scope in scopesToUse) {
        switch (scope.toLowerCase()) {
          case 'email':
            appleScopes.add(AppleIDAuthorizationScopes.email);
            break;
          case 'fullname':
          case 'full_name':
          case 'name':
            appleScopes.add(AppleIDAuthorizationScopes.fullName);
            break;
        }
      }

      // Default scopes if none provided
      if (appleScopes.isEmpty) {
        appleScopes.addAll([
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ]);
      }

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: appleScopes,
      );

      return AppleOAuthResult(
          authorizationCode: credential.authorizationCode,
          identityToken: credential.identityToken,
          email: credential.email,
          givenName: credential.givenName,
          familyName: credential.familyName,
          userIdentifier: credential.userIdentifier ?? '');
    } catch (e) {
      throw AppleSignInFailure('Apple Sign-In failed: ${e.toString()}');
    }
  }

  /// Signs out from Google
  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      throw GoogleSignInFailure('Google Sign-Out failed: ${e.toString()}');
    }
  }

  /// Checks if user is currently signed in with Google
  /// This is a simplified check - for production use, you should use authentication events
  Future<bool> isGoogleSignedIn() async {
    try {
      final account = await _googleSignIn.attemptLightweightAuthentication();
      return account != null;
    } catch (e) {
      return false;
    }
  }

  /// Attempts to get current Google user with lightweight authentication
  Future<GoogleSignInAccount?> getCurrentGoogleUser() async {
    try {
      return await _googleSignIn.attemptLightweightAuthentication();
    } catch (e) {
      return null;
    }
  }
}
