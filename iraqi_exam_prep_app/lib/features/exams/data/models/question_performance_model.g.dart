// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_performance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestionPerformanceModel _$QuestionPerformanceModelFromJson(
        Map<String, dynamic> json) =>
    QuestionPerformanceModel(
      questionId: json['questionId'] as String,
      timesCorrect: (json['timesCorrect'] as num).toInt(),
      timesWrong: (json['timesWrong'] as num).toInt(),
      lastAttempt: json['lastAttempt'] == null
          ? null
          : DateTime.parse(json['lastAttempt'] as String),
    );

Map<String, dynamic> _$QuestionPerformanceModelToJson(
        QuestionPerformanceModel instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      'timesCorrect': instance.timesCorrect,
      'timesWrong': instance.timesWrong,
      'lastAttempt': instance.lastAttempt?.toIso8601String(),
    };
