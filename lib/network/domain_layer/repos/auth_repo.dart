import 'package:firebase_auth/firebase_auth.dart';
import 'package:fruit/compoents/AuthException.dart'
    show AuthException, InvalidCredentialsException;
import 'package:fruit/compoents/end_points.dart';
import 'package:fruit/models/user_model.dart' show UserModel;
import 'package:fruit/network/domain_layer/entities/user_entity.dart'
    show UserEntity;
import '../../services/firebase_service.dart';
import '../../services/firestore_service.dart';

class AuthRepoImpl implements AuthRepo {
  final FirebaseAuthService firebaseAuthService;
  final DatabaseService databaseService;

  AuthRepoImpl({
    required this.databaseService,
    required this.firebaseAuthService,
  });

  @override
  Future<UserEntity> createUserWithEmailAndPassword({
    required String email,
    required String name,
    required String password,
    required String confirmPassword,
  }) async {
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      throw Exception('Email, password, and confirm password cannot be empty');
    }

    if (password != confirmPassword) {
      throw Exception('Passwords do not match');
    }

    final user = await firebaseAuthService.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (user == null) {
      throw Exception('User creation failed');
    }

    final userEntity = UserModel.fromFirebaseUser(user, name: name);

    await databaseService.addData(
      path: 'users/${user.uid}',
      data: userEntity.toMap(),
    );

    return userEntity;
  }

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

      final userData = await databaseService.getData(
        path: 'users/${user.uid}',
      );

      if (userData == null) {
        throw Exception('User not found in Firestore');
      }

      return UserModel(
        uId: user.uid,
        email: user.email ?? '',
        name: userData['name'] ?? '',
        createdAt: DateTime.parse(userData['createdAt'] ?? DateTime.now().toIso8601String()),
      );
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

      final userEntity = UserModel.fromFirebaseUser(
        user,
        name: user.displayName ?? '',
      );
      await databaseService.addData(
        path: 'users/${user.uid}',
        data: userEntity.toMap(),
      );
      return userEntity;
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

      final userEntity = UserModel.fromFirebaseUser(
        user,
        name: user.displayName ?? '',
      );
      await databaseService.addData(
        path: 'users/${user.uid}',
        data: userEntity.toMap(),
      );
      return userEntity;
    } catch (e) {
      throw AuthException('Facebook Sign-In error: ${e.toString()}');
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await firebaseAuthService.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Password reset failed');
    }
  }

  @override
  Future<void> addUserData({required UserEntity user}) async {
    await databaseService.addData(
      path: BackEndPoints.addUserData,
      data: user.toMap(),
    );
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
  Future addUserData({required UserEntity user});
}
