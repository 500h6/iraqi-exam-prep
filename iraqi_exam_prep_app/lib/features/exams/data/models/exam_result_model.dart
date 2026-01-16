import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/exam_result_entity.dart';
import 'question_model.dart';

part 'exam_result_model.g.dart';

@JsonSerializable()
class ExamResultModel extends ExamResultEntity {
  const ExamResultModel({
    required super.id,
    required super.userId,
    required super.subject,
    required super.score,
    required super.totalQuestions,
    required super.correctAnswers,
    required super.wrongAnswers,
    required super.percentage,
    required super.passed,
    required super.completedAt,
    super.questions,
  });


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
