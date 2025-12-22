import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/entities/question_input.dart';

abstract class AdminRemoteDataSource {
  Future<void> addQuestion(QuestionInput input);
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
}
