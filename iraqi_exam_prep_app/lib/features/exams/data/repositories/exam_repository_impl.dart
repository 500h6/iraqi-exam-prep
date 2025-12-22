import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/question_entity.dart';
import '../../domain/entities/exam_result_entity.dart';
import '../../domain/repositories/exam_repository.dart';
import '../datasources/exam_remote_datasource.dart';

class ExamRepositoryImpl implements ExamRepository {
  final ExamRemoteDataSource remoteDataSource;

  ExamRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<QuestionEntity>>> getExamQuestions(
    String subject,
  ) async {
    try {
      final questions = await remoteDataSource.getExamQuestions(subject);
      return Right(questions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExamResultEntity>> submitExam({
    required String subject,
    required Map<String, int> answers,
  }) async {
    try {
      final result = await remoteDataSource.submitExam(
        subject: subject,
        answers: answers,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
