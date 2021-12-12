import 'dart:async';

import 'package:authentication/authenticate/Widgets/apple_widgets.dart';
import 'package:authentication/authenticate/Widgets/google_widgets.dart';
import 'package:authentication/shared/common_auth_functions.dart';
import 'package:authentication/user/Widgets/missing_info.dart';
import 'package:authentication/user/providers/user_provider.dart';
import 'package:authentication/authenticate/models/login.dart';
import 'package:authentication/authentication.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login_form.dart';

class LoginPage extends StatelessWidget {
  final Map<String, dynamic>? moreInfo;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool? registerMode;
  final Widget? logoWidget;
  LoginPage({
    Key? key,
    this.logoWidget,
    this.moreInfo,
    this.registerMode,
  }) : super(key: key);
  late BuildContext _context;

  @override
  Widget build(BuildContext context) {
    if (moreInfo != null && moreInfo?["registerMode"] == false) {
      registerMode = false;
    }
    _context = context;
    LoginInfo _logininfo = AuthenticationController().getLoginInfoFromLocal();
    AuthUser _loginUser = AuthUser(
        id: _logininfo.uid ?? "",
        displayName: _logininfo.name,
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
              title: Center(
                  child: Text(
                "Login",
              )),
            ),
            body: Container(
              child: SingleChildScrollView(
                child: Column(children: [
                  Consumer(builder: (context, listen, child) {
                    var state = listen(userNotifier);

                    if (state is UserNeedsToRegister) {
                      //if regsiterMode = true, then we are already in the register page, and if the registerMode is false, that means that we force to continue even though the local storage is empty
                      if (registerMode == null) {
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
                              builder: (mcontext) => AlertDialog(
                                title: Text("Login error"),
                                content: Text(state.err!),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => {
                                      // context
                                      //     .read(userNotifier.notifier)
                                      //     .setState(registerMode != true
                                      //         ? UserNeedsToRegister(
                                      //             _logininfo, null)
                                      //         : UserNeedsToLogin(
                                      //             _logininfo, null)),
                                      Navigator.pop(mcontext),
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
                            builder: (mcontext) => AlertDialog(
                              title: Text("Login error"),
                              content: Text(state.err!),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => {
                                    Navigator.pop(mcontext),
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        });
                      }
                      return SizedBox.shrink();
                    } else if (state is UserError) {
                      Timer.run(() {
                        showDialog(
                            builder: (mcontext) => AlertDialog(
                                  title: Text("Error"),
                                  content: Text("Error while logging in: " +
                                      state.message),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => {
                                        context
                                            .read(authNotifierProviderForUser
                                                .notifier)
                                            .resetState(),
                                        Navigator.pop(mcontext),

                                        //  Navigator.pushNamed(externalContext, "login"),
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                            context: context);
                      });

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
                              if (registerMode != true)
                                new RichText(
                                  text: new TextSpan(
                                    children: [
                                      new TextSpan(
                                        text: 'Don\'t have an account yet? ',
                                        style:
                                            new TextStyle(color: Colors.black, fontSize: 14),
                                      ),
                                      new TextSpan(
                                        text: 'Lets create one',
                                        style:
                                            new TextStyle(color: Colors.blue, fontSize: 14),
                                        recognizer: new TapGestureRecognizer()
                                          ..onTap = () async {
                                            Navigator.pushReplacementNamed(
                                              context,
                                              "register",
                                            );
                                          },
                                      ),
                                    ],
                                  ),
                                ),
                              // Row(
                              //   children: [
                              //     Padding(
                              //       padding: const EdgeInsets.symmetric(
                              //           horizontal: 5),
                              //       child: Text("Don't have an account yet?"),
                              //     ),
                              //     InkWell(
                              //       onTap: () async {
                              //         Navigator.pushNamed(
                              //           context,
                              //           "register",
                              //         );
                              //       },
                              //       child: Text("Lets crate a new account", style: (color: )),
                              //     )
                              //   ],
                              // ),
                              if (registerMode == true)
                                TextButton(
                                  child: Text(("Already have an account?"),
                                      style: TextStyle(
                                          //   color: BeStyle.darkermain,
                                          )),
                                  onPressed: () {
                                    Navigator.pushNamed(context, "login",
                                        arguments: {"registerMode": false});
                                  },
                                ),
                              SizedBox(height: 10.0),
                              UserForm(
                                  fromRegister: registerMode ?? false,
                                  loginInfo: _logininfo,
                                  user: _logininfo.user!),
                              const SizedBox(height: 20.0),
                              registerMode == true
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
                  .login(loginInfo!, fromRegister: true);
            }
          },
        ));
  }
} // stam
