import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  });

  Future<Either<Failure, UserEntity>> identify({
    required String name,
    required String phone,
    String? branch,
    String? city,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, bool>> checkAuthStatus();

  Future<Either<Failure, UserEntity>> getCurrentUser();
}
