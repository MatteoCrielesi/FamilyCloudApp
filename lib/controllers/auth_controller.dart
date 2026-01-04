import 'package:family_cloud_app/services/auth_service.dart';
import 'package:family_cloud_app/services/vpn_detection_service.dart';
import 'package:flutter/foundation.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    required AuthService authService,
    required VpnDetectionService vpnService,
  })  : _authService = authService,
        _vpnService = vpnService;

  final AuthService _authService;
  final VpnDetectionService _vpnService;

  bool _isLoading = false;
  String? _error;
  String? _username;
  bool _isLoggedIn = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get username => _username;
  bool get isLoggedIn => _isLoggedIn;

  Future<bool> login({
    required String url,
    required String username,
    required String password,
    bool isAppPassword = false, // Just for context, technically handled same by WebDAV
    bool saveCredentials = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Check Reachability
      final uri = Uri.tryParse(url);
      if (uri == null || !uri.hasScheme) {
        _error = 'URL non valido. Inserisci un URL completo (es. https://cloud.example.com)';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final vpnStatus = await _vpnService.checkVpnStatus(uri);
      if (!vpnStatus.isConnected) {
        _error = 'Server non raggiungibile. Controlla la connessione o la VPN.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 2. Perform Login
      final result = await _authService.login(
        baseUrl: url,
        username: username,
        password: password,
        saveCredentials: saveCredentials,
      );

      if (result['success'] == true) {
        _username = result['username'];
        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Errore imprevisto: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _username = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<Map<String, String?>> getSavedCredentials() {
    return _authService.getSavedCredentials();
  }
}
