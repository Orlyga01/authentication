import 'package:authentication/authenticate/models/login.dart';
import 'package:authentication/user/models/user.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class SetUserAfterAuthentication extends UserState {
  final User user;

  const SetUserAfterAuthentication(this.user);

  @override
  List<Object> get props => [user];

  @override
  String toString() => 'UserLoaded { user: $user }';
}

class UserLoading extends UserState {}

class UserNeedsToRegister extends UserState {
  LoginInfo? loginInfo;
  String? err;
  UserNeedsToRegister(this.loginInfo, this.err);
}

class UserNeedsToLogin extends UserState {
  LoginInfo? loginInfo;
  String? err;
  UserNeedsToLogin(this.loginInfo, this.err);
}

class UserLoadedCompleted extends UserState {}

class UserLoaded extends UserState {
  final AuthUser user;
  final String? actionOnUser;

  const UserLoaded(this.user, [this.actionOnUser]);

  @override
  List<Object> get props => [user];

  @override
  String toString() => 'UserLoaded { user: $user }';
}

class UserMissingInfo extends UserState {
  final AuthUser user;

  const UserMissingInfo(this.user);

  @override
  List<Object> get props => [user];

  @override
  String toString() => 'UserLoaded { user: $user }';
}

class UserWasChanged extends UserState {
  final AuthUser olduser;
  final AuthUser newuser;

  const UserWasChanged(this.olduser, this.newuser);

  @override
  List<Object> get props => [olduser, newuser];
}

class UserError extends UserState {
  final String message;
  UserError(this.message);
  @override
  bool operator ==(Object o) {
    if (identical(this, 0)) return true;
    return o is UserError && o.message == message;
  }

  @override
  int get hashCode => message.hashCode;
  @override
  String toString() => 'UserError { user: $message }';
}
