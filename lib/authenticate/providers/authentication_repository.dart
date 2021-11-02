import 'dart:async';

import 'package:authentication/shared/import_shared.dart';

import 'import_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
//import 'package:mobile_number/mobile_number.dart';

class SignUpFailure implements Exception {}

class LogInWithEmailAndPasswordFailure implements Exception {}

class LogOutFailure implements Exception {}

class FirebaseAuthRepository {
  /// {@macro authentication_repository}
  FirebaseAuthRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.standard();
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

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

  /// Starts the Sign In with Google Flow.
  ///
  /// Throws a [LogInWithGoogleFailure] if an exception occurs.
  Future<UserCredential> logInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      final googleAuth = await googleUser?.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      return await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw Exception(_showGoogleLoginFailure(e.code));
    }
  }

  /// Signs in with the provided [email] and [password].
  ///
  /// Throws a [LogInWithEmailAndPasswordFailure] if an exception occurs.
  Future<UserCredential?> logInWithEmailAndPassword(LoginInfo info) async {
    if (info.email != null) {
      try {
        UserCredential uc = await _firebaseAuth.signInWithEmailAndPassword(
            email: info.email!, password: info.password!);
        return uc;
      } on FirebaseAuthException catch (e) {
        throw firebaseAuthExceptionConvertToReadableError(e);
      }
    }
  }

  /// Signs out the current user which will emit
  /// [User.empty] from the [user] Stream.
  ///
  /// Throws a [LogOutFailure] if an exception occurs.
  Future<void> logOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
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

  // Future<String?> initMobileNumberState() async {
  //   if (!await MobileNumber.hasPhonePermission) {
  //     await MobileNumber.requestPhonePermission;
  //   }
  //   String? mobileNumber = '';
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   try {
  //     mobileNumber = await MobileNumber.mobileNumber;
  //     return mobileNumber;
  //   } on PlatformException catch (e) {
  //     return "Failed to get mobile number because of '${e.message}'";
  //   }
  // }

  String firebaseAuthExceptionConvertToReadableError(
      FirebaseAuthException error) {
    if (!isEmpty(error.code)) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Wrong password provided for that user.';
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
