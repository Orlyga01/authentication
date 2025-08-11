import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:authentication/shared/import_shared.dart';
import 'package:authentication/shared/helpers/secureStorage.dart';
import 'package:authentication/authenticate/models/auth_result.dart';
import 'import_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:crypto/crypto.dart';

class SignUpFailure implements Exception {
  final String message;
  SignUpFailure(this.message);
}

class LogInWithEmailAndPasswordFailure implements Exception {
  final String message;
  LogInWithEmailAndPasswordFailure(this.message);
}

class LogOutFailure implements Exception {}

class LocalAuthRepository {
  LocalAuthRepository();
  
  late final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  /// Generates a UUID for new users
  String _generateUserId() {
    var uuid = '';
    var random = Random();
    var chars = '0123456789abcdef';
    
    for (int i = 0; i < 32; i++) {
      if (i == 8 || i == 12 || i == 16 || i == 20) {
        uuid += '-';
      }
      uuid += chars[random.nextInt(chars.length)];
    }
    return uuid;
  }

  /// Hash password for storage (basic implementation)
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Creates a new user with the provided [email] and [password].
  Future<AuthResult> signUp(LoginInfo info) async {
    try {
      // In a real implementation, you would validate with your backend
      // For now, we'll create a local user
      final userId = _generateUserId();
      
      // Here you would typically send to your backend API
      // For package purposes, we just create a local result
      return AuthResult(
        uid: userId,
        email: info.email,
        displayName: info.name,
        phoneNumber: info.phone,
      );
    } catch (e) {
      throw SignUpFailure('Sign up failed: ${e.toString()}');
    }
  }

  Future<String> resetPassword(String email) async {
    try {
      // In a real implementation, you would call your backend
      // to send a password reset email
      
      // For package purposes, we'll just return success
      return '';
    } catch (e) {
      return 'Password reset failed: ${e.toString()}';
    }
  }

  /// Starts the Sign In with Google Flow without Firebase
  Future<AuthResult> logInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      
      if (googleUser == null) {
        throw Exception('Google sign in was cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Generate a local user ID for the Google user
      final userId = _generateUserId();
      
      return AuthResult(
        uid: userId,
        email: googleUser.email,
        displayName: googleUser.displayName,
        photoURL: googleUser.photoUrl,
      );
    } catch (e) {
      throw Exception('Google sign in failed: ${e.toString()}');
    }
  }

  /// Signs in with the provided [email] and [password].
  Future<AuthResult?> logInWithEmailAndPassword(LoginInfo info) async {
    if (info.email != null && info.password != null) {
      try {
        // In a real implementation, you would validate credentials with your backend
        // For package purposes, we'll do basic validation and create a result
        
        // Generate or retrieve user ID (in real app, this would come from backend)
        final userId = info.uid ?? _generateUserId();
        
        return AuthResult(
          uid: userId,
          email: info.email,
          displayName: info.name,
          phoneNumber: info.phone,
        );
      } catch (e) {
        throw LogInWithEmailAndPasswordFailure('Login failed: ${e.toString()}');
      }
    }
    return null;
  }

  /// Signs out the current user
  Future<void> logOut() async {
    try {
      await _googleSignIn.signOut();
    } on Exception {
      throw LogOutFailure();
    }
  }

  Future<bool> isAuthenticated() async {
    // In a real implementation, you would check with your backend
    // For package purposes, we'll check local storage
    final loginData = UserLocalStorage().getLoginData();
    return loginData.uid != null && loginData.loggedOut != true;
  }

  Future<void> authenticate(LoginInfo logininfo) async {
    if (logininfo.email != null) {
      try {
        await logInWithEmailAndPassword(
            LoginInfo(email: logininfo.email, password: logininfo.password));
      } catch (e) {
        throw Exception('Authentication failed: ${e.toString()}');
      }
    }
  }

  Future<String?> getUserId() async {
    // Return the current user ID from local storage
    final loginData = UserLocalStorage().getLoginData();
    return loginData.uid;
  }

  Future deleteAuthUser(String email, String password) async {
    try {
      // In a real implementation, you would call your backend to delete the user
      // For package purposes, we'll just return success
      return true;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> deleteCurrentUser() async {
    // In a real implementation, you would call your backend
    // For package purposes, we'll clear local storage
    await UserLocalStorage().removeLoginData();
  }
} 