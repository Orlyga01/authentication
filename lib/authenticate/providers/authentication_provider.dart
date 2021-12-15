import 'dart:developer';
import 'dart:io';
import 'dart:async';
import 'package:authentication/authentication.dart';
import 'package:authentication/shared/helpers/secureStorage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthenticationNotifier extends StateNotifier<AuthenticationState> {
  AuthenticationNotifier() : super(Uninitialized());

  Future<void> appStarted() async {
    LoginInfo? logininfo;

    try {
      await UserLocalStorage().init();
      logininfo = UserLocalStorage().getLoginData();
      if (logininfo.loggedOut == false) {
        Authenticated(null, logininfo);
        return;
      }
      if (logininfo.uid == null || logininfo.loggedOut == null) {
        state = NeedToRegister(null);
        return;
      } else if (logininfo.loggedOut!) {
        state = NeedToLogin(logininfo);
        return;
      }
      login(logininfo, keepExternal: true);
    } catch (e) {
      state = AuthenticationFailed(e.toString(), logininfo);
    }
  }

  afterSuccessfulLogin() {
    state = AfterSuccessfulLogin();
  }

  Future<void> login(LoginInfo logininfo,
      {bool fromRegister = false, bool keepExternal = false}) async {
    state = AuthenticationInProgress();
    if (!keepExternal) logininfo.externalLogin = false;
    if (logininfo.loggedOut == false && !fromRegister) {
      state = Authenticated(null, logininfo);
    }
    await UserLocalStorage().setLoginData(logininfo);
    if (logininfo.email != null && logininfo.password != null)
      state = await AuthenticationController()
          .checkCredentials(logininfo, fromRegister);
    else
      state = Unauthenticated("", logininfo);
  }

  Future<void> GoogleLogin() async {
    state = GoogleAuthenticationInProgress();
    state = await AuthenticationController().googleLogin();
  }

  Future<void> AppleLogin() async {
    state = AppleAuthenticationInProgress();
    state = await AuthenticationController().appleLogin();
  }

  userWantsToLogin() {
    state = NeedToLogin(null);
  }

  resetState() {
    state = idleState();
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
      log("after credentials success");
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

  Future<AuthenticationState> appleLogin() async {
    if (!await SignInWithApple.isAvailable()) {
      return AuthenticationFailed(
        'This Device is not eligible for Apple Sign in',
      ); //Break from the program
    }

    try {
      AuthorizationCredentialAppleID credential =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          // TODO: Set the `clientId` and `redirectUri` arguments to the values you entered in the Apple Developer portal during the setup
          clientId: 'OrlyReznikAppleLogin',
          redirectUri: Uri.parse(
            'https://com.bemember.glitch.me/callbacks/sign_in_with_apple',
          ),
        ),
      );
      final signInWithAppleEndpoint = Uri(
        scheme: 'https',
        host: 'com.bemember.glitch.me',
        path: '/sign_in_with_apple',
        queryParameters: <String, String>{
          'code': credential.authorizationCode,
          if (credential.givenName != null) 'firstName': credential.givenName!,
          if (credential.familyName != null) 'lastName': credential.familyName!,
          'useBundleId': Platform.isIOS || Platform.isMacOS ? 'true' : 'false',
          if (credential.state != null) 'state': credential.state!,
        },
      );
      final session = await http.Client().post(
        signInWithAppleEndpoint,
      );
      final oAuthCredential = OAuthProvider('apple.com').credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

// Use the OAuthCredential to sign in to Firebase.
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(oAuthCredential);
      if (userCredential != null) {
        await afterExternalLogin(userCredential);
        return Authenticated(userCredential.user!, null);
      } else {
        return AuthenticationFailed("Apple Login failed");
      }
    } catch (e) {
      return AuthenticationFailed(e.toString());
    }
  }

  LoginInfo convertUserCredentialsToLoginInfo(
      UserCredential userc, bool exteranLogin) {
    return LoginInfo(
        email: userc.user!.email,
        uid: userc.user!.uid,
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

  Future<AuthenticationState> googleLogin() async {
    String? personid;
    try {
      UserCredential userc = await _authRepository.logInWithGoogle();
      if (userc != null) {
        await afterExternalLogin(userc);

        return Authenticated(userc.user!, null);
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
