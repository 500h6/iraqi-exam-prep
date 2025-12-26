import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/data/models/user_model.dart';

abstract class ActivationRemoteDataSource {
  Future<UserModel?> validateCode(String code);
  Future<bool> checkSubscription();
}

class ActivationRemoteDataSourceImpl implements ActivationRemoteDataSource {
  final DioClient dioClient;

  ActivationRemoteDataSourceImpl(this.dioClient);

  @override
  Future<UserModel?> validateCode(String code) async {
    try {
      final response = await dioClient.post(
        '/activation/validate',
        data: {'code': code},
      );
      
      // If the backend returns success: true, we want to succeed even if parsing fails
      // (This handles the transition period before the backend is deployed)
      if (response.data['success'] == true) {
        try {
          return UserModel.fromJson(response.data['data']);
        } catch (e) {
          // Parsing failed (likely old backend format), return null as a success fallback
          return null;
        }
      }
      throw Exception('Activation failed');
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
