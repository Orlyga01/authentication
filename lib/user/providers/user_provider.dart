import 'dart:async';
import 'dart:developer';
// import 'package:bemember/helpers/onesignal_notification.dart';
// import 'package:bemember/helpers/secureStorage.dart';
import 'package:authentication/authenticate/providers/import_auth.dart';
import 'package:authentication/shared/helpers/secureStorage.dart';
import 'package:authentication/shared/import_shared.dart';
import 'package:authentication/shared/locator.dart';
import 'package:authentication/user/providers/import_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//var authNotifierProviderForUser;
final authNotifierProviderForUser =
    StateNotifierProvider<AuthenticationNotifier, AuthenticationState>((ref) {
  return AuthenticationNotifier();
});
final userNotifier = StateNotifierProvider<UserNotifier, UserState>((ref) {
  //  AuthenticationState authState = ref.watch(authNotifierProviderForUser);

  return UserNotifier(ref);
});

class UserNotifier extends StateNotifier<UserState> {
  Ref os;
  late var authState;
  //!!!! changes done here
  UserNotifier(this.os) : super(UserLoading()) {
    authChanged();
  }

  setState(UserState us) {
    state = us;
  }

  authChanged() {
    authState = os.watch(authNotifierProviderForUser);
    if (authState is Uninitialized) {
      os.read(authNotifierProviderForUser.notifier).appStarted();
    } else if (authState is NeedToLogin) {
      state = UserNeedsToLogin(authState.loginInfo, null);
    } else if (authState is NeedToRegister) {
      state = UserNeedsToRegister(authState.loginInfo, authState.err);
    } else if (authState is Authenticated) {
      try {
        setUserAfterAuthentication(authState.user, authState.logininfo);
      } catch (e) {
        print("error setUserAfterAuth:" + e.toString());
      }
    } else if (authState is AuthenticationFailed) {
      state = UserError(authState.error);
    } else if (authState is Unauthenticated) {
      if (!isEmpty(authState.logininfo.confirmedPassword))
        state = UserNeedsToRegister(authState.logininfo, authState.err);
      else
        state = UserNeedsToLogin(authState.logininfo, authState.err);
    }
  }

  Future<bool> get isLoggedOut async {
    String lo = await UserLocalStorage().getKeyValue("loggedOut");
    return (lo == '' || lo == "true");
  }

  setUserAfterAuthentication(User? muser, LoginInfo? logininfo) async {
    try {
      UserState newState =
          await UserController().setUserAfterAuthentication(muser, logininfo);
      state = newState;
      var _habits = state;
      // _habits = UserLoaded(user);
      state = _habits;
    } catch (e) {
      state = UserError(e.toString());
    }
  }
// This is to initiate the listeners

  Future<AuthUser?> addUser(AuthUser user) async {
    return UserController().addUser(user);
  }

  Future<String?> completeUserMissingInfoAfterAuthenticate(
      AuthUser user) async {
    try {
      await updateUser(user);
      UserController().setUserInController(user);
      state = UserLoaded(user, "userUpdated");
    } catch (e) {
      state = UserError(e.toString());
    }
  }

  Future<String?> updateUser(AuthUser user) async {
    try {
      AuthUser curUser = UserController().getUser;
      await UserController().updateUser(user.id, user);
      state = UserWasChanged(curUser, user);
    } catch (e) {
      state = UserError(e.toString());
    }
  }

  logOut() {
    UserController().resetUser();

    state = UserNeedsToLogin(null, null);
  }
}

class UserController {
  static final UserController _userC = new UserController._internal();
  UserController._internal();
  AuthUser _user = AuthUser.empty;
  bool _isLoggedIn = false;
  FirebaseUserRepository _userRepository =
      authUserlocator.get<FirebaseUserRepository>();
  Map<String, dynamic>? _loginSettings;
  factory UserController() {
    return _userC;
  }

  void init() {
    return;
  }

  Future<AuthUser?> isUserExists(AuthUser checkuser,
      [bool checkByPhone = false,
      bool checkByEmail = false,
      bool checkAll = true]) async {
    AuthUser? foundUser;
    if (checkAll) {
      checkByPhone = true;
      checkByEmail = true;
    }
    String userid = UserController().userid;
    if (!isEmpty(checkuser.phone) && checkByPhone)
      foundUser =
          await _userRepository.getUserByField("phone", checkuser.phone);
    if (foundUser != null && foundUser.id != userid) return foundUser;
    if (!isEmpty(checkuser.email) && checkByEmail)
      foundUser =
          await _userRepository.getUserByField("email", checkuser.email);
    if (foundUser != null && foundUser.id != userid) return foundUser;
  }

  Future<UserState> setUserAfterAuthentication(
      //REMOVE Afgter IOS
      User? authUser,
      LoginInfo? loginInfo) async {
    try {
      AuthUser? user = UserLocalStorage().getAuthUser();
      //user = null;
      if (user == null || user.email != loginInfo?.email) {
        String? userid = authUser != null
            ? authUser.uid
            : (loginInfo != null && loginInfo.uid != null)
                ? loginInfo.uid
                : null;
        if (userid != null) user = await UserController().getUserById(userid);
        //This is a new user - and we need to get him into the system
        //However, it might be that the user's information
      }
      if (user == null) {
        if (authUser == null)
          throw "User from External Authentication system is empty";
        //TOBE REMOVE
        AuthUser newUser = AuthUser(
            id: authUser.uid,
            email: isEmpty(authUser.email)
                ? loginInfo?.user?.email
                : authUser.email,
            phone: isEmpty(authUser.phoneNumber)
                ? loginInfo?.user?.phone
                : authUser.phoneNumber,
            image: isEmpty(loginInfo?.user?.image)
                ? authUser.photoURL
                : loginInfo?.user?.image,
            displayName: isEmpty(loginInfo?.user?.displayName)
                ? authUser.displayName
                : loginInfo?.user?.displayName,
            role: loginInfo?.user?.role);
        try {
          AuthUser? addedUser = await addUser(newUser);
          if (addedUser == null) throw "Couldnt create a user";
          UserController().setUserInController(addedUser);
          if (addedUser.isInfoMissing) return UserMissingInfo(addedUser);
          _isLoggedIn = true;
          UserLocalStorage().setAuthUser(addedUser);
          return UserLoaded(addedUser, "userAdded");
        } catch (e) {
          UserError(e.toString());
        }
      } else {
        user = completeMissingInfoFromLoginInfo(user, loginInfo);
        UserController().setUserInController(user);
        UserLocalStorage().setAuthUser(user);
        if (user.isInfoMissing) return UserMissingInfo(user);
        _isLoggedIn = true;

        return UserLoaded(
          user,
        );
      }
    } catch (e) {
      return UserError(e.toString());
    }
    return UserError("error");
  }

  AuthUser completeMissingInfoFromLoginInfo(
      AuthUser user, LoginInfo? loginInfouser) {
    if (loginInfouser == null) return user;
    bool needtoupdateuser = false;
    if (user.displayName.isEmptyBe && !loginInfouser.name.isEmptyBe) {
      user.displayName = loginInfouser.name;
      needtoupdateuser = true;
    }
    if (user.phone.isEmptyBe && !loginInfouser.phone.isEmptyBe) {
      user.phone = loginInfouser.phone;
      needtoupdateuser = true;
    }
    if (user.email.isEmptyBe && !loginInfouser.email.isEmptyBe) {
      user.email = loginInfouser.email;
      needtoupdateuser = true;
    }
    if (needtoupdateuser) {
      updateUser(user.id, user);
    }
    return user;
  }

  setUserInController(AuthUser user) {
    _user = user;
  }

  bool get fromApple => _user.email!.indexOf('leid.com') > -1;
  Future<AuthUser?> getUserById(String id) async {
    return _userRepository.get(id);
  }

  bool get isUserLoggedIn {
    return _isLoggedIn;
  }

  String get userid {
    if (_user == null) return "";
    return _user.id;
  }

  AuthUser get getUser {
    return _user;
  }

  Future<AuthUser?> addUser(AuthUser user) async {
    try {
      await _userRepository.add(user);
      return user;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> resetUser() async {
    await UserLocalStorage().setLogOut();
    _isLoggedIn = false;
    _user = AuthUser.empty;
  }

  // Future<AuthUser?> setUser(String userid) async {
  //   if (_user != null) return _user;
  // }

  // Future<AuthUser?> getUserByPersonID(String personid) async {
  //   return _userRepository.getUserByField("personId", personid);
  // }

  Future<void> updateUser(String id,
      [AuthUser? user, String? fieldName, dynamic? fieldValue]) async {
    await _userRepository.update(id, user, fieldName, fieldValue);
    //The current user was changed, then we need to update the global _user
    if (id == userid) {
      if (fieldName != null) {
        _user.toJson()[fieldName] = fieldValue;
        UserLocalStorage().setAuthUser(_user);
      } else if (user != null) {
        _user = user;
      }
      //TODO need to think if this is needed:
      // UserLocalStorage().setLoginData(LoginInfo().convertFromUser(_user));

      // and we need to update the local storage
    }
  }

  Future<List<AuthUser>> getUsersByListOfIds(List<String> usersList) async {
    return await _userRepository.getUsersByListOfIds(usersList);
  }

  Future<List<String>> getUserPlayerIds(userid) async {
    try {
      AuthUser? destuser = await UserController().getUserById(userid);
      if (destuser == null) {
        print("couldnt find user $destuser");
        return [];
      }
      return !isEmpty(destuser.oneSignalPlayers)
          ? destuser.oneSignalPlayers!.split(AuthConstants.arrayDevider)
          : [];
    } catch (e) {
      throw e;
    }
  }

  bool get isUserSuperAdmin {
    return _user.role == AuthConstants.superAdmin;
  }

  set loginSettings(Map<String, dynamic> settings) => _loginSettings = settings;
  dynamic getSettings(String setting) {
    return _loginSettings?[setting];
  }

  Future<void> delete(id) async {
    return _userRepository.delete(getUser.id);
  }
}
