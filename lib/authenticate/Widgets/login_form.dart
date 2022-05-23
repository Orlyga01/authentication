import 'package:authentication/authenticate/models/login.dart';
import 'package:authentication/shared/auth_constants.dart';
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
  final List<dynamic>? rolesList;
 
  // final GlobalKey<FormState> formKey;

  UserForm({
    Key? key,
    required this.user,
    this.fromRegister = false,
    this.loginInfo,
    this.emailLogin = true,
    this.phoneLogin = true,  this.rolesList,
    // required this.formKey,
  }) : super(key: key);
  @override
  _UserFormState createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  late BuildContext _context;
  late List<DropdownMenuItem<dynamic>> items;
 void initState() {
    items = createRolesForDropDown();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    _context = context;
    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          
          if (widget.loginInfo == null || widget.fromRegister || widget.roleList != null)
 Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<dynamic>(
              items: items,
              value: widget.selectedItem,
              style: TextStyle(
                inherit: false,
                fontSize: 16,
              ),
              icon: const Icon(Icons.expand_more_outlined),
              onChanged: (value) => {
                widget.onChange!(value) ?? () => {},
                setState(() {
                  value = getTextDisplay(value);
                  widget.selectedItem = getTextDisplay(value);
                })
              },
            ),
          ),
        )
          if (widget.loginInfo == null || widget.fromRegister)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextFormField(
                  key: Key("name"),
                  initialValue:
                      widget.loginInfo != null && widget.loginInfo!.name != null
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
          if (widget.loginInfo == null || widget.fromRegister)
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
                      initialValue: (widget.loginInfo != null &&
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
                if (widget.loginInfo != null)
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
                if (widget.loginInfo != null && widget.fromRegister)
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
          if (!widget.fromRegister && widget.loginInfo != null)
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
  List<DropdownMenuItem<dynamic>> createRolesForDropDown(
      Function? selectedToString) {
    List<DropdownMenuItem> ddMap = widget.rolesList!.map((value) {
      return DropdownMenuItem(
          value: value,
          child: Container(
              child: Text("Role".ctr(),)));
    }).toList();
    return ddMap;
  }
}
