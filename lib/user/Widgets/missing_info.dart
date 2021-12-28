import 'package:authentication/authenticate/Widgets/login_form.dart';
import 'package:authentication/shared/common_auth_functions.dart';
import 'package:authentication/user/providers/import_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MissingUserInfo extends StatelessWidget {
  final AuthUser user;
  final formKey = new GlobalKey<FormState>();

  MissingUserInfo({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (user.phone != null && user.phone!.indexOf("missing") > -1)
      user.phone = "";
    if (user.email != null && user.email!.indexOf("missing") > -1)
      user.email = "";
    // if (person.name.indexOf("missing") > -1) person.name = '';

    TextEditingController phoneCont = TextEditingController();
    return AlertDialog(
      title: Text("Please Complete:".ctr()),
      content: Container(
        child: Form(key: formKey, child: UserForm(user: this.user)),
      ),
      actions: [
        OutlinedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                bool valid = await checkUserValidity(user, context);
                if (valid) {
                  context
                      .read(userNotifier.notifier)
                      .completeUserMissingInfoAfterAuthenticate(user);
                }
                await UserController().resetUser();
                Navigator.of(context).pop();
              }
              //  }
            },
            child: Text("Save".ctr())),
        OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel".ctr())),
      ],
    );
  }
}

Future<bool> checkUserValidity(AuthUser newUser, context) async {
  String err = newUser.validate();
  if (err != "") return false;
  AuthUser currentUser = UserController().getUser;
  bool checkphone = currentUser.phone != newUser.phone;
  bool checkemail = currentUser.email != newUser.email;
  // we need to check if another user is already using this phone
  AuthUser? foundUser = await UserController()
      .isUserExists(newUser, checkphone, checkemail, false);
  if (foundUser != null) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog

          return AlertDialog(
              title: Text("Email or phone are already being used by: ".ctr() +
                  foundUser.displayName!.substring(0, 3) +
                  ' **** '),
              actions: [
                OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("OK".ctr())),
              ]);
        });
    return false;
  }
  return true;
}
