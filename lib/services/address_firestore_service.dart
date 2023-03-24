import 'package:flutter_mon_loan_tracking/exceptions/address_not_found_exception.dart';
import 'package:flutter_mon_loan_tracking/models/address.dart';
import 'package:flutter_mon_loan_tracking/services/base_firebase_service.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';

class AddressFirestoreService extends BaseFirestoreService<Address> {
  @override
  Future<Address> add({required Address data}) async {
    var doc = root.doc();

    if (data.id != Constants.NO_ID) {
      doc = root.doc(data.id);
      await doc.set(data.toJson());

      return data;
    } else {
      final updatedAddress = Address.updateId(id: doc.id, address: data);

      await doc.set(updatedAddress.toJson());

      return updatedAddress;
    }
  }

  @override
  Future<List<Address>> all() async {
    final doc = await root.orderBy('lastName').get();
    final addresses = doc.docs
        .map((e) => Address.fromJson(e.data() as Map<String, dynamic>))
        .toList();

    return addresses;
  }

  @override
  Future<Address> delete({required Address data}) async {
    final doc = root.doc(data.id);
    await doc.delete();

    return data;
  }

  @override
  Future<Address> get({required String id}) async {
    final doc = root.doc(id);
    final data = await doc.get();

    if (!data.exists) {
      return Future.error(AddressNotFoundException());
    }

    return Address.fromJson(data.data() as Map<String, dynamic>);
  }

  Future<Address> getByUserId({required String userId}) async {
    final doc = root.where('userId', isEqualTo: userId).limit(1);
    final data = await doc.get();

    if (data.docs.isEmpty) {
      return Future.error(AddressNotFoundException());
    }

    return Address.fromJson(data.docs[0].data() as Map<String, dynamic>);
  }

  @override
  Future<Address> update({required Address data}) async {
    final doc = root.doc(data.id);

    await doc.set(data.toJson());

    return data;
  }

  @override
  String get collectionName => 'address';
}