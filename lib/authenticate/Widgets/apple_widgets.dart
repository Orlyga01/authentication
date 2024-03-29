import 'dart:async';
import 'dart:io';
import 'package:authentication/authenticate/providers/authentication_state.dart';
import 'package:authentication/user/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;

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
    if (!kIsWeb && Platform.isIOS)
      return Consumer(
        builder: (
          context,
          ref,
          child,
        ) {
          return Container(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: SignInWithAppleButton(
                    style: SignInWithAppleButtonStyle.whiteOutlined,
                    height: 40,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    onPressed: () => ref
                        .read(authNotifierProviderForUser.notifier)
                        .AppleLogin(),
                  ),
                ),
                Consumer(builder: (context,  ref, child) {
                  final state = ref.watch(authNotifierProviderForUser);
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
