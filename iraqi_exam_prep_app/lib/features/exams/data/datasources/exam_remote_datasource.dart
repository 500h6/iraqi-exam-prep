import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/question_model.dart';
import '../models/exam_result_model.dart';

abstract class ExamRemoteDataSource {
  Future<List<QuestionModel>> getExamQuestions(String subject);
  Future<ExamResultModel> submitExam({
    required String subject,
    required Map<String, int> answers,
  });
}

class ExamRemoteDataSourceImpl implements ExamRemoteDataSource {
  final DioClient dioClient;

  ExamRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<QuestionModel>> getExamQuestions(String subject) async {
    try {
      final response = await dioClient.get('/exams/$subject/questions');
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      final questionsJson = data['questions'] as List<dynamic>?;

      if (questionsJson == null) {
        throw Exception('Invalid response from server');
      }

      return questionsJson
          .map((json) => QuestionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final message = _extractErrorMessage(e) ?? 'Failed to get questions';
      throw Exception(message);
    }
  }

  @override
  Future<ExamResultModel> submitExam({
    required String subject,
    required Map<String, int> answers,
  }) async {
    try {
      final response = await dioClient.post(
        '/exams/$subject/submit',
        data: {'answers': answers},
      );
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      final resultJson = data['result'] as Map<String, dynamic>?;

      if (resultJson == null) {
        throw Exception('Invalid response from server');
      }

      return ExamResultModel.fromJson(resultJson);
    } on DioException catch (e) {
      final message = _extractErrorMessage(e) ?? 'Failed to submit exam';
      throw Exception(message);
    }
  }

  String? _extractErrorMessage(DioException e) {
    final responseData = e.response?.data;
    if (responseData is Map<String, dynamic>) {
      final error = responseData['error'];
      if (error is Map<String, dynamic>) {
        final message = error['message'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
      }
      final message = responseData['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    return e.message;
  }
}
