import 'package:authentication/user/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'import_auth.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

class Uninitialized extends AuthenticationState {}

class Authenticated extends AuthenticationState {
  final User? user;
  final LoginInfo? logininfo;

  const Authenticated(
    this.user,
    this.logininfo,
  );

 
  @override
  String toString() => 'Authenticated { userId: $user }';
}

class SignUpCompleted extends AuthenticationState {
  final AuthUser user;

  const SignUpCompleted(this.user);

  @override
  List<Object> get props => [user];

  @override
  String toString() => 'Authenticated { userId: $user }';
}

class Unauthenticated extends AuthenticationState {
  final String err;
  final LoginInfo? logininfo;
  const Unauthenticated(this.err, this.logininfo);
  @override
  List<Object> get props => [
        errorTextConfiguration,
        {logininfo}
      ];

  @override
  String toString() => 'Authenticated { userId: $err }';
}

class NeedToLogin extends AuthenticationState {
  LoginInfo? loginInfo;
  String? err;
  NeedToLogin(this.loginInfo, [this.err]);
  @override
  String toString() => 'NeedToLogin ';
}

class NeedToRegister extends AuthenticationState {
  LoginInfo? loginInfo;
  String? err;
  NeedToRegister(this.loginInfo, [this.err]);
}

class SignUpInProgress extends AuthenticationState {}

class AuthenticationFailed extends AuthenticationState {
  LoginInfo? loginInfo;
  String error;
  AuthenticationFailed(this.error, [this.loginInfo]);
}

class AuthenticationInProgress extends AuthenticationState {}

class AppleAuthenticationInProgress extends AuthenticationState {}

class GoogleAuthenticationInProgress extends AuthenticationState {}

class UserLoggedOut extends AuthenticationState {}

class AfterSuccessfulLogin extends AuthenticationState {}

class idleState extends AuthenticationState {}
