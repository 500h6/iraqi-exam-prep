import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, Map<String, dynamic>>> requestOtp({
    required String phone,
  });

  Future<Either<Failure, UserEntity>> verifyOtp({
    required String phone,
    required String code,
  });

  Future<Either<Failure, UserEntity>> completeProfile({
    required String name,
  });



  Future<Either<Failure, void>> logout();

  Future<Either<Failure, bool>> checkAuthStatus();

  Future<Either<Failure, UserEntity>> getCurrentUser();
}
