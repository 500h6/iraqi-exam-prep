import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/entities/question_input.dart';
import '../models/activation_code_model.dart';

abstract class AdminRemoteDataSource {
  Future<void> addQuestion(QuestionInput input);
  Future<List<ActivationCodeModel>> generateCodes(GenerateCodeInput input);
  Future<List<ActivationCodeModel>> listCodes({String? status, int? limit});
  Future<void> revokeCode(String codeId);
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
}
