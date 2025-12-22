import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/question_entity.dart';
import '../entities/exam_result_entity.dart';

abstract class ExamRepository {
  Future<Either<Failure, List<QuestionEntity>>> getExamQuestions(String subject);
  Future<Either<Failure, ExamResultEntity>> submitExam({
    required String subject,
    required Map<String, int> answers,
  });
}
