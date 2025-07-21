import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:authentication/authentication.dart';
import 'package:authentication/shared/common_auth_functions.dart';
import 'package:authentication/shared/helpers/secureStorage.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthenticationNotifier extends StateNotifier<AuthenticationState> {
  AuthenticationNotifier() : super(Uninitialized());

  void setStateIfChanged(AuthenticationState newState) {
    if (state.runtimeType != newState.runtimeType || state != newState) {
      state = newState;
    }
  }

  Future<void> appStarted() async {
    LoginInfo? logininfo;

    try {
      await UserLocalStorage().init();
      logininfo = UserLocalStorage().getLoginData();
      if (logininfo.loggedOut == false) {
        setStateIfChanged(Authenticated(null, logininfo));
        return;
      }
      if (logininfo.uid == null || logininfo.loggedOut == null) {
        setStateIfChanged(NeedToRegister(null));
        return;
      } else if (logininfo.loggedOut!) {
        setStateIfChanged(NeedToLogin(logininfo));
        return;
      }
      login(logininfo, keepExternal: true);
    } catch (e) {
      setStateIfChanged(AuthenticationFailed(e.toString(), logininfo));
    }
  }

  afterSuccessfulLogin() {
    setStateIfChanged(AfterSuccessfulLogin());
  }

  Future<void> login(LoginInfo logininfo,
      {bool fromRegister = false, bool keepExternal = false}) async {
    setStateIfChanged(AuthenticationInProgress());
    if (!keepExternal) logininfo.externalLogin = false;
    if (logininfo.loggedOut == false && !fromRegister) {
      setStateIfChanged(Authenticated(null, logininfo));
    }
    await UserLocalStorage().setLoginData(logininfo);
    if (logininfo.email != null && logininfo.password != null)
      setStateIfChanged(await AuthenticationController()
          .checkCredentials(logininfo, fromRegister));
    else
      setStateIfChanged(Unauthenticated("", logininfo));
  }

  Future<void> GoogleLogin({bool saveToLocalStorage = true}) async {
    setStateIfChanged(GoogleAuthenticationInProgress());
    setStateIfChanged(await AuthenticationController()
        .googleLogin(saveToLocalStorage: saveToLocalStorage));
  }

  Future<void> AppleLogin() async {
    setStateIfChanged(AppleAuthenticationInProgress());
    setStateIfChanged(await AuthenticationController().appleLogin());
  }

  userWantsToLogin() {
    setStateIfChanged(NeedToLogin(null));
  }

  resetState() {
    setStateIfChanged(idleState());
  }
}

class AuthenticationController {
  static final AuthenticationController _groupC =
      new AuthenticationController._internal();
  AuthenticationController._internal();
  FirebaseAuthRepository _authRepository = FirebaseAuthRepository();

  factory AuthenticationController() {
    return _groupC;
  }
  bool _fromApple = false;
  bool get fromApple => _fromApple;
  Future<AuthenticationState> checkCredentials(LoginInfo logininfo,
      [bool fromRegister = false, bool authByPhone = false]) async {
    UserCredential? userc;
    //That means
    try {
      if (fromRegister)
        userc = await _authRepository.signUp(logininfo);
      else {
        // String? phone = logininfo.phone ?? logininfo.user?.phone;
        // if (phone != null && authByPhone)
        //   userc = await _authRepository.loginByPhone(phone);
        userc = await _authRepository.logInWithEmailAndPassword(logininfo);
      }
      logininfo.uid = userc!.user!.uid;
      //If its the same user as before login
      if (isDifferentLoginUser(userc))
        await UserLocalStorage()
            .setLoginData(convertUserCredentialsToLoginInfo(userc, false));
      await UserLocalStorage().setKeyValue("loggedOut", "false");
      return Authenticated(userc.user!, logininfo);
    } catch (e) {
      return AuthenticationFailed(e.toString(), logininfo);
    }
  }

  bool isDifferentLoginUser(UserCredential userc) {
    LoginInfo oldLogin = UserLocalStorage().getLoginData();
    //If its the same user as before login
    return oldLogin.uid != userc.user!.uid;
  }

  deleteCurrentUser() {
    _authRepository.deleteCurrentUser();
  }

  Future<void> deleteAuthUser(String email, String password) async {
    return _authRepository.deleteAuthUser(email, password);
  }

  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<AuthenticationState> appleLogin() async {
    try {
      OAuthCredential oAuthCredential = await signInWithApple();

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(oAuthCredential);
      if (userCredential != null) {
        final loginInfo =
            convertUserCredentialsToLoginInfo(userCredential, true);
        loginInfo.loginType = "apple";
        return Authenticated(userCredential.user!, loginInfo);
      } else {
        return AuthenticationFailed("Apple Login failed");
      }
    } catch (e) {
      return AuthenticationFailed(e.toString());
    }
  }

  Future<OAuthCredential> signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    return oauthCredential;
  }

  LoginInfo convertUserCredentialsToLoginInfo(
      UserCredential userc, bool exteranLogin) {
    return LoginInfo(
      email: userc.user!.email,
      uid: userc.user!.uid,
      name: userc.user!.displayName,
      phone: userc.user!.phoneNumber,
      externalLogin: exteranLogin,
    );
  }

  Future<void> afterExternalLogin(UserCredential userc) async {
    String? personid;
    //check if user exists in the app

    await UserLocalStorage()
        .setLoginData(convertUserCredentialsToLoginInfo(userc, true));

    UserLocalStorage().setKeyValue("loggedOut", "false");
  }

  Future<AuthenticationState> googleLogin(
      {bool saveToLocalStorage = true}) async {
    String? personid;
    try {
      UserCredential userc = await _authRepository.logInWithGoogle();
      if (userc != null) {
        final loginInfo = convertUserCredentialsToLoginInfo(userc, true);
        loginInfo.loginType = "google";
        return Authenticated(userc.user!, loginInfo);
        // } else if (saveToLocalStorage) {
        //   await afterExternalLogin(userc);
        // }
        // return Authenticated(userc.user!, null);
      } else {
        return AuthenticationFailed("Google Login failed", null);
      }
    } catch (e) {
      return AuthenticationFailed(e.toString(), null);
    }
  }

  LoginInfo getLoginInfoFromLocal() {
    return UserLocalStorage().getLoginData();
  }

  Future<String> sendResetPassword(email) async {
    return _authRepository.resetPassword(email);
  }
}
