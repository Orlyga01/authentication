class AuthResult {
  final String uid;
  final String? email;
  final String? displayName;
  final String? phoneNumber;
  final String? photoURL;

  AuthResult({
    required this.uid,
    this.email,
    this.displayName,
    this.phoneNumber,
    this.photoURL,
  });

  // Create a simple user object that mimics Firebase User structure
  SimpleUser get user => SimpleUser(
    uid: uid,
    email: email,
    displayName: displayName,
    phoneNumber: phoneNumber,
    photoURL: photoURL,
  );
}

class SimpleUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? phoneNumber;
  final String? photoURL;

  SimpleUser({
    required this.uid,
    this.email,
    this.displayName,
    this.phoneNumber,
    this.photoURL,
  });
} 