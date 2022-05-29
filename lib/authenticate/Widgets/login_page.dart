import 'dart:async';
import 'package:authentication/authenticate/Widgets/apple_widgets.dart';
import 'package:authentication/authenticate/Widgets/google_widgets.dart';
import 'package:authentication/authenticate/models/common_models.dart';
import 'package:authentication/shared/common_auth_functions.dart';
import 'package:authentication/user/Widgets/missing_info.dart';
import 'package:authentication/authentication.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login_form.dart';

class LoginPage extends StatelessWidget {
  final Map<String, dynamic>? moreInfo;
  final LoginInfo? loginInfo;
  final List<CustomInputFields>? customFields;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool? registerMode;
  final Function(LoginInfo)? doBeforeRegister;
  final Widget? logoWidget;
  LoginPage({
    Key? key,
    this.logoWidget,
    this.moreInfo,
    this.registerMode,
    this.loginInfo,
    this.customFields,
    this.doBeforeRegister,
  }) : super(key: key);
  late BuildContext _context;

  @override
  Widget build(BuildContext context) {
    if (moreInfo != null && moreInfo?["registerMode"] == false) {
      registerMode = false;
    }
    _context = context;
// this is sent from the joinmom flow
    LoginInfo _logininfo = loginInfo != null
        ? loginInfo!
        : AuthenticationController().getLoginInfoFromLocal();
    AuthUser _loginUser = AuthUser(
        id: _logininfo.uid ?? "",
        displayName: _logininfo.name,
        email: _logininfo.email,
        phone: _logininfo.phone);
    _logininfo.user = _loginUser;
    if (moreInfo != null &&
        moreInfo!["missingInfo"] == true &&
        !AuthenticationController().fromApple) {
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
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Center(
                child: Text(
              "Login".ctr(),
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
                              title: Text("Login error".ctr()),
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
                    }
                    return SizedBox.shrink();
                  } else if (state is UserNeedsToLogin) {
                    _logininfo = state.loginInfo ?? _logininfo;
                    if (!isEmpty(state.err)) {
                      Timer.run(() {
                        showDialog(
                          context: context,
                          builder: (mcontext) => AlertDialog(
                            title: Text("Login error".ctr()),
                            content: Text(state.err!),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => {
                                  Navigator.pop(mcontext),
                                },
                                child: Text('OK'.ctr()),
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
                                title: Text("Error".ctr()),
                                content: Text("Error while logging in: ".ctr() +
                                    state.message.ctr()),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => {
                                      context
                                          .read(authNotifierProviderForUser
                                              .notifier)
                                          .resetState(),
                                      Navigator.pop(mcontext),
                                    },
                                    child: Text('OK'.ctr()),
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
                                      text:
                                          'Don\'t have an account yet? '.ctr(),
                                      style: new TextStyle(
                                          color: Colors.black, fontSize: 14),
                                    ),
                                    new TextSpan(
                                      text: 'Lets create one'.ctr(),
                                      style: new TextStyle(
                                          color: Colors.blue, fontSize: 14),
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
                            if (registerMode == true)
                              OutlinedButton(
                                key: Key("haveAccount"),
                                child: Text(("Already have an account?".ctr()),
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
                              user: _logininfo.user!,
                              customFields: customFields,
                            ),
                            const SizedBox(height: 20.0),
                            registerMode == true
                                ? _SignUpButton(_logininfo, _formKey, _context,
                                    doBeforeRegister)
                                : _LoginButton(_logininfo, _formKey, _context),
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
          key: Key("login_btn"),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Login".ctr(),
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
  final Function(LoginInfo)? doBeforeRegister;

  const _SignUpButton(this.loginInfo, this._formKey, this.externalContext,
      this.doBeforeRegister);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.7,
        child: ElevatedButton(
          key: Key("register_btn"),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Register".ctr(),
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
          onPressed: () async {
            if (_formKey.currentState!.validate() && loginInfo != null) {
              AuthUser? foundUser = await UserController()
                  .isUserExists(loginInfo!.convertToAuthUser());
              if (foundUser != null) {
                Timer.run(() {
                  showDialog(
                      context: context,
                      builder: (mcontext) => AlertDialog(
                            title: Text("Registration Error".ctr()),
                            content: Text(
                                "Email or phone are already in use, would you like to login?"
                                    .ctr()),
                            actions: <Widget>[
                              TextButton(
                                key: Key("gotoLogin"),
                                onPressed: () {
                                  Navigator.pop(mcontext);
                                  Navigator.pushNamed(context, "login",
                                      arguments: {
                                        "registerMode": false,
                                        "logininfo": loginInfo!
                                      });
                                },
                                child: Text('Go to Login page'.ctr()),
                              ),
                              TextButton(
                                key: Key("stay"),
                                onPressed: () => {
                                  Navigator.pop(mcontext),
                                },
                                child: Text('Stay here'.ctr()),
                              ),
                            ],
                          ));
                });
              } else {
                if (doBeforeRegister != null && loginInfo != null) {
                  doBeforeRegister!(loginInfo!);
                }
                externalContext
                    .read(authNotifierProviderForUser.notifier)
                    .login(loginInfo!, fromRegister: true);
              }
            }
          },
        ));
  }
} // stam
