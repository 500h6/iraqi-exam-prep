import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

abstract class ActivationRemoteDataSource {
  Future<bool> validateCode(String code);
  Future<bool> checkSubscription();
}

class ActivationRemoteDataSourceImpl implements ActivationRemoteDataSource {
  final DioClient dioClient;

  ActivationRemoteDataSourceImpl(this.dioClient);

  @override
  Future<bool> validateCode(String code) async {
    try {
      final response = await dioClient.post(
        '/activation/validate',
        data: {'code': code},
      );
      return response.data['success'] == true;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to validate code');
    }
  }

  @override
  Future<bool> checkSubscription() async {
    try {
      final response = await dioClient.get('/activation/status');
      return response.data['isPremium'] == true;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to check subscription');
    }
  }
}
