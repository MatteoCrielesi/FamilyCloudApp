import 'package:flutter/foundation.dart';

class FileController extends ChangeNotifier {
  String _currentPath = '/';

  String get currentPath => _currentPath;

  void setCurrentPath(String path) {
    _currentPath = path;
    notifyListeners();
  }
}
