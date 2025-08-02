import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:authentication/authentication.dart';
import 'package:authentication/shared/helpers/secureStorage.dart';
import 'package:authentication/authenticate/models/oauth_models.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  // Repository will be created dynamically with provided configuration

  factory AuthenticationController() {
    return _groupC;
  }
  bool _fromApple = false;
  bool get fromApple => _fromApple;
  Future<AuthenticationState> checkCredentials(LoginInfo logininfo,
      [bool fromRegister = false, bool authByPhone = false]) async {
    // This method is now for email/password authentication only
    // Since we removed Firebase, this would need to be handled by your external system
    try {
      // You would implement your own email/password authentication here
      // For now, return an error indicating this needs to be implemented
      return AuthenticationFailed(
          "Email/password authentication not implemented - handle via your external system",
          logininfo);
    } catch (e) {
      return AuthenticationFailed(e.toString(), logininfo);
    }
  }

  bool isDifferentLoginUser(String newUserId) {
    LoginInfo oldLogin = UserLocalStorage().getLoginData();
    //If its the same user as before login
    return oldLogin.uid != newUserId;
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
      // Create repository - configuration comes from AuthConfig
      final repository = OAuthAuthRepository();
      final appleResult = await repository.signInWithApple();

      final loginInfo = convertAppleOAuthToLoginInfo(appleResult);
      loginInfo.loginType = "apple";

      // Save to local storage if needed
      if (isDifferentLoginUser(appleResult.userIdentifier)) {
        await UserLocalStorage().setLoginData(loginInfo);
      }
      await UserLocalStorage().setKeyValue("loggedOut", "false");

      return Authenticated(null, loginInfo); // No Firebase user, just LoginInfo
    } catch (e) {
      return AuthenticationFailed(e.toString());
    }
  }

  LoginInfo convertAppleOAuthToLoginInfo(AppleOAuthResult appleResult) {
    return LoginInfo(
      email: appleResult.email,
      uid: appleResult.userIdentifier,
      name: appleResult.displayName,
      externalLogin: true,
    );
  }

  LoginInfo convertGoogleOAuthToLoginInfo(GoogleOAuthResult googleResult) {
    return LoginInfo(
      email: googleResult.email,
      uid: googleResult.id,
      name: googleResult.displayName,
      externalLogin: true,
    );
  }

  Future<void> afterExternalLogin(LoginInfo loginInfo) async {
    //check if user exists in the app

    await UserLocalStorage().setLoginData(loginInfo);
    UserLocalStorage().setKeyValue("loggedOut", "false");
  }

  Future<AuthenticationState> googleLogin(
      {bool saveToLocalStorage = true}) async {
    try {
      // Create repository - configuration comes from AuthConfig
      final repository = OAuthAuthRepository();
      final googleResult = await repository.signInWithGoogle();

      final loginInfo = convertGoogleOAuthToLoginInfo(googleResult);
      loginInfo.loginType = "google";

      if (saveToLocalStorage) {
        // Save to local storage if needed
        if (isDifferentLoginUser(googleResult.id)) {
          await UserLocalStorage().setLoginData(loginInfo);
        }
        await UserLocalStorage().setKeyValue("loggedOut", "false");
      }

      return Authenticated(null, loginInfo); // No Firebase user, just LoginInfo
    } catch (e) {
      return AuthenticationFailed(e.toString(), null);
    }
  }

  LoginInfo getLoginInfoFromLocal() {
    return UserLocalStorage().getLoginData();
  }

  Future<String> sendResetPassword(email) async {
    // Password reset would need to be handled by your external system
    return "Password reset not implemented - handle via your external system";
  }
}
