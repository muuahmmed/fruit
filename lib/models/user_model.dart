import 'package:firebase_auth/firebase_auth.dart';

import '../network/domain_layer/entities/user_entity.dart';


class UserModel extends UserEntity {
  UserModel({
    required String uId,
    required String name,
    required String email,
  }) : super(uId: uId, name: name, email: email,);

  factory UserModel.fromFirebaseUser(User user ) {
    return UserModel(
      uId: user.uid,
      name: user.displayName ?? 'No Name',
      email: user.email ?? '',
    );
  }
}
