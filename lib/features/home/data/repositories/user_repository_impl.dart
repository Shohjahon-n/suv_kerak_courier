import 'package:dio/dio.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_data_source.dart';
import '../datasources/user_remote_data_source_impl.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._remoteDataSource);

  final UserRemoteDataSource _remoteDataSource;

  @override
  Future<User> fetchProfile() async {
    final UserModel model = await _remoteDataSource.fetchProfile();
    return model.toEntity();
  }

  static UserRepositoryImpl build(Dio dio) {
    return UserRepositoryImpl(UserRemoteDataSourceImpl(dio));
  }
}
