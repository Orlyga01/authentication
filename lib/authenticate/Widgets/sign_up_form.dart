import 'package:authentication/authenticate/models/login.dart';
import 'package:flutter/material.dart';

class SignUpForm extends ConsumerWidget {
  final RegisterInfo registerinfo;
  GlobalKey<FormState>? formKey = GlobalKey<FormState>();

  SignUpForm({Key? key, this.formKey, required this.registerinfo})
      : super(key: key);

  @override
  Widget build(BuildContext context, watch) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // PersonForm(
          //   mcontext: context,
          //   person: registerinfo.user!.person!,
          //   fromRegister: true,
          //   formKey: formKey,
          // ),
          LoginForm(
            logininfo: registerinfo.loginInfo,
            fromRegister: true,
          ),
          const SizedBox(height: 8.0),
          TextFormField(
              initialValue: registerinfo.confirmedPassword,
              obscureText: true,
              decoration: InputDecoration(
                hintText: ("Confirm Password"),
                // prefixIcon:
                //     Icon(Icons.star_rate, size: 10, color: Colors.red),
                // prefixIconConstraints: BoxConstraints(
                //   maxWidth: 10,
                // ),
              ),
              onChanged: (String inputString) {
                registerinfo.confirmedPassword = inputString;
              },
              validator: (value) {
                if (registerinfo.confirmPasswordpasswordValidator(value) ==
                    '') {
                  registerinfo.confirmedPassword = value;
                } else {
                  return ("Password") + " " + ("doesn't match");
                }
                return null;
              }),
          const SizedBox(height: 8.0),
          Expanded(child: SizedBox.shrink()),
        ],
      ),
    );
  }
}

class SignUpButton extends StatefulWidget {
  final String buttonText;
  final Function? onPressed;

  const SignUpButton({Key? key, required this.buttonText, this.onPressed})
      : super(key: key);
  @override
  SignUpButtonState createState() => SignUpButtonState();
}

class SignUpButtonState extends State<SignUpButton> {
  bool waitingState = false;

  changeState(val) {
    setState(() => waitingState = val);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Row(
        children: [
          Expanded(
            child: Center(child: Text(widget.buttonText)),
          ),
          Visibility(
            visible: waitingState,
            child: SizedBox(
                height: 20, width: 20, child: CircularProgressIndicator()),
          ),
        ],
      ),
      onPressed: () => {widget.onPressed!() ?? () => {}},
    );
  }
}
