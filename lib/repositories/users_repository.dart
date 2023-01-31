import 'package:flutter_mon_loan_tracking/models/user.dart' as UserModel;
import 'package:flutter_mon_loan_tracking/repositories/base_repository.dart';
import 'package:flutter_mon_loan_tracking/services/user_firestore_service.dart';

class UsersRepository extends BaseRepository<UserModel.User>{
  UsersRepository({
    required this.firestoreService,
});
  final UserFirestoreService firestoreService;

  @override
  Future<UserModel.User> add({required UserModel.User data}) {
    return firestoreService.add(data: data);
  }

  @override
  Future<List<UserModel.User>> all() {
    return firestoreService.all();
  }

  @override
  Future<UserModel.User> delete({required UserModel.User data}) {
    return firestoreService.delete(data: data);
  }

  @override
  Future<UserModel.User> get({required String id}) {
    return firestoreService.get(id: id);
  }

  @override
  Future<UserModel.User> update({required UserModel.User data}) {
    return firestoreService.update(data: data);
  }

}