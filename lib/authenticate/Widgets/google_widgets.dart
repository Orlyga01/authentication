import 'dart:async';
import 'package:authentication/authenticate/providers/authentication_state.dart';
import 'package:authentication/user/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoogleLoginButton extends StatelessWidget {
  final bool outlined;
  final Color? mainColor;
  final Color? textColor;
  final BuildContext? outerContext;

  final BuildContext externalContext;
  const GoogleLoginButton(
      {Key? key,
      this.outlined = false,
      required this.externalContext,
      this.mainColor = Colors.grey,
      this.textColor = Colors.grey,
      this.outerContext})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
                                               // String? screen = currentPage(GlobalKey<NavigatorState>()),

    return Consumer(builder: (context, ScopedReader watch, child) {
      final state = watch(authNotifierProviderForUser);
      if (state is GoogleUnauthenticated) {
        Timer.run(() {
          showDialog(
              builder: (mcontext) => AlertDialog(
                    title: Text("Google Login Error"),
                    content: Text(
                        "Google was not able to log you in. Please contact support" +
                            state.err),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => {

                          Navigator.pop(mcontext),
                          Navigator.pushNamed(externalContext, "login"),
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
              context: externalContext);
        });

        return SizedBox.shrink();
      }

      return OutlinedButton(
          style: OutlinedButton.styleFrom(
              backgroundColor: !outlined ? mainColor : Colors.white),
          key: Key('loginForm_googleLogin_raisedButton'),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sign in with Google',
                style: TextStyle(
                  color: outlined ? textColor : Colors.white,
                ),
              ),
              SizedBox(width: 10),
              Consumer(builder: (context, ScopedReader watch, child) {
                final state = watch(authNotifierProviderForUser);
                if (state is GoogleAuthenticationInProgress)
                  return CircularProgressIndicator();
                else
                  return Image.asset(
                    'assets/images/google_logo.png',
                    height: 30,
                  );
              }),
            ],
          ),
          onPressed: () =>
              context.read(authNotifierProviderForUser.notifier).GoogleLogin());
    });
  }
}
