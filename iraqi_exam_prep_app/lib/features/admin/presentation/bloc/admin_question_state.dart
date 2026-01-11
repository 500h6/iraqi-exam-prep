import 'package:equatable/equatable.dart';
import '../../../exams/domain/entities/question_entity.dart';

abstract class AdminQuestionState extends Equatable {
  const AdminQuestionState();

  @override
  List<Object?> get props => [];
}

class AdminQuestionInitial extends AdminQuestionState {}

class AdminQuestionLoading extends AdminQuestionState {}

class AdminQuestionSuccess extends AdminQuestionState {
  final String? message;
  const AdminQuestionSuccess({this.message});

  @override
  List<Object?> get props => [message];
}

class AdminQuestionListSuccess extends AdminQuestionState {
  final List<QuestionEntity> questions;

  const AdminQuestionListSuccess(this.questions);

  @override
  List<Object?> get props => [questions];
}

class AdminQuestionFailure extends AdminQuestionState {
  final String message;

  const AdminQuestionFailure(this.message);

  @override
  List<Object?> get props => [message];
}
