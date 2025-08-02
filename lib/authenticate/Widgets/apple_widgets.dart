import 'dart:io';
import 'package:authentication/authenticate/providers/authentication_state.dart';
import 'package:authentication/shared/common_auth_functions.dart';
import 'package:authentication/user/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AppleLoginButton extends StatelessWidget {
  final bool outlined;
  final BuildContext externalContext;
  final String? buttonText;
  final bool? disabled;
  final Widget? pendingSpinner;
  final void Function()? disableFunction;
  final Color? mainColor;
  final Color? textColor;

  const AppleLoginButton({
    Key? key,
    this.outlined = false,
    required this.externalContext,
    this.disabled = false,
    this.buttonText,
    this.disableFunction,
    this.mainColor,
    this.pendingSpinner,
    this.textColor,
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
          final state = ref.watch(authNotifierProviderForUser);

          return FilledButton(
            style: ButtonStyle(
              foregroundColor:
                  MaterialStateProperty.all<Color>(Colors.transparent),
              backgroundColor: MaterialStateProperty.all<Color>(
                  (mainColor ?? Colors.black)
                      .withOpacity(disabled == true ? 0.5 : 1.0)),
              surfaceTintColor:
                  MaterialStateProperty.all<Color>(Colors.transparent),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Show spinner during authentication, otherwise show Apple logo
                if (state is AppleAuthenticationInProgress)
                  SizedBox(
                    height: 25,
                    width: 25,
                    child: pendingSpinner ??
                        CircularProgressIndicator(
                          color: Colors.white,
                        ),
                  )
                else
                  Icon(
                    Icons.apple,
                    color: Colors.white,
                    size: 25,
                  ),
                SizedBox(width: 10),
                Text(
                  buttonText ?? 'Sign in with Apple'.ctr(),
                  style: TextStyle(
                    color: textColor ?? Colors.white,
                  ),
                ),
              ],
            ),
            onPressed: disabled == true
                ? (disableFunction ?? () {})
                : () =>
                    ref.read(authNotifierProviderForUser.notifier).AppleLogin(),
          );
        },
      );
    else
      return SizedBox.shrink();
  }
}
