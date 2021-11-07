import 'dart:async';

import 'package:authentication/authenticate/Widgets/apple_widgets.dart';
import 'package:authentication/authenticate/Widgets/google_widgets.dart';
import 'package:authentication/shared/common_auth_functions.dart';
import 'package:authentication/user/Widgets/missing_info.dart';
import 'package:authentication/user/providers/user_provider.dart';
import 'package:authentication/authenticate/models/login.dart';
import 'package:authentication/authentication.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login_form.dart';

class LoginPage extends StatelessWidget {
  final Map<String, dynamic>? moreInfo;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool registerMode;
  final Widget? logoWidget;
  LoginPage({
    Key? key,
    this.logoWidget,
    this.moreInfo,
    this.registerMode = false,
  }) : super(key: key);
  late BuildContext _context;

  @override
  Widget build(BuildContext context) {
    _context = context;
    LoginInfo _logininfo = AuthenticationController().getLoginInfoFromLocal();
    AuthUser _loginUser = AuthUser(
        id: _logininfo.uid ?? "",
        email: _logininfo.email,
        phone: _logininfo.phone);
    _logininfo.user = _loginUser;
    if (moreInfo != null && moreInfo!["missingInfo"] == true) {
      Timer.run(() {
        showDialog(
          context: context,
          builder: (ncontext) => MissingUserInfo(
            user: moreInfo!["user"],
          ),
        );
      });
    }
    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                "Login",
              ),
            ),
            body: Container(
              child: SingleChildScrollView(
                child: Column(children: [
                  Consumer(builder: (context, listen, child) {
                    var state = listen(userNotifier);

                    if (state is UserNeedsToRegister) {
                      if (!registerMode) {
                        Timer.run(() {
                          Navigator.pushReplacementNamed(
                            _context,
                            "register",
                          );
                        });
                      } else {
                        _logininfo = state.loginInfo ?? _logininfo;
                        if (!isEmpty(state.err)) {
                          Timer.run(() {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text("Login error"),
                                content: Text(state.err!),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => {
                                      Navigator.pop(context),
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          });
                        }
                      }
                      return SizedBox.shrink();
                    } else if (state is UserNeedsToLogin) {
                      _logininfo = state.loginInfo ?? _logininfo;
                      if (!isEmpty(state.err)) {
                        Timer.run(() {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text("Login error"),
                              content: Text(state.err!),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => {
                                    Navigator.pop(context),
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        });
                      }
                      return SizedBox.shrink();
                    } else {
                      return SizedBox.shrink();
                    }
                  }),
                  Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              logoWidget != null
                                  ? Padding(
                                      padding: EdgeInsets.only(bottom: 30),
                                      child: logoWidget!)
                                  : SizedBox.shrink(),
                              Container(
                                  // width:
                                  //     MediaQuery.of(context).size.width * 2 / 3,
                                  child: GoogleLoginButton(
                                outlined: true,
                                externalContext: context,
                              )),
                              SizedBox(height: 20.0),
                              Container(
                                  // width:
                                  //     MediaQuery.of(context).size.width * 2 / 3,
                                  child: AppleLoginButton(
                                outlined: true,
                                externalContext: context,
                              )),
                              SizedBox(height: 20.0),
                              Divider(),
                              if (registerMode)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  child: TextButton(
                                    child: Text(("Already have an account?"),
                                        style: TextStyle(
                                            //   color: BeStyle.darkermain,
                                            )),
                                    onPressed: () {
                                      Navigator.pushNamed(context, "login");
                                    },
                                  ),
                                ),
                              SizedBox(height: 20.0),
                              UserForm(
                                  fromRegister: registerMode,
                                  loginInfo: _logininfo,
                                  user: _logininfo.user!),
                              const SizedBox(height: 20.0),
                              registerMode
                                  ? _SignUpButton(
                                      _logininfo, _formKey, _context)
                                  : _LoginButton(
                                      _logininfo, _formKey, _context),
                              SizedBox(height: 20.0),
                              Divider(),
                              SizedBox(height: 20.0),
                            ],
                          ),
                        ),
                      ))
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final LoginInfo? loginInfo;
  final GlobalKey<FormState> _formKey;
  final BuildContext externalContext;

  const _LoginButton(
    this.loginInfo,
    this._formKey,
    this.externalContext,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.7,
        child: ElevatedButton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Login",
              ),
              SizedBox(width: 10),
              Consumer(builder: (context, ScopedReader watch, child) {
                final state = watch(authNotifierProviderForUser);
                if (state is AuthenticationInProgress)
                  return CircularProgressIndicator();
                else
                  return SizedBox.shrink();
              }),
            ],
          ),
          onPressed: () {
            if (_formKey.currentState!.validate() && loginInfo != null) {
              externalContext
                  .read(authNotifierProviderForUser.notifier)
                  .login(loginInfo!);
            }
          },
        ));
  }
}

class _SignUpButton extends StatelessWidget {
  final LoginInfo? loginInfo;
  final GlobalKey<FormState> _formKey;
  final BuildContext externalContext;

  const _SignUpButton(this.loginInfo, this._formKey, this.externalContext);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.7,
        child: ElevatedButton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Register",
              ),
              SizedBox(width: 10),
              Consumer(builder: (context, ScopedReader watch, child) {
                final state = watch(authNotifierProviderForUser);
                if (state is AuthenticationInProgress)
                  return CircularProgressIndicator();
                else
                  return SizedBox.shrink();
              }),
            ],
          ),
          onPressed: () {
            if (_formKey.currentState!.validate() && loginInfo != null) {
              externalContext
                  .read(authNotifierProviderForUser.notifier)
                  .login(loginInfo!, true);
            }
          },
        ));
  }
} // stam
