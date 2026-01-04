import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:family_cloud_app/infrastructures/secure_storage.dart';

class AuthService {
  AuthService({SecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? SecureStorage();

  final SecureStorage _secureStorage;

  /// Creates a custom http.Client that trusts 'family.cloud'
  http.Client _createClient() {
    final ioc = HttpClient();
    ioc.badCertificateCallback = (X509Certificate cert, String host, int port) {
      return host == 'family.cloud';
    };
    return IOClient(ioc);
  }

  /// Authenticates the user against Nextcloud via WebDAV.
  ///
  /// [baseUrl] is the root URL of the Nextcloud instance (e.g. https://cloud.example.com).
  /// [username] is the user's login name.
  /// [password] is either the account password or an App Password.
  /// [saveCredentials] determines if credentials should be stored securely.
  Future<Map<String, dynamic>> login({
    required String baseUrl,
    required String username,
    required String password,
    bool saveCredentials = false,
  }) async {
    // Ensure baseUrl does not end with a slash for consistent path building
    final cleanBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    // Nextcloud WebDAV endpoint for files
    // Using /remote.php/webdav/ is also common, but /remote.php/dav/files/USER/ is more specific.
    // Let's try a simple PROPFIND on the user's root.
    final webDavUrl = Uri.parse('$cleanBaseUrl/remote.php/dav/files/$username/');

    final basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    final client = _createClient();
    try {
      final response = await http.Response.fromStream(
        await client.send(
          http.Request('PROPFIND', webDavUrl)
            ..headers['Authorization'] = basicAuth
            ..headers['Depth'] = '0',
        ),
      );

      if (response.statusCode == 207 || response.statusCode == 200) {
        // Success
        if (saveCredentials) {
          await _secureStorage.write('nextcloud_url', cleanBaseUrl);
          await _secureStorage.write('nextcloud_username', username);
          await _secureStorage.write('nextcloud_password', password);
        }
        return {
          'success': true,
          'username': username,
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': 'Credenziali non valide',
        };
      } else {
        return {
          'success': false,
          'error': 'Errore server: ${response.statusCode}',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'error': 'Impossibile raggiungere il server',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Errore sconosciuto: $e',
      };
    } finally {
      client.close();
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete('nextcloud_username');
    await _secureStorage.delete('nextcloud_password');
    // We might want to keep the URL
  }

  Future<Map<String, String?>> getSavedCredentials() async {
    return {
      'url': await _secureStorage.read('nextcloud_url'),
      'username': await _secureStorage.read('nextcloud_username'),
      'password': await _secureStorage.read('nextcloud_password'),
    };
  }
}
