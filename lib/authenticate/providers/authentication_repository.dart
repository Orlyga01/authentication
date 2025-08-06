import 'dart:async';
import 'dart:io';

import 'package:authentication/shared/import_shared.dart';

import 'import_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
//import 'package:mobile_number/mobile_number.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Google OAuth configuration - to be set by the consuming app
class GoogleSignInConfig {
  static String? androidClientId;
  static String? iosClientId;
  static String? webClientId;
  static String? serverClientId; // For backend authentication

  static void configure({
    String? androidClientId,
    String? iosClientId,
    String? webClientId,
    String? serverClientId, // Usually the web client ID for backend auth
  }) {
    GoogleSignInConfig.androidClientId = androidClientId;
    GoogleSignInConfig.iosClientId = iosClientId;
    GoogleSignInConfig.webClientId = webClientId;
    GoogleSignInConfig.serverClientId = serverClientId;
  }
}

class SignUpFailure implements Exception {}

class LogInWithEmailAndPasswordFailure implements Exception {}

class LogOutFailure implements Exception {}

class FirebaseAuthRepository {
  /// {@macro authentication_repository}
  FirebaseAuthRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance {
    _initializeGoogleSignIn();
  }

  final firebase_auth.FirebaseAuth _firebaseAuth;
  late final GoogleSignIn _googleSignIn;

  /// Initialize Google Sign-In with the 7.x API
  void _initializeGoogleSignIn() {
    print('🔍 [GoogleSignIn Debug] Starting initialization...');
    print('🔍 [GoogleSignIn Debug] Platform.isAndroid: ${Platform.isAndroid}');
    print('🔍 [GoogleSignIn Debug] kIsWeb: $kIsWeb');

    // Get the GoogleSignIn instance
    _googleSignIn = GoogleSignIn.instance;
    print('🔍 [GoogleSignIn Debug] Got GoogleSignIn.instance');

    // Configure client IDs based on platform using keys.dart values
    String? clientId;
    String? serverClientId;

    if (Platform.isAndroid) {
      // For Android: use the explicit serverClientId (required for v7.1.1+)
      serverClientId = GoogleSignInConfig.serverClientId;
      print(
          '🔍 [GoogleSignIn Debug] Android - using serverClientId: $serverClientId');
    } else if (Platform.isIOS) {
      // For iOS: clientId should be the iOS client ID
      clientId = GoogleSignInConfig.iosClientId;
      // iOS can also use serverClientId for backend authentication if needed
      serverClientId = GoogleSignInConfig.serverClientId;
      print(
          '🔍 [GoogleSignIn Debug] iOS - using clientId: $clientId, serverClientId: $serverClientId');
    } else if (kIsWeb) {
      // For Web: clientId should be the web client ID
      clientId = GoogleSignInConfig.webClientId;
      // Web can also use serverClientId for backend authentication if needed
      serverClientId = GoogleSignInConfig.serverClientId;
      print(
          '🔍 [GoogleSignIn Debug] Web - using clientId: $clientId, serverClientId: $serverClientId');
    }

    print('🔍 [GoogleSignIn Debug] Final configuration:');
    print('🔍 [GoogleSignIn Debug] - clientId: $clientId');
    print('🔍 [GoogleSignIn Debug] - serverClientId: $serverClientId');
    print('🔍 [GoogleSignIn Debug] Calling _googleSignIn.initialize()...');

    // Initialize Google Sign-In with proper configuration
    _googleSignIn
        .initialize(
      clientId: clientId,
      serverClientId: serverClientId,
    )
        .then((_) {
      print(
          '✅ [GoogleSignIn Debug] GoogleSignIn.initialize() completed successfully');
    }).catchError((error) {
      print(
          '❌ [GoogleSignIn Debug] Google Sign-In initialization failed: $error');
      print('❌ [GoogleSignIn Debug] Error type: ${error.runtimeType}');
    });
  }

  /// Stream of [User] which will emit the current user when
  /// the authentication state changes.
  ///
  /// Emits [User.empty] if the user is not authenticated.
  Stream<User?> get authUser {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      return firebaseUser;
    });
  }

  /// Creates a new user with the provided [email] and [password].
  ///
  /// Throws a [SignUpFailure] if an exception occurs.

  Future<UserCredential> signUp(LoginInfo info) async {
    try {
      return _firebaseAuth.createUserWithEmailAndPassword(
        email: info.email!,
        password: info.password!,
      );
    } on FirebaseAuthException catch (e) {
      throw firebaseAuthExceptionConvertToReadableError(e);
    }
  }

  Future<String> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return '';
    } on FirebaseAuthException catch (e) {
      return firebaseAuthExceptionConvertToReadableError(e);
    }
  }

  /// Starts the Sign In with Google Flow using 7.x API.
  ///
  /// Throws a [LogInWithGoogleFailure] if an exception occurs.
  Future<UserCredential> logInWithGoogle() async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        return await FirebaseAuth.instance.signInWithPopup(authProvider);
      } else {
        // Use the new 7.x API
        final googleUser = await _googleSignIn.authenticate();

        final googleAuth = googleUser.authentication;

        // Get authorization for Firebase integration
        final authorization =
            await googleUser.authorizationClient.authorizeScopes(['email']);

        final credential = firebase_auth.GoogleAuthProvider.credential(
          accessToken: authorization.accessToken,
          idToken: googleAuth.idToken,
        );
        return await _firebaseAuth.signInWithCredential(credential);
      }
    } on GoogleSignInException catch (e) {
      throw Exception(_showGoogleLoginFailure(e.code.toString()));
    } on FirebaseAuthException catch (e) {
      throw Exception(_showGoogleLoginFailure(e.code));
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
    }
  }

  /// Signs in with the provided [email] and [password].
  ///
  /// Throws a [LogInWithEmailAndPasswordFailure] if an exception occurs.
  Future<UserCredential?> logInWithEmailAndPassword(LoginInfo info) async {
    if (info.email != null && info.password != null) {
      try {
        UserCredential uc = await _firebaseAuth.signInWithEmailAndPassword(
            email: info.email!, password: info.password!);
        return uc;
      } on FirebaseAuthException catch (e) {
        throw firebaseAuthExceptionConvertToReadableError(e);
      }
    }
    return null; // Return null if email or password is null
  }

  // Future<UserCredential?> logWithPhone(String phone) async {

  //     try {
  //      _firebaseAuth.verifyPhoneNumber(
  // phoneNumber: phone,
  // verificationCompleted: (PhoneAuthCredential credential) {
  //   return credential.;
  // },
  // verificationFailed: (FirebaseAuthException e) {
  //   throw firebaseAuthExceptionConvertToReadableError(e);
  // },
  // codeSent: (String verificationId, int? resendToken) {},
  // codeAutoRetrievalTimeout: (String verificationId) {});
  //     } on FirebaseAuthException catch (e) {
  //       throw firebaseAuthExceptionConvertToReadableError(e);
  //     }
  //   }

  /// Signs out the current user which will emit
  /// [User.empty] from the [user] Stream.
  ///
  /// Throws a [LogOutFailure] if an exception occurs.
  Future<void> logOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn
            .disconnect(), // Use disconnect() for complete sign out in 7.x
      ]);
    } on Exception {
      throw LogOutFailure();
    }
  }

  Future<bool> isAuthenticated() async {
    final currentUser = _firebaseAuth.currentUser;
    return currentUser != null;
  }

  Future<void> authenticate(LoginInfo logininfo) async {
    if (logininfo.email != null) {
      try {
        logInWithEmailAndPassword(
            LoginInfo(email: logininfo.email, password: logininfo.password));
      } on FirebaseAuthException catch (e) {
        throw firebaseAuthExceptionConvertToReadableError(e);
      }
    }

    //return _firebaseAuth.signInAnonymously();
  }

  Future<String?> getUserId() async {
    return _firebaseAuth.currentUser?.uid;
  }

  String _showGoogleLoginFailure(String error) {
    switch (error) {
      case 'sign_in_failed':
        return "Google sign In failed";
      default:
        return "Google sign In failed";
    }
  }

  Future deleteAuthUser(String email, String password) async {
    try {
      AuthCredential credentials = firebase_auth.EmailAuthProvider.credential(
          email: email, password: password);

      firebase_auth.UserCredential? result =
          await _firebaseAuth.signInWithCredential(credentials);
      if (result.user != null) await result.user!.delete();
      return true;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> deleteCurrentUser() async {
    if (_firebaseAuth.currentUser != null)
      return _firebaseAuth.currentUser!.delete();
  }

  String firebaseAuthExceptionConvertToReadableError(
      FirebaseAuthException error) {
    if (!isEmpty(error.code)) {
      switch (error.code) {
        case 'network-request-failed':
          return 'Please check your network';
        case 'user-not-found':
          return 'Email was not found. Check your email and try again';
        case 'wrong-password':
          return 'Wrong password';
        case 'email-already-exists':
          return 'Email already exists';
        case 'invalid-phone-number':
        case 'phone-number-already-exists':
        default:
          return 'General Authentication Error';
      }
    }
    return "General Authentication Error";
  }
}
