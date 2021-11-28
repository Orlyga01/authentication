import 'package:authentication/authenticate/models/login.dart';
import 'package:authentication/user/providers/import_user.dart';

import 'package:flutter/material.dart';

class UserForm extends StatefulWidget {
  final AuthUser user;
  final LoginInfo? loginInfo;
  final bool fromRegister;
  // final GlobalKey<FormState> formKey;

  UserForm({
    Key? key,
    required this.user,
    this.fromRegister = false,
    this.loginInfo,
    // required this.formKey,
  }) : super(key: key);
  @override
  _UserFormState createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  late BuildContext _context;

  @override
  Widget build(BuildContext context) {
    _context = context;
    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.loginInfo == null || widget.fromRegister)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextFormField(
                  initialValue: widget.user.displayName ?? '',
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    hintText: ("Name"),
                  ),
                  onChanged: (String inputString) {
                    widget.user.displayName = inputString;
                  },
                  validator: (value) {
                    if (value != null && value.isEmpty) {
                      return "missing Name";
                    } else {
                      widget.user.displayName = value!;
                    }
                    return null;
                  }),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextFormField(
                initialValue: (widget.loginInfo != null &&
                        widget.loginInfo!.isFromExternalLogin)
                    ? null
                    : widget.user.email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: ("Email"),
                  //   prefixIcon: Icon(Icons.star_rate, size: 10, color: Colors.red),
                ),
                onChanged: (String inputString) {
                  setState(() {
                    if (widget.loginInfo != null)
                      widget.loginInfo!.password = null;
                    widget.user.email = inputString;
                    widget.loginInfo?.email = inputString;
                  });
                },
                validator: (value) {
                  String validate = LoginInfo().emailValidator(value!);
                  if (validate == '') {
                    widget.user.email = value;
                    widget.loginInfo?.email = value;
                  } else
                    return validate;
                  return null;
                }),
          ),
          if (widget.loginInfo == null || widget.fromRegister)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextFormField(
                  // initialValue: initialValue,
                  initialValue: widget.user.phone ?? '',
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: ("Mobile Phone"),
                  ),
                  onChanged: (value) => {
                        widget.user.phone = value,
                        widget.loginInfo?.phone = value
                      },
                  validator: (value) {
                    if ((value == null || value.length == 0))
                      return "missing phone";
                  }),
            ),
          if (widget.loginInfo != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextFormField(
                  initialValue: widget.loginInfo!.isFromExternalLogin
                      ? null
                      : widget.loginInfo!.password,
                  obscureText: true,
                  decoration: InputDecoration(
                    errorMaxLines: 2,
                    hintText: ("Password"),
                    //     prefixIcon: Icon(
                    //     Icons.star_rate,
                    //     size: 10,
                    //    color: Colors.red,
                    //  ),
                  ),
                  onChanged: (String inputString) {
                    widget.loginInfo!.password = inputString;
                  },
                  validator: (value) {
                    String err = LoginInfo().passwordValidator(value);
                    if (err == '')
                      widget.loginInfo!.password = value;
                    else
                      return (LoginInfo.passwordErrString);

                    return null;
                  }),
            ),
          if (widget.loginInfo != null && widget.fromRegister)
            TextFormField(
                initialValue: widget.loginInfo!.confirmedPassword,
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
                  widget.loginInfo!.confirmedPassword = inputString;
                },
                validator: (value) {
                  if (widget.loginInfo!
                          .confirmPasswordpasswordValidator(value) ==
                      '') {
                    widget.loginInfo!.confirmedPassword = value;
                  } else {
                    return ("Password") + " " + ("doesn't match");
                  }
                  return null;
                }),
          if (!widget.fromRegister && widget.loginInfo != null)
            Container(
              padding: EdgeInsets.only(top: 20),
              child: GestureDetector(
                child: Text("Forgot password?"),
                onTap: () {
                  Navigator.pushNamed(context, "reset_password",
                      arguments: {"email": widget.user.email});
                },
              ),
            )
        ],
      ),
    );
  }
}
