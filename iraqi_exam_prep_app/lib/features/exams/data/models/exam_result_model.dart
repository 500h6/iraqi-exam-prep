import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/exam_result_entity.dart';
import 'question_model.dart';

part 'exam_result_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ExamResultModel extends ExamResultEntity {
  @override
  final List<QuestionModel>? questions;

  const ExamResultModel({
    required String id,
    required String userId,
    required String subject,
    required int score,
    required int totalQuestions,
    required int correctAnswers,
    required int wrongAnswers,
    required double percentage,
    required bool passed,
    required DateTime completedAt,
    this.questions,
  }) : super(
          id: id,
          userId: userId,
          subject: subject,
          score: score,
          totalQuestions: totalQuestions,
          correctAnswers: correctAnswers,
          wrongAnswers: wrongAnswers,
          percentage: percentage,
          passed: passed,
          completedAt: completedAt,
          questions: questions,
        );


  factory ExamResultModel.fromJson(Map<String, dynamic> json) {
    return ExamResultModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      subject: json['subject'] as String,
      score: (json['score'] as num).toInt(),
      totalQuestions: (json['totalQuestions'] as num).toInt(),
      correctAnswers: (json['correctAnswers'] as num).toInt(),
      wrongAnswers: (json['wrongAnswers'] as num).toInt(),
      percentage: (json['percentage'] as num).toDouble(),
      passed: json['passed'] as bool,
      completedAt: DateTime.parse(json['completedAt'] as String),
      questions: json['questions'] != null
          ? (json['questions'] as List)
              .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => _$ExamResultModelToJson(this);
}
