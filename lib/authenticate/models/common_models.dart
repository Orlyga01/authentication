import 'package:authentication/shared/import_shared.dart';
import 'package:flutter/material.dart';

enum inputTypes { radio, dropdown, text, checkbox }

class CustomInputWidget extends StatefulWidget {
  final CustomInputFields customField;
  final Function(dynamic)? onChanged;

  CustomInputWidget(
      {Key? key, required this.customField, required this.onChanged})
      : super(key: key);

  @override
  State<CustomInputWidget> createState() => _CustomInputWidgetState();
}

class _CustomInputWidgetState extends State<CustomInputWidget> {
  @override
  Widget build(BuildContext context) {
    switch (widget.customField.type) {
      case inputTypes.checkbox:
        {
          return CheckboxListTile(
            title: Text((widget.customField.title.ctr())),
            value: widget.customField.value == true,
            onChanged: (newValue) {
              if (widget.onChanged != null) widget.onChanged!(newValue);

              setState(() {
                widget.customField.value = newValue;
              }); //onChange at parent have to have setState
            },
            controlAffinity:
                ListTileControlAffinity.leading, //  <-- leading Checkbox
          );
        }
      default:
        {
          return SizedBox.shrink();
        }
    }
  }
}

class CustomInputFields {
  inputTypes type;
  String title;
  String name;
  int? index;
  bool? isRequired;
  Function(dynamic)? onChanged;
  dynamic defaultValue;
  dynamic value;
  String? ddvalues; //for dd comma seperated list
  CustomInputFields(
      {required this.type,
      required this.title,
      required this.name,
      this.onChanged,
      this.defaultValue,
      this.value,
      this.isRequired,
      this.ddvalues});
}
