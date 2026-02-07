import 'user_entity.dart';

class AuthResponseEntity {
  final UserEntity user;
  final String token;

  const AuthResponseEntity({
    required this.user,
    required this.token,
  });
}
