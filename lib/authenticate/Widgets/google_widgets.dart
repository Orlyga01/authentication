import 'dart:async';
import 'package:authentication/authenticate/providers/authentication_state.dart';
import 'package:authentication/shared/common_auth_functions.dart';
import 'package:authentication/user/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoogleLoginButton extends StatelessWidget {
  final bool outlined;
  final Color? mainColor;
  final Color? textColor;
  final bool? disabled;
  final void Function()? disableFunction;
  final BuildContext? outerContext;
  final String? buttonText;
  final bool? saveToLocalStorage;
  final Widget? pendingSpinner;
  final BuildContext externalContext;
  const GoogleLoginButton(
      {Key? key,
      this.outlined = false,
      this.buttonText,
      required this.externalContext,
      this.mainColor = Colors.grey,
      this.textColor = Colors.grey,
      this.outerContext,
      this.saveToLocalStorage = true,
      this.disabled = false,
      this.pendingSpinner,
      this.disableFunction})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    // String? screen = currentPage(GlobalKey<NavigatorState>()),

    return Consumer(builder: (context, ref, child) {
      final state = ref.watch(authNotifierProviderForUser);

      return FilledButton(
          style: ButtonStyle(
            foregroundColor:
                MaterialStateProperty.all<Color>(Colors.transparent),
            backgroundColor: MaterialStateProperty.all<Color>(
                mainColor ?? Colors.transparent),
            surfaceTintColor:
                MaterialStateProperty.all<Color>(Colors.transparent),
          ),
          key: Key('loginForm_googleLogin_raisedButton'),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Google logo
              Image.asset(
                'assets/images/google_logo.png',
                height: 25,
                package: 'authentication',
              ),
              SizedBox(width: 10),
              Text(
                buttonText ?? 'Sign in with Google'.ctr(),
                style: TextStyle(
                  color: outlined ? (textColor ?? Colors.white) : Colors.white,
                ),
              ),
              // Progress indicator if needed
              if (state is GoogleAuthenticationInProgress) SizedBox(width: 10),
              if (state is GoogleAuthenticationInProgress)
                pendingSpinner ?? CircularProgressIndicator(),
            ],
          ),
          onPressed: disabled == true
              ? (disableFunction ?? () {})
              : () => ref
                  .read(authNotifierProviderForUser.notifier)
                  .GoogleLogin(saveToLocalStorage: saveToLocalStorage ?? true));
    });
  }
}
