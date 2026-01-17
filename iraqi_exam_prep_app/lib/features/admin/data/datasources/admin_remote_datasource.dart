import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../../exams/data/models/question_model.dart';
import '../../domain/entities/question_input.dart';
import '../models/activation_code_model.dart';

abstract class AdminRemoteDataSource {
  Future<void> addQuestion(QuestionInput input);
  Future<List<QuestionModel>> searchQuestions({String? subject, String? query});
  Future<void> updateQuestion(String id, QuestionInput input);
  Future<void> deleteQuestion(String id);
  Future<List<ActivationCodeModel>> generateCodes(GenerateCodeInput input);
  Future<List<ActivationCodeModel>> listCodes({String? status, int? limit});
  Future<void> revokeCode(String codeId);
  // User Management
  Future<List<Map<String, dynamic>>> searchUsers({String? phone});
  Future<void> promoteToAdmin(String userId);
  Future<void> demoteFromAdmin(String userId);
  Future<void> activateUser(String userId);
  Future<void> deactivateUser(String userId);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final DioClient dioClient;

  AdminRemoteDataSourceImpl(this.dioClient);

  @override
  Future<void> addQuestion(QuestionInput input) async {
    try {
      await dioClient.post(
        '/admin/questions',
        data: input.toJson(),
      );
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final error = responseData['error'];
        if (error is Map<String, dynamic>) {
          final message = error['message'] as String?;
          if (message != null) throw Exception(message);
        }
        final message = responseData['message'] as String?;
        if (message != null) throw Exception(message);
      }
      throw Exception('Failed to create question');
    }
  }
  @override
  Future<List<QuestionModel>> searchQuestions({String? subject, String? query}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (subject != null) queryParams['subject'] = subject;
      if (query != null) queryParams['search'] = query;

      final response = await dioClient.get(
        '/admin/questions',
        queryParameters: queryParams,
      );
      final data = response.data as Map<String, dynamic>;
      final questionsList = data['data']['questions'] as List<dynamic>;
      return questionsList
          .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final message = responseData['message'] as String?;
        if (message != null) throw Exception(message);
      }
      throw Exception('Failed to fetch questions');
    }
  }

  @override
  Future<void> updateQuestion(String id, QuestionInput input) async {
    try {
      await dioClient.patch(
        '/admin/questions/$id',
        data: input.toJson(),
      );
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final message = responseData['message'] as String?;
        if (message != null) throw Exception(message);
      }
      throw Exception('Failed to update question');
    }
  }

  @override
  Future<void> deleteQuestion(String id) async {
    try {
      await dioClient.delete('/admin/questions/$id');
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final message = responseData['message'] as String?;
        if (message != null) throw Exception(message);
      }
      throw Exception('Failed to delete question');
    }
  }
  @override
  Future<List<ActivationCodeModel>> generateCodes(GenerateCodeInput input) async {
    try {
      final response = await dioClient.post(
        '/admin/activation-codes',
        data: input.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      
      // Handle both single code and bulk codes response
      if (data['data']['codes'] != null) {
        final codesList = data['data']['codes'] as List<dynamic>;
        return codesList
            .map((e) => ActivationCodeModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data['data']['code'] != null) {
        return [ActivationCodeModel.fromJson(data['data']['code'] as Map<String, dynamic>)];
      }
      return [];
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final error = responseData['error'];
        if (error is Map<String, dynamic>) {
          final message = error['message'] as String?;
          if (message != null) throw Exception(message);
        }
        final message = responseData['message'] as String?;
        if (message != null) throw Exception(message);
      }
      throw Exception('Failed to generate codes');
    }
  }

  @override
  Future<List<ActivationCodeModel>> listCodes({String? status, int? limit}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (limit != null) queryParams['limit'] = limit.toString();

      final response = await dioClient.get(
        '/admin/activation-codes',
        queryParameters: queryParams,
      );
      final data = response.data as Map<String, dynamic>;
      final codesList = data['data']['codes'] as List<dynamic>;
      return codesList
          .map((e) => ActivationCodeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final message = responseData['message'] as String?;
        if (message != null) throw Exception(message);
      }
      throw Exception('Failed to fetch codes');
    }
  }

  @override
  Future<void> revokeCode(String codeId) async {
    try {
      await dioClient.patch('/admin/activation-codes/$codeId/revoke');
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final message = responseData['message'] as String?;
        if (message != null) throw Exception(message);
      }
      throw Exception('Failed to revoke code');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchUsers({String? phone}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (phone != null && phone.isNotEmpty) queryParams['phone'] = phone;

      final response = await dioClient.get(
        '/admin/users',
        queryParameters: queryParams,
      );
      final data = response.data as Map<String, dynamic>;
      final usersList = data['data']['users'] as List<dynamic>;
      return usersList.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final message = responseData['message'] as String?;
        if (message != null) throw Exception(message);
      }
      throw Exception('Failed to fetch users');
    }
  }

  @override
  Future<void> promoteToAdmin(String userId) async {
    try {
      await dioClient.patch('/admin/users/$userId/promote');
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final message = responseData['message'] as String?;
        if (message != null) throw Exception(message);
      }
      throw Exception('Failed to promote user');
    }
  }

  @override
  Future<void> demoteFromAdmin(String userId) async {
    try {
      await dioClient.patch('/admin/users/$userId/demote');
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final message = responseData['message'] as String?;
        if (message != null) throw Exception(message);
      }
      throw Exception('Failed to demote user');
    }
  }

  @override
  Future<void> activateUser(String userId) async {
    try {
      await dioClient.patch('/admin/users/$userId/activate');
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final message = responseData['message'] as String?;
        if (message != null) throw Exception(message);
      }
      throw Exception('Failed to activate user');
    }
  }

  @override
  Future<void> deactivateUser(String userId) async {
    try {
      await dioClient.patch('/admin/users/$userId/deactivate');
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final message = responseData['message'] as String?;
        if (message != null) throw Exception(message);
      }
      throw Exception('Failed to deactivate user');
    }
  }
}
