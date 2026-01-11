import 'package:equatable/equatable.dart';

class QuestionEntity extends Equatable {
  final String id;
  final String subject;
  final String questionText;
  final List<String> options;
  final int correctAnswer; // Index of correct answer (0-3)
  final String? explanation;
  final String? imageUrl;

  const QuestionEntity({
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
