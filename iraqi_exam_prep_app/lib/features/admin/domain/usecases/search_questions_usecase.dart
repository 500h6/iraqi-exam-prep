import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../exams/domain/entities/question_entity.dart';
import '../repositories/admin_repository.dart';

class SearchQuestionsUseCase {
  final AdminRepository repository;

  SearchQuestionsUseCase(this.repository);

  Future<Either<Failure, List<QuestionEntity>>> call({
    String? subject,
    String? query,
  }) {
    return repository.searchQuestions(subject: subject, query: query);
  }
}
