import 'package:flutter_mon_loan_tracking/models/user.dart';
import 'package:flutter_mon_loan_tracking/models/user_type.dart';
import 'package:flutter_mon_loan_tracking/services/base_cache_service.dart';

class UserCacheService extends BaseCacheService<User> {
  final Map<String, User> _mappedUsers = {};
  User? loggedInUser;

  @override
  Future<User> add({required User data}) async {
    _mappedUsers[data.id] = data;
    return data;
  }

  Future<List<User>> addAll({required List<User> users}) {
    _mappedUsers.addAll({for (var user in users) user.id: user});
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

  Future<List<User>> agents() {
    final agents = _mappedUsers.values
        .where((user) => user.type == UserType.agent)
        .toList();

    return Future.value(agents);
  }

  Future<List<User>> customers() {
    final customers = _mappedUsers.values
        .where((user) => user.type == UserType.customer)
        .toList();

    return Future.value(customers);
  }
}
