import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService {
  final _auth = FirebaseAuth.instance;

  Future<String?> login(
      {required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return credential.user?.uid;
  }

  Future<String?> register(
      {required String email, required String password}) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    return credential.user?.uid;
  }

  bool isLoggedIn() {
    return loggedInUser != null;
  }

  User? get loggedInUser => _auth.currentUser;
}
