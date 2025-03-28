import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit/Login/cubit/Login_states.dart';
import '../../network/domain_layer/repos/auth_repo.dart';

class ShopLoginCubit extends Cubit<ShopLoginStates> {
  final AuthRepo authRepo;

  ShopLoginCubit(this.authRepo) : super(ShopLoginInitialState());

  Future<void> userLogin({
    required String email,
    required String password,
  }) async {
    emit(ShopLoginLoadingState());
    try {
      final user = await authRepo.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      emit(ShopLoginSuccessState(user));
    } catch (e) {
      emit(ShopLoginErrorState(e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(ShopLoginLoadingState());
    try {
      final user = await authRepo.signInWithGoogle();
      emit(ShopLoginSuccessState(user));
    } catch (e) {
      print(e.toString());
      emit(ShopLoginErrorState(e.toString()));
    }
  }
  Future<void> signInWithFacebook() async {
    emit(ShopLoginLoadingState());
    try {
      final user = await authRepo.signInWithFacebook();
      emit(ShopLoginSuccessState(user));
    } catch (e) {
      print(e.toString());
      emit(ShopLoginErrorState(e.toString()));
    }
  }

  // In your ShopLoginCubit
  Future<void> sendPasswordResetEmail(String email) async {
    emit(ShopLoginLoadingState());
    try {
      await authRepo.sendPasswordResetEmail(email: email);
      emit(ShopForgotPasswordSuccessState());
    } catch (e) {
      emit(ShopLoginErrorState(e.toString()));
    }
  }
}
