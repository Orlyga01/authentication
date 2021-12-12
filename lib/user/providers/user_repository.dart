import 'package:authentication/user/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseUserRepository {
  CollectionReference _userCollection =
      FirebaseFirestore.instance.collection("users");
  static final FirebaseUserRepository _dbUser =
      new FirebaseUserRepository._internal();
  FirebaseUserRepository._internal();
  factory FirebaseUserRepository() {
    return _dbUser;
  }

  Future<AuthUser> add(AuthUser user) async {
    user.createdAt = DateTime.now();
    user.modifiedAt = DateTime.now();
    // the user id should be the same as the authenticated userid
    var val = await _userCollection.doc(user.id).set(user.toJson());
    return user;
  }

  Future<void> delete(AuthUser user) {
    return _userCollection.doc(user.id).delete();
  }

  Future<AuthUser?> get(id) async {
    try {
      DocumentSnapshot documentSnapshot = await _userCollection.doc(id).get();
      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        data['id'] = id;
        return AuthUser.fromJson(data);
      }
      return null;
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<void> update(String? id,
      [AuthUser? user, String? fieldName, dynamic? fieldValue]) {
    if (fieldName != null) {
      if (id == null) {
        print("----------error===========id was not passed to update");
        throw "no user id";
      }

      return _userCollection.doc(id).update({
        fieldName: fieldValue,
        "modifiedAt": DateTime.now().millisecondsSinceEpoch
      });
    } else {
      if (user == null) {
        print("----------error===========no user");
        throw "no user ";
      }

      user.modifiedAt = DateTime.now();
      return _userCollection.doc(user.id).update(user.toJson());
    }
  }

  @override
  Stream<List<AuthUser>>? getList() {
    return null;
  }

  Future<AuthUser?> getUserByField(String field, dynamic value) async {
    var querySnapshot =
        await _userCollection.where(field, isEqualTo: value).limit(1).get();
    if (querySnapshot.docs.length > 0) {
      var data = querySnapshot.docs[0].data() as Map<String, dynamic>;
      data['id'] = querySnapshot.docs[0].id;
      return AuthUser.fromJson(data);
    }
  }

  cleanDB() {
    FirebaseFirestore.instance.collection('persons').get().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        if (ds.reference.id != '6PJSkSGqGNmx075yNG6D') ds.reference.delete();
      }
    });
    FirebaseFirestore.instance
        .collection('users')
        .doc("rPa8P2BGIsTuUjDZSEKLSLeSg802")
        .collection("groups")
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
    FirebaseFirestore.instance.collection('groups').get().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
    FirebaseFirestore.instance.collection("basegroups").get().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
  }

  Future<List<AuthUser>> getUsersByListOfIds(List<String> usersList) async {
    if (usersList.length == 0) return [];
    List<AuthUser> userReturnlist = [];
    List<List<String>> subList = [];
    for (var i = 0; i < usersList.length; i += 10) {
      subList.add(usersList.sublist(
          i, i + 10 > usersList.length ? usersList.length : i + 10));
    }
    try {
      for (var i = 0; i < subList.length; i++) {
        QuerySnapshot query = await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: subList[i])
            .get();
        List<AuthUser> usertmplist = query.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data["id"] = doc.id;
          return AuthUser.fromJson(data);
        }).toList();
        if (usertmplist.length > 0)
          userReturnlist = userReturnlist + usertmplist;
      }
    } catch (e) {
      throw (e);
    }
    return userReturnlist;
  }
}
