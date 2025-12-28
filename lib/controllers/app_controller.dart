import 'package:flutter/foundation.dart';

import 'package:family_cloud_app/models/app_settings.dart';

class AppController extends ChangeNotifier {
  AppController({required AppSettings settings}) : _settings = settings;

  AppSettings _settings;

  AppSettings get settings => _settings;

  void updateSettings(AppSettings settings) {
    _settings = settings;
    notifyListeners();
  }
}
