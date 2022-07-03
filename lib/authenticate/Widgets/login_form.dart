import 'package:authentication/authenticate/models/common_models.dart';
import 'package:authentication/authenticate/models/login.dart';
import 'package:authentication/shared/common_auth_functions.dart';
import 'package:authentication/user/providers/import_user.dart';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class UserForm extends StatefulWidget {
  final AuthUser user;
  final LoginInfo? loginInfo;
  final bool fromRegister;
  final bool emailLogin;
  final bool phoneLogin;
  bool? showPassword = true;
  List<CustomInputFields>? customFields;

  // final GlobalKey<FormState> formKey;

  UserForm(
      {Key? key,
      required this.user,
      this.fromRegister = false,
      this.loginInfo,
      this.emailLogin = true,
      this.phoneLogin = true,
      this.customFields,
      this.showPassword
      // required this.formKey,
      })
      : super(key: key);
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
          if (isRegisterMode && widget.customFields != null)
            ListView.builder(
                shrinkWrap: true,
                itemCount: widget.customFields!.length,
                itemBuilder: (context, index) {
                  widget.customFields![index].index = index;
                  return CustomInputWidget(
                    customField: widget.customFields![index],
                    onChanged: (value) =>
                        widget.customFields![index].value = value,
                  );
                }),
          if (isRegisterMode)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextFormField(
                  key: Key("name"),
                  initialValue:
                      !isLoginInfoForRegister && widget.loginInfo!.name != null
                          ? widget.loginInfo!.name
                          : widget.user.displayName ?? '',
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    hintText: ("Name".ctr()),
                  ),
                  onChanged: (String inputString) {
                    widget.user.displayName = inputString;
                  },
                  validator: (value) {
                    if (value != null && value.isEmpty) {
                      return "missing Name".ctr();
                    } else {
                      widget.user.displayName = value!;
                    }
                    return null;
                  }),
            ),
          if (isRegisterMode)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextFormField(
                  // initialValue: initialValue,
                  initialValue: widget.user.phone ?? '',
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: ("Mobile Phone".ctr()),
                  ),
                  onChanged: (value) => {
                        widget.user.phone = value,
                        widget.loginInfo?.phone = value
                      },
                  validator: (value) {
                    if ((value == null || value.length == 0))
                      return "missing phone".ctr();
                  }),
            ),
          Container(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextFormField(
                      key: Key("email"),
                      initialValue: (!isLoginInfoForRegister &&
                              widget.loginInfo!.isFromExternalLogin)
                          ? null
                          : widget.user.email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: ("Email".ctr()),
                        //   prefixIcon: Icon(Icons.star_rate, size: 10, color: Colors.red),
                      ),
                      onChanged: (String inputString) {
                        setState(() {
                          if (!isLoginInfoForRegister)
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
                if (widget.showPassword != false)
                  TextFormField(
                      key: Key("password"),
                      textDirection: TextDirection.ltr,
                      initialValue: widget.loginInfo!.isFromExternalLogin
                          ? null
                          : widget.loginInfo!.password,
                      obscureText: true,
                      decoration: InputDecoration(
                        errorMaxLines: 2,
                        hintText: ("Password".ctr()),
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
                if (isRegisterMode)
                  TextFormField(
                      key: Key("confirmPassword"),
                      initialValue: widget.loginInfo!.confirmedPassword,
                      obscureText: true,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        hintText: ("Confirm Password".ctr()),
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
                          return ("Password".ctr()) +
                              " " +
                              ("doesn't match".ctr());
                        }
                        return null;
                      }),
              ],
            ),
          ),
          if (!isRegisterMode)
            Container(
              padding: EdgeInsets.only(top: 20),
              child: GestureDetector(
                child: Text("Forgot password?".ctr()),
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

  bool get isRegisterMode => widget.fromRegister;
  bool get isLoginInfoForRegister =>
      widget.loginInfo == null ||
      (widget.loginInfo != null && widget.loginInfo!.email == null);
}
