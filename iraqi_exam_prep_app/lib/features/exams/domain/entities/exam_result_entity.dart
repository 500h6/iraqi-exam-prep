import 'package:equatable/equatable.dart';

class ExamResultEntity extends Equatable {
  final String id;
  final String userId;
  final String subject;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final double percentage;
  final bool passed;
  final DateTime completedAt;

  const ExamResultEntity({
    required this.id,
    required this.userId,
    required this.subject,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.percentage,
    required this.passed,
    required this.completedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        subject,
        score,
        totalQuestions,
        correctAnswers,
        wrongAnswers,
        percentage,
        passed,
        completedAt,
      ];
}
