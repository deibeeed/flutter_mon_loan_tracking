import 'package:flutter_mon_loan_tracking/models/user.dart';
import 'package:flutter_mon_loan_tracking/services/base_cache_service.dart';

class UserCacheService extends BaseCacheService<User> {
  final Map<String, User> _mappedUsers = {};

  @override
  Future<User> add({required User data}) async {
    _mappedUsers[data.id] = data;
    return data;
  }
  
  Future<List<User>> addAll({ required List<User> users }) {
    _mappedUsers.addAll({ for (var user in users) user.id: user});
    return Future.value(users);
  }

  @override
  Future<List<User>> all() async {
    return _mappedUsers.values.toList();
  }

  @override
  Future<User> delete({required User data}) async {
    _mappedUsers.removeWhere((key, value) => key == data.id);

    return data;
  }

  @override
  Future<User> get({required String id}) async {
    return Future.value(_mappedUsers[id]);
  }

  @override
  Future<User> update({required User data}) async {
    return add(data: data);
  }
}