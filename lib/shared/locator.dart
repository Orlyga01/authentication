import 'package:authentication/user/providers/import_user.dart';
import 'package:get_it/get_it.dart';

bool _registered = false;
final authlocator = GetIt.instance;
setupAuthServices() async {
  if (!_registered) {
    FirebaseUserRepository _userRepository = FirebaseUserRepository();
    authlocator
        .registerSingleton<FirebaseUserRepository>(_userRepository);
  }
}
