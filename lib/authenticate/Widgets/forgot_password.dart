import 'package:authentication/authenticate/models/login.dart';
import 'package:authentication/authenticate/providers/authentication_provider.dart';
import 'package:authentication/shared/auth_widgets.dart';
import 'package:authentication/shared/common_auth_functions.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatelessWidget {
  String? email;
  static String id = 'forgot-password';
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ForgotPasswordPage({Key? key, this.email}) : super(key: key);
  late BuildContext _context;
  @override
  Widget build(BuildContext context) {
    _context = context;
    return Dialog(
      insetPadding:
          const EdgeInsets.only(left: 10.0, top: 30, right: 10, bottom: 30),
      child: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Your Email'.ctr(),
                style: TextStyle(fontSize: 30, color: Colors.white),
              ),
              TextFormField(
                  initialValue: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: ("Email".ctr()),
                    //  prefixIcon:
                    //    Icon(Icons.star_rate, size: 10, color: Colors.red),
                    prefixIconConstraints: BoxConstraints(
                      maxWidth: 10,
                    ),
                  ),
                  onChanged: (String inputString) {
                    email = inputString;
                  },
                  validator: (value) {
                    String validate = LoginInfo().emailValidator(value!);
                    if (validate == '')
                      email = value;
                    else
                      return validate;
                    return null;
                  }),
              SizedBox(height: 20),
              OutlinedButton(
                child: Text('Send Email'.ctr()),
                onPressed: () async {
                  await sendResetEmail(context);
                },
              ),
              OutlinedButton(
                child: Text('Login'.ctr()),
                onPressed: () {},
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendResetEmail(context) async {
    if (_formKey.currentState!.validate() && email != null) {
      try {
        String err = await AuthenticationController().sendResetPassword(email);

        showDialog(
            context: context,
            builder: (BuildContext context) {
              // return object of type Dialog
              return AlertDialog(
                title: Text(err != "" ? "Error".ctr() : "Email sent".ctr()),
                content: Text(
                    err != "" ? err : ('Email was sent to: '.ctr()) + email!),
                actions: [
                  TextButton(
                    onPressed: () {
                      NavigatorState nav = Navigator.of(context);
                      nav.pop();
                      nav.pop();
                    },
                    child: Text('OK'.ctr()),
                  ),
                ],
              );
            });
      } catch (e) {
        showAlertDialog(e.toString(), context);
      }
    }
  }
}
