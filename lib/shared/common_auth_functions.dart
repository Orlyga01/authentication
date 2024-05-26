// import 'package:easy_localization/easy_localization.dart';

bool isEmpty(dynamic field) {
  return ((field == null) ||
      field == 0 ||
      field.length == 0 ||
      (field == false));
}

dynamic myDateSerializer(dynamic object) {
  if (object is DateTime) {
    return object.toIso8601String();
  }
  return object;
}

extension StringIsEmpty on String? {
  bool get isEmptyBe => this == null || this!.isEmpty;
}

extension StringTranslateExtensionCustom on String {
  String ctr({
    List<String>? args,
    Map<String, String>? namedArgs,
    bool? gender,
  }) {
    String? newgender;
    if (gender != null) newgender = gender ? "boy" : "girl";
    // String tmp;
    //  String tmp = this.(args: args, namedArgs: namedArgs, gender: newgender);
    return "need to fix this";
  }
}
