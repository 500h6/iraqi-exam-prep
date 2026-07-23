// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamResultModel _$ExamResultModelFromJson(Map<String, dynamic> json) =>
    ExamResultModel(
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
      questions: (json['questions'] as List<dynamic>?)
          ?.map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ExamResultModelToJson(ExamResultModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'subject': instance.subject,
      'score': instance.score,
      'totalQuestions': instance.totalQuestions,
      'correctAnswers': instance.correctAnswers,
      'wrongAnswers': instance.wrongAnswers,
      'percentage': instance.percentage,
      'passed': instance.passed,
      'completedAt': instance.completedAt.toIso8601String(),
      'questions': instance.questions?.map((e) => e.toJson()).toList(),
    };
