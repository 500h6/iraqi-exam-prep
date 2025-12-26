import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  });
  Future<void> logout();
  Future<bool> checkAuthStatus();
  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;
  final StorageService secureStorage;

  AuthRemoteDataSourceImpl(this.dioClient, this.secureStorage);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dioClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      final token = data['token'] as String?;
      final userJson = data['user'] as Map<String, dynamic>?;

      if (token == null || userJson == null) {
        throw Exception('Invalid response from server');
      }

      final user = UserModel.fromJson(userJson);

      // Store token
      await secureStorage.write(
        key: AppConstants.accessTokenKey,
        value: token,
      );
      await secureStorage.write(
        key: AppConstants.userIdKey,
        value: user.id,
      );

      return user;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e) ?? 'Login failed');
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      final response = await dioClient.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'name': name,
          if (phone != null) 'phone': phone,
        },
      );

      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      final token = data['token'] as String?;
      final userJson = data['user'] as Map<String, dynamic>?;

      if (token == null || userJson == null) {
        throw Exception('Invalid response from server');
      }

      final user = UserModel.fromJson(userJson);

      // Store token
      await secureStorage.write(
        key: AppConstants.accessTokenKey,
        value: token,
      );
      await secureStorage.write(
        key: AppConstants.userIdKey,
        value: user.id,
      );

      return user;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e) ?? 'Registration failed');
    }
  }

  @override
  Future<void> logout() async {
    await secureStorage.deleteAll();
  }

  @override
  Future<bool> checkAuthStatus() async {
    final token = await secureStorage.read(key: AppConstants.accessTokenKey);
    return token != null;
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await dioClient.get('/auth/me');
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      final userJson = data['user'] as Map<String, dynamic>?;

      if (userJson == null) {
        throw Exception('Invalid response from server');
      }

      return UserModel.fromJson(userJson);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e) ?? 'Failed to get user');
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
