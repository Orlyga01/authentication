import 'package:flutter/material.dart';

void showAlertDialog(String text, BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog

        return AlertDialog(title: Text(text), actions: [
          OutlinedButton(
              onPressed: () => Navigator.of(context).pop(), child: Text("OK")),
        ]);
      });
}
