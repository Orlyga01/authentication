import 'package:authentication/shared/import_shared.dart';
import 'package:authentication/user/models/user.dart';

class LoginInfo {
  String? email;
  String? password;
  String? phone;
  String? uid;
  bool? externalLogin;
  bool? loggedOut;
  String? confirmedPassword;

  String? role; //superAdmin, admin
  LoginInfo(
      {this.email,
      this.password,
      this.phone,
      this.externalLogin = false,
      this.uid});
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );
  static final passwordErrString =
      " Pasword should have at least 8 chars, one letter and one number";
  static final emailErrString = " Email is incorrect";
  static final _passwordRegExp =
      RegExp(r'^(?=.*\d)(?=.*[a-z])[0-9a-zA-Z!.@#$%^&*?]{8,}$');

  String validate() {
    String validate;
    if (email == null && phone == null) {
      return "Email or Phone is missing";
    }
    if (email != null) {
      validate = emailValidator(email!);
      if (validate != '') return validate;
    }

    validate = passwordValidator(password);
    if (validate != '') return validate;
    return "";
  }

  String emailValidator(String value) {
    return isEmpty(value)
        ? 'Email is Empty'
        : _emailRegExp.hasMatch(value)
            ? ''
            : emailErrString;
  }

  String passwordValidator(String? value) {
    return isEmpty(value)
        ? 'Password is Empty'
        : value != AuthConstants.externalLoginPassword
            ? _passwordRegExp.hasMatch(value!)
                ? ''
                : passwordErrString
            : '';
  }

  static get empty {
    return LoginInfo();
  }

  String confirmPasswordpasswordValidator(String? value) {
    return (value == password) ? '' : ("Passwords don't match"); //
  }

  get isFromExternalLogin {
    return this.externalLogin != null && this.externalLogin == true;
  }

  LoginInfo convertFromUser(AuthUser user) {
    return LoginInfo(email: user.email, phone: user.phone, uid: user.id);
  }
}

class RegisterInfo {
  LoginInfo? loginInfo;
  String? confirmedPassword;
  AuthUser? user;

  //TODO
  String? role; //superAdmin, admin
  RegisterInfo({this.user, this.loginInfo, this.confirmedPassword});

  String validate() {
    String validate = '';
    validate = userValidator(user!);
    if (validate != '') return validate;
    validate = loginInfo!.validate();
    if (validate != '') return validate;
    validate = confirmPasswordpasswordValidator(confirmedPassword);
    if (validate != '') return validate;

    return "";
  }

  String phoneValidator(String value) {
    return isEmpty(value) ? 'Phone is Empty' : "";
  }

  String emailValidator(String value) {
    return loginInfo!.emailValidator(value);
  }

  String passwordValidator(String? value) {
    return loginInfo!.passwordValidator(value);
  }

  String confirmPasswordpasswordValidator(String? value) {
    return (value == loginInfo!.password) ? '' : ("Passwords don't match"); //
  }

  String userValidator(AuthUser value) {
    return value.validate();
  }

  static get empty {
    return RegisterInfo(loginInfo: LoginInfo.empty, user: AuthUser.empty);
  }
}
