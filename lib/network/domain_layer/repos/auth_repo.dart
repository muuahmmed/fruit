import 'package:firebase_auth/firebase_auth.dart';
import 'package:fruit/compoents/AuthException.dart'
    show AuthException, InvalidCredentialsException;
import 'package:fruit/models/user_model.dart' show UserModel;
import 'package:fruit/network/domain_layer/entities/user_entity.dart'
    show UserEntity;
import '../../services/firebase_service.dart';

class AuthRepoImpl implements AuthRepo {
  // Implement AuthRepo
  final FirebaseAuthService firebaseAuthService;

  AuthRepoImpl({required this.firebaseAuthService});

  @override
  // Implement the createUserWithEmailAndPassword method
  Future<UserEntity> createUserWithEmailAndPassword({
    required String email,
    required String name,
    required String password,
    required String confirmPassword,
  }) async {
    print('Creating user with email: $email'); // Debug statement
    print('Name: $name'); // Debug statement
    print('Password: $password'); // Debug statement
    print('Confirm Password: $confirmPassword'); // Debug statement

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      throw Exception('Email, password, and confirm password cannot be empty');
    }

    if (password != confirmPassword) {
      throw Exception('Passwords do not match');
    }

    var user = await firebaseAuthService.createUserWithEmailAndPassword(
      email: email,
      password: password,
      emailAddress: email,
    );

    if (user == null) {
      throw Exception('User creation failed');
    }

    print('User created successfully: ${user.email}'); // Debug statement
    return UserModel.fromFirebaseUser(user);
  }

  // Implement the signInWithEmailAndPassword method
  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = await firebaseAuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (user == null) {
        throw InvalidCredentialsException();
      }
      return UserModel.fromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'user-not-found') {
        throw InvalidCredentialsException();
      }
      throw AuthException(e.message ?? 'Authentication failed');
    }
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      final user = await firebaseAuthService.signInWithGoogle();
      if (user == null) {
        throw AuthException('Google Sign-In failed - no user returned');
      }
      return UserModel.fromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Google Sign-In failed');
    } catch (e) {
      throw AuthException('Google Sign-In error: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity> signInWithFacebook() async {
    try {
      final user = await firebaseAuthService.signInWithFacebook();
      if (user == null) {
        throw AuthException('Facebook Sign-In failed - no user returned');
      }
      return UserModel.fromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Facebook Sign-In failed');
    } catch (e) {
      throw AuthException('Facebook Sign-In error: ${e.toString()}');
    }
  }
  // In your AuthRepoImpl
  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await firebaseAuthService.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Password reset failed');
    }
  }
}

abstract class AuthRepo {
  Future<UserEntity> createUserWithEmailAndPassword({
    required String email,
    required String name,
    required String password,
    required String confirmPassword,
  });

  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<UserEntity> signInWithGoogle();
  Future<UserEntity> signInWithFacebook();
  Future<void> sendPasswordResetEmail({required String email});
}
