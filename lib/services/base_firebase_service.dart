import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_mon_loan_tracking/services/base_cache_service.dart';
import 'package:flutter_mon_loan_tracking/services/environments.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';

abstract class BaseFirestoreService<T> extends BaseCacheService<T>{
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
}