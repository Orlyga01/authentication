import 'dart:async' show Future;
import 'dart:convert';
import 'package:authentication/authenticate/models/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserLocalStorage {
  late SharedPreferences _storage;
  static final UserLocalStorage _cmC = new UserLocalStorage._internal();
  UserLocalStorage._internal();
  factory UserLocalStorage() {
    return _cmC;
  }

  Future init() async {
    _storage = await SharedPreferences.getInstance();
    //await _storage.clear();
  }

  Future<String> getKeyValue(String key, [String? defValue]) async {
    try {
      return _storage.getString(key) ?? defValue ?? "";
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool?> setKeyValue(String key, String value) async {
    if (value != "") {
      return _storage.setString(key, value);
    }
  }

  Future setLanguage(String locale) async {
    await setKeyValue("languageCode", locale);
  }

  Future<void> setLogOut() async {
    await remove("uid");
    await setKeyValue("loggedOut", true.toString());
  }

  Future<void> setLoginData(LoginInfo loginInfo) async {
    if (loginInfo.email != null) {
      await setKeyValue("email", loginInfo.email!);
    }
    if (loginInfo.name != null) {
      await setKeyValue("name", loginInfo.name!);
    }
    if (loginInfo.phone != null) {
      await setKeyValue("phone", loginInfo.phone!);
    }
    if (loginInfo.password != null) {
      await setKeyValue("pswd", loginInfo.password!);
    }
    if (loginInfo.externalLogin != null) {
      await setKeyValue("externalLogin", loginInfo.externalLogin!.toString());
      if (loginInfo.externalLogin == true) await setKeyValue("pswd", "");
    }

    if (loginInfo.uid != null) {
      await setKeyValue("uid", loginInfo.uid!);
    }
  }

  LoginInfo getLoginData() {
    try {
      LoginInfo loginInfo = LoginInfo();
      loginInfo.email = _storage.getString(
        "email",
      );
      loginInfo.name = _storage.getString(
        "name",
      );
      loginInfo.phone = _storage.getString(
        "phone",
      );
      if (loginInfo.email == null && loginInfo.phone == null) {
        return LoginInfo();
      }
      loginInfo.password = _storage.getString(
        "pswd",
      );
      loginInfo.externalLogin = _storage.getString("externalLogin") == "true";

      String loggedOUt = _storage.getString(
        "loggedOut",
      )!;
      if (loggedOUt != null) {
        loginInfo.loggedOut = loggedOUt == "true";
      }
      loginInfo.uid = _storage.getString(
        "uid",
      );
      return loginInfo;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> remove(String key) {
    return setKeyValue(key, "");
  }

  Future<void> mapToStorage(String key, Map<String, dynamic> map) {
    return setKeyValue(key, jsonEncode(map));
  }

  Future<Map<String, dynamic>?> storageToMap(
      String key, Function? mconvert) async {
    Map<String, dynamic>? retmap = Map();
    String? json = await UserLocalStorage().getKeyValue(key);
    if (json != null && json.length > 0) {
      Map<String, dynamic> tmp = jsonDecode(json);
      if (tmp.length == 0) return null;
      if (mconvert != null) {
        tmp.forEach((key, value) {
          retmap[key] = mconvert(value);
        });
        return retmap;
      } else {
        return tmp;
      }
    }
  }
}
