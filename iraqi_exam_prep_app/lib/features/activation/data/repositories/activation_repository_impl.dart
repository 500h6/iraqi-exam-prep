import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/activation_repository.dart';
import '../datasources/activation_remote_datasource.dart';

class ActivationRepositoryImpl implements ActivationRepository {
  final ActivationRemoteDataSource remoteDataSource;

  ActivationRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, bool>> validateCode(String code) async {
    try {
      final result = await remoteDataSource.validateCode(code);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkSubscription() async {
    try {
      final result = await remoteDataSource.checkSubscription();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
