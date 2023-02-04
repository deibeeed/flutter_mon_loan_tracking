import 'package:flutter_mon_loan_tracking/exceptions/user_not_found_exception.dart';
import 'package:flutter_mon_loan_tracking/models/user.dart';
import 'package:flutter_mon_loan_tracking/services/base_firebase_service.dart';

class UserFirestoreService extends BaseFirestoreService<User> {

  @override
  Future<User> add({required User data}) async {
    final doc = root.doc();
    final updatedUser = User.updateId(id: doc.id, user: data);

    await doc.set(updatedUser.toJson());

    return updatedUser;
  }

  @override
  Future<List<User>> all() async {
    final doc = await root.get();
    final users = doc.docs
        .map((e) => User.fromJson(e.data() as Map<String, dynamic>))
        .toList();

    return users;
  }

  @override
  Future<User> delete({required User data}) async {
    final doc = root.doc(data.id);
    await doc.delete();

    return data;
  }

  @override
  Future<User> get({required String id}) async {
    final doc = root.doc(id);
    final data = await doc.get();

    if (!data.exists) {
      return Future.error(UserNotFoundException());
    }

    return User.fromJson(data.data() as Map<String, dynamic>);
  }

  @override
  Future<User> update({required User data}) async {
    final doc = root.doc(data.id);

    await doc.set(data.toJson());

    return data;
  }

  @override
  String get collectionName => 'users';
}
