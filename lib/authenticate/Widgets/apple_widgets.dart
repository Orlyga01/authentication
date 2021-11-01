import 'dart:async';
import 'dart:io';
import 'package:authentication/authenticate/providers/authentication_state.dart';
import 'package:authentication/user/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleLoginButton extends StatelessWidget {
  final bool outlined;
  final BuildContext externalContext;
  const AppleLoginButton({
    Key? key,
    this.outlined = false,
    required this.externalContext,
  }) : super(key: key);
  @override
  build(BuildContext context) {
    if (Platform.isIOS)
      return Consumer(
        builder: (
          context,
          ScopedReader watch,
          child,
        ) {
          final state = watch(authNotifierProviderForUser);
          if (state is AppleUnauthenticated) {
            Timer.run(
              () {
                showDialog(
                  builder: (_) => AlertDialog(
                    title: Text("Apple Login Error"),
                    content: Text("Apple was not able to log you in. " +
                        state.err.toString()),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => {
                          Navigator.pushNamed(externalContext, "login"),
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                  context: externalContext,
                );
              },
            );
            return SizedBox.shrink();
          }
          return Container(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: SignInWithAppleButton(
                    style: SignInWithAppleButtonStyle.whiteOutlined,
                    height: 40,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    onPressed: () => context
                        .read(authNotifierProviderForUser.notifier)
                        .AppleLogin(),
                  ),
                ),
                Consumer(builder: (context, ScopedReader watch, child) {
                  final state = watch(authNotifierProviderForUser);
                  if (state is AppleAuthenticationInProgress)
                    return SizedBox(
                        width: 30, child: CircularProgressIndicator());
                  else
                    return SizedBox.shrink();
                }),
              ],
            ),
          );
        },
      );
    else
      return SizedBox.shrink();
  }
}
