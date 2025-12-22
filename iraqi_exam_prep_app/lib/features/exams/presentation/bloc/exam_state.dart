import 'package:equatable/equatable.dart';
import '../../domain/entities/question_entity.dart';
import '../../domain/entities/exam_result_entity.dart';

abstract class ExamState extends Equatable {
  const ExamState();

  @override
  List<Object?> get props => [];
}

class ExamInitial extends ExamState {}

class ExamLoading extends ExamState {}

class ExamQuestionsLoaded extends ExamState {
  final List<QuestionEntity> questions;

  const ExamQuestionsLoaded(this.questions);

  @override
  List<Object?> get props => [questions];
}

class ExamSubmitted extends ExamState {
  final ExamResultEntity result;

  const ExamSubmitted(this.result);

  @override
  List<Object?> get props => [result];
}

class ExamError extends ExamState {
  final String message;

  const ExamError(this.message);

  @override
  List<Object?> get props => [message];
}
