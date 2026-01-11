import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../exams/domain/entities/question_entity.dart';
import '../../domain/entities/question_input.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, void>> addQuestion(QuestionInput input) async {
    try {
      await remoteDataSource.addQuestion(input);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<QuestionEntity>>> searchQuestions({
    String? subject,
    String? query,
  }) async {
    try {
      final questions = await remoteDataSource.searchQuestions(
        subject: subject,
        query: query,
      );
      return Right(questions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateQuestion(
    String id,
    QuestionInput input,
  ) async {
    try {
      await remoteDataSource.updateQuestion(id, input);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteQuestion(String id) async {
    try {
      await remoteDataSource.deleteQuestion(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
