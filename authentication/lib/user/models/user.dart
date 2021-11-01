//import 'package:property_change_notifier/property_change_notifier.dart';

import 'package:authentication/shared/import_shared.dart';

class AuthUser {
  String id = '';
  String? displayName;
  String? email;
  String? image;
  DateTime? createdAt;
  DateTime? modifiedAt;
  String? phone;
  List<String>? tokensArray;
  UserSettings? settings;
  String? oneSignalPlayers;
  String? role;

  String validate() {
    if (email == null && phone == null)
      return "Please set email or phone number";
    return "";
  }

  AuthUser(
      {required this.id,
      this.displayName,
      this.email,
      this.phone,
      this.image,
      this.createdAt,
      this.modifiedAt,
      this.settings,
      this.oneSignalPlayers,
      this.role});

  AuthUser.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        displayName = json['displayName'],
        email = json['email'],
        phone = json['phone'],
        image = json['image'],
        oneSignalPlayers = json['oneSignalPlayers'],
        role = json['role'],
        settings = json["settings"] != null
            ? UserSettings.fromJson(json["settings"])
            : null,
        createdAt = DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
        modifiedAt = DateTime.fromMillisecondsSinceEpoch(json['modifiedAt']);

  //collectionFromJson(
  //   json['groups'], (value) => UserGroup.fromJson(value));

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'email': email,
        'phone': phone,
        'oneSignalPlayers': oneSignalPlayers,
        'createdAt': createdAt?.millisecondsSinceEpoch,
        'image': image,
        'modifiedAt': modifiedAt?.millisecondsSinceEpoch,
        'role': role,
        'settings': settings?.toJson()
      };
  static get empty {
    return AuthUser(email: '', id: '', phone: '');
  }

  bool get isInfoMissing {
    return isEmpty(displayName) || isEmpty(phone) || isEmpty(email);
  }
}

class UserSettings {
  NotificationSettings? notification;
  UserSettings(this.notification);
  Map<String, dynamic> toJson() => {
        'notification': notification?.toJson(),
      };
  UserSettings.fromJson(Map<String, dynamic> json)
      : notification = NotificationSettings.fromJson(json['notification']);
}

class NotificationSettings {
  bool notifyOnlyImportant = false;
  NotificationSettings(this.notifyOnlyImportant);
  Map<String, dynamic> toJson() => {
        'notifyOnlyImportant': notifyOnlyImportant,
      };
  NotificationSettings.fromJson(Map<String, dynamic> json)
      : notifyOnlyImportant = json['notifyOnlyImportant'];
}
