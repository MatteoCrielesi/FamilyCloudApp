import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:family_cloud_app/models/app_settings.dart';

class AppController extends ChangeNotifier {
  AppController() : _settings = AppSettings(nextcloudBaseUrl: Uri(scheme: 'https', host: 'family.cloud'));

  AppSettings _settings;
  bool _isLoaded = false;

  AppSettings get settings => _settings;
  bool get isLoaded => _isLoaded;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final baseUrl = prefs.getString('nextcloudBaseUrl');
    final reachabilityUrl = prefs.getString('nextcloudReachabilityUrl');
    final allowSelfSigned = prefs.getBool('allowSelfSignedCertificates') ?? false;
    
    final primaryColor = prefs.getInt('primaryColor') ?? 0xFF673AB7;
    final secondaryColor = prefs.getInt('secondaryColor') ?? 0xFF9575CD;
    final notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    final dndEnabled = prefs.getBool('dndEnabled') ?? false;
    final dndStartTime = prefs.getString('dndStartTime') ?? "22:00";
    final dndEndTime = prefs.getString('dndEndTime') ?? "07:00";

    final appLockEnabled = prefs.getBool('appLockEnabled') ?? false;
    final autoLogoutEnabled = prefs.getBool('autoLogoutEnabled') ?? false;
    final autoLogoutMinutes = prefs.getInt('autoLogoutMinutes') ?? 15;
    final wifiOnlyUpload = prefs.getBool('wifiOnlyUpload') ?? false;
    final compressImages = prefs.getBool('compressImages') ?? false;

    _settings = AppSettings(
      nextcloudBaseUrl: baseUrl != null ? Uri.parse(baseUrl) : Uri.parse('https://family.cloud'),
      nextcloudReachabilityUrl: reachabilityUrl != null ? Uri.parse(reachabilityUrl) : null,
      allowSelfSignedCertificates: allowSelfSigned,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      notificationsEnabled: notificationsEnabled,
      dndEnabled: dndEnabled,
      dndStartTime: dndStartTime,
      dndEndTime: dndEndTime,
      appLockEnabled: appLockEnabled,
      autoLogoutEnabled: autoLogoutEnabled,
      autoLogoutMinutes: autoLogoutMinutes,
      wifiOnlyUpload: wifiOnlyUpload,
      compressImages: compressImages,
    );
    
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings settings) async {
    _settings = settings;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nextcloudBaseUrl', settings.nextcloudBaseUrl.toString());
    if (settings.nextcloudReachabilityUrl != null) {
      await prefs.setString('nextcloudReachabilityUrl', settings.nextcloudReachabilityUrl.toString());
    } else {
      await prefs.remove('nextcloudReachabilityUrl');
    }
    await prefs.setBool('allowSelfSignedCertificates', settings.allowSelfSignedCertificates);
    
    await prefs.setInt('primaryColor', settings.primaryColor);
    await prefs.setInt('secondaryColor', settings.secondaryColor);
    await prefs.setBool('notificationsEnabled', settings.notificationsEnabled);
    await prefs.setBool('dndEnabled', settings.dndEnabled);
    await prefs.setString('dndStartTime', settings.dndStartTime);
    await prefs.setString('dndEndTime', settings.dndEndTime);

    await prefs.setBool('appLockEnabled', settings.appLockEnabled);
    await prefs.setBool('autoLogoutEnabled', settings.autoLogoutEnabled);
    await prefs.setInt('autoLogoutMinutes', settings.autoLogoutMinutes);
    await prefs.setBool('wifiOnlyUpload', settings.wifiOnlyUpload);
    await prefs.setBool('compressImages', settings.compressImages);
  }
}
