import 'package:authentication/authenticate/providers/authentication_provider.dart';
import 'package:authentication/user/providers/import_user.dart';
import 'package:get_it/get_it.dart';

bool _registered = false;
final authUserlocator = GetIt.instance;
final authlocator = GetIt.instance;

setupAuthServices() async {
  if (!_registered) {
    FirebaseUserRepository _userRepository = FirebaseUserRepository();
    authlocator.registerSingleton<FirebaseUserRepository>(_userRepository);

    AuthenticationController _authRepository = AuthenticationController();
    authUserlocator
        .registerSingleton<AuthenticationController>(_authRepository);
    AuthenticationNotifier _authNotifier = AuthenticationNotifier();
    authlocator.registerSingleton<AuthenticationNotifier>(_authNotifier);
  }
}
