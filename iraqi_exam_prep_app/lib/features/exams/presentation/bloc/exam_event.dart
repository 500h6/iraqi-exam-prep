import 'package:equatable/equatable.dart';

abstract class ExamEvent extends Equatable {
  const ExamEvent();

  @override
  List<Object?> get props => [];
}

class LoadExamQuestionsEvent extends ExamEvent {
  final String subject;

  const LoadExamQuestionsEvent(this.subject);

  @override
  List<Object?> get props => [subject];
}

class SubmitExamEvent extends ExamEvent {
  final String subject;
  final Map<String, int> answers;

  const SubmitExamEvent({
    required this.subject,
    required this.answers,
  });

  @override
  List<Object?> get props => [subject, answers];
}
