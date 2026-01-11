import 'package:dio/dio.dart';

import '../models/user_model.dart';
import 'user_remote_data_source.dart';

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  UserRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<UserModel> fetchProfile() async {
    final response = await _dio.get<Map<String, dynamic>>('/profile');
    final data = response.data;
    if (data == null) {
      throw StateError('Empty response body');
    }
    return UserModel.fromJson(data);
  }
}
