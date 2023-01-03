import 'package:flutter/widgets.dart';
import 'package:test/auth/auth.dart';

import '../models/user_models.dart';

class UserProvider with ChangeNotifier {
  User? user;
  final AuthMethods _authMethods = AuthMethods();

  User? get getUser => user;

  Future<void> refreshUser() async {
    User user = await _authMethods.getUserDetails();
    print(user.uid);
    user = user;
    notifyListeners();
  }
}
