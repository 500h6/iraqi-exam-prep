import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../exams/domain/entities/question_entity.dart';
import '../entities/question_input.dart';

abstract class AdminRepository {
  Future<Either<Failure, void>> addQuestion(QuestionInput input);
  Future<Either<Failure, List<QuestionEntity>>> searchQuestions({
    String? subject,
    String? query,
  });
  Future<Either<Failure, void>> updateQuestion(
    String id,
    QuestionInput input,
  );
  Future<Either<Failure, void>> deleteQuestion(String id);
}
