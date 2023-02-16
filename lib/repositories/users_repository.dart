import 'package:flutter_mon_loan_tracking/models/user.dart' as UserModel;
import 'package:flutter_mon_loan_tracking/repositories/base_repository.dart';
import 'package:flutter_mon_loan_tracking/services/user_cache_service.dart';
import 'package:flutter_mon_loan_tracking/services/user_firestore_service.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';

class UserRepository extends BaseRepository<UserModel.User> {
  UserRepository({
    required this.firestoreService,
    required this.cacheService,
  });

  final UserFirestoreService firestoreService;
  final UserCacheService cacheService;

  @override
  Future<UserModel.User> add({required UserModel.User data}) {
    return firestoreService
        .add(data: data)
        .then((value) => cacheService.add(data: value));
  }

  @override
  Future<List<UserModel.User>> all() {
    return firestoreService.all()
    .then((value) => cacheService.addAll(users: value));
  }

  Future<List<UserModel.User>> allCache() {
    return cacheService.all();
  }

  @override
  Future<UserModel.User> delete({required UserModel.User data}) {
    return firestoreService
        .delete(data: data)
        .then((value) => cacheService.delete(data: data));
  }

  @override
  Future<UserModel.User> get({required String id}) async {
    
    try {
      return await cacheService.get(id: id);
    } catch (err) {
      printd(err);
    }
    
    return firestoreService.get(id: id).then((value) => cacheService.add(data: value));
  }

  @override
  Future<UserModel.User> update({required UserModel.User data}) {
    return firestoreService.update(data: data);
  }
}
