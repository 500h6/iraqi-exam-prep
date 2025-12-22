import 'package:equatable/equatable.dart';

abstract class AdminQuestionState extends Equatable {
  const AdminQuestionState();

  @override
  List<Object?> get props => [];
}

class AdminQuestionInitial extends AdminQuestionState {}

class AdminQuestionLoading extends AdminQuestionState {}

class AdminQuestionSuccess extends AdminQuestionState {}

class AdminQuestionFailure extends AdminQuestionState {
  final String message;

  const AdminQuestionFailure(this.message);

  @override
  List<Object?> get props => [message];
}
