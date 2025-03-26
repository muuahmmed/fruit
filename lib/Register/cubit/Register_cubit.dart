import 'package:flutter_bloc/flutter_bloc.dart';

import '../../network/domain_layer/entities/user_entity.dart';
import '../../network/domain_layer/repos/auth_repo.dart';
import 'Register_States.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth auth = FirebaseAuth.instance;

class RegisterCubit extends Cubit<RegisterStates> {
  final AuthRepo authRepo;

  RegisterCubit(this.authRepo) : super(RegisterInitialState());

  static RegisterCubit get(context) => BlocProvider.of<RegisterCubit>(context);

  Future<void> createUserWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    emit(RegisterLoadingState());
    try {
      if (password != confirmPassword) {
        emit(RegisterErrorState('Passwords do not match'));
        return;
      }

      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userEntity = UserEntity(
        uId: userCredential.user?.uid ?? '',
        name: name,
        email: email,
      );

      emit(RegisterSuccessState(userEntity: userEntity));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        emit(RegisterErrorState('This account is already registered'));
      } else {
        emit(RegisterErrorState(e.message ?? 'Registration failed'));
      }
    } catch (e) {
      emit(RegisterErrorState('An unexpected error occurred'));
    }
  }
}
