import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/data/models/user_model.dart';

abstract class ActivationRemoteDataSource {
  Future<UserModel> validateCode(String code);
  Future<bool> checkSubscription();
}

class ActivationRemoteDataSourceImpl implements ActivationRemoteDataSource {
  final DioClient dioClient;

  ActivationRemoteDataSourceImpl(this.dioClient);

  @override
  Future<UserModel> validateCode(String code) async {
    try {
      final response = await dioClient.post(
        '/activation/validate',
        data: {'code': code},
      );
      return UserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to validate code');
    }
  }

  @override
  Future<bool> checkSubscription() async {
    try {
      final response = await dioClient.get('/activation/status');
      return response.data['data']['isPremium'] == true;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to check subscription');
    }
  }
}
