import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/question_entity.dart';
import '../repositories/exam_repository.dart';

class GetExamQuestionsUseCase {
  final ExamRepository repository;

  GetExamQuestionsUseCase(this.repository);

  Future<Either<Failure, List<QuestionEntity>>> call(String subject) async {
    return await repository.getExamQuestions(subject);
  }
}
