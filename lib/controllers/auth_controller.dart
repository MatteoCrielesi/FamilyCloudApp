import 'package:flutter/foundation.dart';

class AuthController extends ChangeNotifier {
  String? _username;
  String? _appPassword;

  String? get username => _username;
  String? get appPassword => _appPassword;

  bool get isLoggedIn => _username != null && _appPassword != null;

  void setSession({required String username, required String appPassword}) {
    _username = username;
    _appPassword = appPassword;
    notifyListeners();
  }

  void clearSession() {
    _username = null;
    _appPassword = null;
    notifyListeners();
  }
}
