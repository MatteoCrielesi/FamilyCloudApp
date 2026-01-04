import 'dart:async';
import 'dart:io';

import 'package:family_cloud_app/models/vpn_status.dart';

class VpnDetectionService {
  const VpnDetectionService();

  Future<VpnStatus> checkVpnStatus(
    Uri reachabilityUrl, {
    Duration timeout = const Duration(seconds: 3),
    bool allowSelfSignedCertificates = false,
  }) async {
    // 1. Check Cloud Connectivity
    final cloudStatus = await _checkUrl(
      reachabilityUrl,
      timeout: timeout,
      allowSelfSignedCertificates: allowSelfSignedCertificates,
    );

    if (cloudStatus.isConnected) {
      return cloudStatus;
    }

    // 2. If Cloud failed, check Internet Connectivity (Google)
    // We use a known stable public URL.
    final internetUrl = Uri.parse('https://www.google.com');
    final internetStatus = await _checkUrl(
      internetUrl,
      timeout: timeout,
      allowSelfSignedCertificates: false, // Public sites usually have valid certs
    );

    // If Google is reachable, it means we have Internet but no Cloud access -> VPN likely OFF
    if (internetStatus.isConnected) {
      return const VpnStatus(isConnected: false, isInternetAvailable: true);
    }

    // If Google is NOT reachable, it means we have No Internet
    return const VpnStatus(isConnected: false, isInternetAvailable: false);
  }

  Future<VpnStatus> _checkUrl(
    Uri url, {
    required Duration timeout,
    required bool allowSelfSignedCertificates,
  }) async {
    final client = HttpClient()..connectionTimeout = timeout;

    if (allowSelfSignedCertificates || url.host == 'family.cloud') {
      client.badCertificateCallback = (_, __, ___) => true;
    }

    try {
      final request = await client.getUrl(url).timeout(timeout);
      request.followRedirects = false;

      final response = await request.close().timeout(timeout);
      await response.drain<void>();

      final statusCode = response.statusCode;
      if (statusCode >= 200 && statusCode < 400) {
        return const VpnStatus(isConnected: true, hasSiteError: false);
      }

      return VpnStatus(
        isConnected: true,
        hasSiteError: true,
        message: 'HTTP $statusCode',
      );
    } on SocketException {
      return const VpnStatus(isConnected: false);
    } on TimeoutException {
      return const VpnStatus(isConnected: false);
    } on HandshakeException catch (e) {
      return VpnStatus(
        isConnected: true,
        hasSiteError: true,
        message: e.message,
      );
    } catch (e) {
      return VpnStatus(
        isConnected: true,
        hasSiteError: true,
        message: e.toString(),
      );
    } finally {
      client.close(force: true);
    }
  }

  Future<bool> isNextcloudReachable(
    Uri url, {
    Duration timeout = const Duration(seconds: 3),
    bool allowSelfSignedCertificates = false,
  }) async {
    final status = await checkVpnStatus(
      url,
      timeout: timeout,
      allowSelfSignedCertificates: allowSelfSignedCertificates,
    );
    return status.isConnected && !status.hasSiteError;
  }

  Future<bool> isTwingateRunning() async {
    try {
      if (Platform.isWindows) {
        // Check if Twingate.exe is in the task list
        final result = await Process.run(
          'tasklist',
          ['/FI', 'IMAGENAME eq Twingate.exe', '/FO', 'CSV', '/NH'],
        );
        return result.stdout.toString().contains('Twingate.exe');
      } else if (Platform.isMacOS) {
        // Check if Twingate is running using pgrep
        final result = await Process.run('pgrep', ['-x', 'Twingate']);
        return result.exitCode == 0;
      }
    } catch (e) {
      // Ignore errors and assume not running
    }
    return false;
  }
}
