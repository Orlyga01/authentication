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
  final String? buttonText;
  final bool? disabled;
  final Widget? pendingSpinner;
  final void Function()? disableFunction;
  final Color? mainColor;
  const AppleLoginButton({
    Key? key,
    this.outlined = false,
    required this.externalContext,
    this.disabled = false,
    this.buttonText,
    this.disableFunction,
    this.mainColor,
    this.pendingSpinner,
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
            decoration: BoxDecoration(
              color: (mainColor ?? Colors.transparent)
                  .withOpacity(disabled == true ? 0.5 : 1.0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: SignInWithAppleButton(
                    text: buttonText ?? "Login with Apple",
                    style: SignInWithAppleButtonStyle.whiteOutlined,
                    height: 40,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    onPressed: disabled == true
                        ? (disableFunction ?? () {})
                        : () => ref
                            .read(authNotifierProviderForUser.notifier)
                            .AppleLogin(),
                  ),
                ),
                Consumer(builder: (context, ref, child) {
                  final state = ref.watch(authNotifierProviderForUser);
                  if (state is AppleAuthenticationInProgress)
                    return SizedBox(
                        width: 30,
                        child: pendingSpinner ?? CircularProgressIndicator());
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
