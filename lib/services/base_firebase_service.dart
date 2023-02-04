import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_mon_loan_tracking/services/environments.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';

abstract class BaseFirestoreService<T> {
  final _fs = FirebaseFirestore.instance;

  CollectionReference get root {
    var rootPath = 'dev_$collectionName';

    if (Constants.currentEnvironment == Environments.staging) {
      rootPath = 'stg_$collectionName';
    } else if (Constants.currentEnvironment == Environments.production) {
      rootPath = collectionName;
    }

    return _fs.collection(rootPath);
  }

  String get collectionName;
  Future<T> add({ required T data });
  Future<T> update({ required T data});
  Future<T> delete({ required T data });
  Future<T> get({ required String id });
  Future<List<T>> all();
}