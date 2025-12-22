import 'package:equatable/equatable.dart';

abstract class AdminQuestionEvent extends Equatable {
  const AdminQuestionEvent();

  @override
  List<Object?> get props => [];
}

class SubmitQuestionEvent extends AdminQuestionEvent {
  final String subject;
  final String questionText;
  final List<String> options;
  final int correctAnswer;
  final String? explanation;

  const SubmitQuestionEvent({
    required this.subject,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    this.explanation,
  });

  @override
  List<Object?> get props => [
        subject,
        questionText,
        options,
        correctAnswer,
        explanation,
      ];
}

class ResetAdminQuestionEvent extends AdminQuestionEvent {}
