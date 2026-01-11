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
  final String? imageUrl;

  const SubmitQuestionEvent({
    required this.subject,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
        subject,
        questionText,
        options,
        correctAnswer,
        explanation,
        imageUrl,
      ];
}

class UpdateAdminQuestionEvent extends AdminQuestionEvent {
  final String id;
  final String subject;
  final String questionText;
  final List<String> options;
  final int correctAnswer;
  final String? explanation;
  final String? imageUrl;

  const UpdateAdminQuestionEvent({
    required this.id,
    required this.subject,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
        id,
        subject,
        questionText,
        options,
        correctAnswer,
        explanation,
        imageUrl,
      ];
}

class DeleteAdminQuestionEvent extends AdminQuestionEvent {
  final String id;

  const DeleteAdminQuestionEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class SearchAdminQuestionsEvent extends AdminQuestionEvent {
  final String? subject;
  final String? query;

  const SearchAdminQuestionsEvent({this.subject, this.query});

  @override
  List<Object?> get props => [subject, query];
}

class ResetAdminQuestionEvent extends AdminQuestionEvent {}
