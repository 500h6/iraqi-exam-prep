import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/question_entity.dart';

part 'question_model.g.dart';

@JsonSerializable()
class QuestionModel extends QuestionEntity {
  const QuestionModel({
    required super.id,
    required super.subject,
    required super.questionText,
    required super.options,
    required super.correctAnswer,
    super.explanation,
    super.imageUrl,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionModelToJson(this);
}
