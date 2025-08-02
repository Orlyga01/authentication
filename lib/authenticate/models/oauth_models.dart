import 'package:equatable/equatable.dart';

/// Model for Google OAuth response
class GoogleOAuthResult extends Equatable {
  final String? accessToken;
  final String? idToken;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String id;

  const GoogleOAuthResult({
    this.accessToken,
    this.idToken,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.id,
  });

  @override
  List<Object?> get props =>
      [accessToken, idToken, email, displayName, photoUrl, id];
}

/// Model for Apple OAuth response
class AppleOAuthResult extends Equatable {
  final String? authorizationCode;
  final String? identityToken;
  final String? email;
  final String? givenName;
  final String? familyName;
  final String userIdentifier;

  const AppleOAuthResult({
    this.authorizationCode,
    this.identityToken,
    this.email,
    this.givenName,
    this.familyName,
    required this.userIdentifier,
  });

  String? get displayName {
    if (givenName != null || familyName != null) {
      return '${givenName ?? ''} ${familyName ?? ''}'.trim();
    }
    return null;
  }

  @override
  List<Object?> get props => [
        authorizationCode,
        identityToken,
        email,
        givenName,
        familyName,
        userIdentifier
      ];
}

/// Base class for OAuth results
abstract class OAuthResult extends Equatable {
  final String id;
  final String? email;
  final String? displayName;

  const OAuthResult({
    required this.id,
    this.email,
    this.displayName,
  });

  @override
  List<Object?> get props => [id, email, displayName];
}
