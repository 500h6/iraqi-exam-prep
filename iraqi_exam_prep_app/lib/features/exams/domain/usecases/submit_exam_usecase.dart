import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/exam_result_entity.dart';
import '../repositories/exam_repository.dart';

class SubmitExamUseCase {
  final ExamRepository repository;

  SubmitExamUseCase(this.repository);

  Future<Either<Failure, ExamResultEntity>> call({
    required String subject,
    required Map<String, int> answers,
  }) async {
    return await repository.submitExam(subject: subject, answers: answers);
  }
}
