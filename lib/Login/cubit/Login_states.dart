import '../../network/domain_layer/entities/user_entity.dart';

abstract class ShopLoginStates {}

class ShopLoginInitialState extends ShopLoginStates {}

class ShopLoginLoadingState extends ShopLoginStates {}

class ShopLoginSuccessState extends ShopLoginStates {
  final UserEntity loginModel;

  ShopLoginSuccessState(
    this.loginModel,
  ); // Add a constructor to accept loginModel
}

class ShopLoginErrorState extends ShopLoginStates {
  final String error;
  ShopLoginErrorState(this.error);
}
