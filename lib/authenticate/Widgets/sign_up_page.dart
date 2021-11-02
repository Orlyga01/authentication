import 'dart:async';

import 'package:bemember/helpers/device.dart';
import 'package:authentication/authenticate/models/login.dart';
import 'package:bemember/models/user.dart';
import 'package:bemember/providers/authentication/login/sign_up_cubit.dart';
import 'package:bemember/screens/login/sign_up_form.dart';
import 'package:bemember/shared/widgets/apple_widgets.dart';
import 'package:bemember/shared/widgets/google_widgets.dart';
import 'package:bemember/shared/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:bemember/shared/import_to_all_views.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:bemember/providers.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

final _registrationStateNotifier =
    StateNotifierProvider<SignUpNotifier, SignUpState>((ref) {
  return SignUpNotifier();
});

class SignUpPage extends StatelessWidget {
  final String? thisDevicePhoneNumber;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  SignUpPage({Key? key, this.thisDevicePhoneNumber}) : super(key: key);

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => SignUpPage());
  }

  late BuildContext _context;
  @override
  Widget build(BuildContext context) {
    _context = context;
    RegisterInfo registerinfo =
        RegisterInfo(user: AuthUser.empty, loginInfo: LoginInfo.empty);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(title: const Text('Sign Up')),
        body: Consumer(builder: (context, ScopedReader watch, child) {
          AsyncValue<ConnectivityResult> connectivity =
              watch(connectivityProvider);
          NetworkProvider().pageAlertNoConnectivity(context, connectivity);
          return Consumer(
            builder: (context, watch, child) {
              var state = watch(_registrationStateNotifier);
              if (state is SignUpFailed) {
                Timer.run(() {
                  showMessage(state.error, _context);
                });
              } else if (state is RegisterationCompleted) {
                afterAuthenticated(_context, state.registerInfo.user!.id);
              }
              return SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width,
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: IntrinsicHeight(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            LogoWidget(boxSize: 80),
                            SizedBox(width: 40),
                            GoogleLoginButton(
                                outlined: true, externalContext: context),
                            SizedBox(height: 20),
                            AppleLoginButton(
                              outlined: true,
                              externalContext: context,
                            ),
                            TextButton(
                              child: Text(("Already have an account?"),
                                  style: TextStyle(
                                    color: BeStyle.darkermain,
                                  )),
                              onPressed: () {
                                context
                                    .read(authNotifierProvider.notifier)
                                    .userWantsToLogin();
                                Navigator.pushNamed(context, "login");
                              },
                            ),
                            SizedBox(height: 30),
                            Expanded(
                              child: Form(
                                key: _formKey,
                                child: SignUpForm(
                                    formKey: _formKey,
                                    registerinfo: registerinfo,
                                    thisDevicePhoneNumber:
                                        thisDevicePhoneNumber),
                              ),
                            ),
                            SizedBox(height: 20),
                            Container(
                              width: getSafeAreaWidth70per(context),
                              child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState != null &&
                                        _formKey.currentState!.validate()) {
                                      context
                                          .read(_registrationStateNotifier
                                              .notifier)
                                          .signUpFormSubmitted(registerinfo);
                                    }
                                  },
                                  child: Text("Register")),
                            ),
                            Expanded(child: SizedBox.shrink()),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  void submitForm(context, registerinfo) {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      context
          .read(_registrationStateNotifier.notifier)
          .signUpFormSubmitted(registerinfo);
    }
  }
}
