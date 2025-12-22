import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/exam_result_entity.dart';

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
  });

  factory ExamResultModel.fromJson(Map<String, dynamic> json) =>
      _$ExamResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExamResultModelToJson(this);
}
