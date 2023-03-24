import 'package:flutter_mon_loan_tracking/models/address.dart';
import 'package:flutter_mon_loan_tracking/repositories/base_repository.dart';
import 'package:flutter_mon_loan_tracking/services/address_firestore_service.dart';

class AddressRepository extends BaseRepository<Address> {
  AddressRepository({
    required this.firestoreService,
  });
  final AddressFirestoreService firestoreService;

  @override
  Future<Address> add({required Address data}) {
    return firestoreService.add(data: data);
  }

  @override
  Future<List<Address>> all() {
    return firestoreService.all();
  }

  @override
  Future<Address> delete({required Address data}) {
    return firestoreService.delete(data: data);
  }

  @override
  Future<Address> get({required String id}) {
    return firestoreService.get(id: id);
  }

  Future<Address> getByUserId({required String userId}) {
    return firestoreService.getByUserId(userId: userId);
  }

  @override
  Future<Address> update({required Address data}) {
    return firestoreService.update(data: data);
  }
}