import 'dart:io';

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:family_cloud_app/models/vpn_status.dart';
import 'package:family_cloud_app/services/vpn_detection_service.dart';
import 'package:family_cloud_app/views/widget/vpn_status_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class VpnRequiredView extends StatefulWidget {
  const VpnRequiredView({
    this.vpnDetectionService = const VpnDetectionService(),
    this.reachabilityUrl,
    this.autoCheckOnStart = true,
    super.key,
  });

  final VpnDetectionService vpnDetectionService;
  final Uri? reachabilityUrl;
  final bool autoCheckOnStart;

  @override
  State<VpnRequiredView> createState() => _VpnRequiredViewState();
}

class _VpnRequiredViewState extends State<VpnRequiredView> {
  VpnStatus _status = const VpnStatus(isConnected: false);
  bool _isChecking = false;
  String? _desktopTwingatePath;

  bool _isTwingateRunning = false;

  static final _defaultReachabilityUrl = Uri.parse('https://family.cloud/');
  static final _twingatePlayStoreUrl = Uri.parse(
    'https://play.google.com/store/apps/details?id=com.twingate&pcampaignid=web_share',
  );
  static final _twingateAppStoreUrl = Uri.parse(
    'https://apps.apple.com/it/app/twingate/id1501686317',
  );
  static final _twingateDownloadUrl = Uri.parse(
    'https://www.twingate.com/download',
  );
  static const _twingatePathPreferenceKey = 'twingate_path';

  @override
  void initState() {
    super.initState();
    _loadDesktopTwingatePath();
    if (widget.autoCheckOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkStatus();
      });
    }
  }

  Future<void> _loadDesktopTwingatePath() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_twingatePathPreferenceKey);
    if (!mounted) {
      return;
    }
    setState(() {
      _desktopTwingatePath = value;
    });
  }

  Future<void> _saveDesktopTwingatePath(String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_twingatePathPreferenceKey);
    } else {
      await prefs.setString(_twingatePathPreferenceKey, value);
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _desktopTwingatePath = value;
    });
  }

  Future<void> _checkStatus() async {
    if (_isChecking) {
      return;
    }

    setState(() {
      _isChecking = true;
    });

    final status = await widget.vpnDetectionService.checkVpnStatus(
      widget.reachabilityUrl ?? _defaultReachabilityUrl,
      allowSelfSignedCertificates: true,
    );

    final isTwingateRunning =
        await widget.vpnDetectionService.isTwingateRunning();

    if (!mounted) {
      return;
    }

    setState(() {
      _status = status;
      _isTwingateRunning = isTwingateRunning;
      _isChecking = false;
    });
  }

  Future<void> _openUrl(Uri url) async {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> _openTwingateMobile() async {
    if (Platform.isAndroid) {
      // Try opening via package name
      final success = await LaunchApp.openApp(
        androidPackageName: 'com.twingate',
        // Optional: appStoreLink: _twingatePlayStoreUrl.toString(),
        openStore: false,
      );
      // LaunchApp.openApp returns dynamic or int. 1 means success.
      // We check for 1 explicitly or check if it is not 0/false if strictly needed,
      // but dynamic comparison might trigger lint if inferred as int.
      // Casting to dynamic to avoid analyzer warning if it inferred int.
      if ((success as dynamic) == 1 || (success as dynamic) == true) {
        return;
      }
    }

    final candidates = <Uri>[Uri.parse('twingate://'), Uri.parse('twingate:')];

    for (final uri in candidates) {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }

    if (Platform.isAndroid) {
      // If LaunchApp failed, try opening store manually
      await _openUrl(_twingatePlayStoreUrl);
      return;
    }
    if (Platform.isIOS) {
      await _openUrl(_twingateAppStoreUrl);
      return;
    }
  }

  Future<void> _pickDesktopTwingatePath() async {
    if (Platform.isWindows) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['exe'],
      );
      final path = result?.files.single.path;
      if (path != null) {
        await _saveDesktopTwingatePath(path);
      }
      return;
    }

    if (Platform.isMacOS) {
      final path = await FilePicker.platform.getDirectoryPath();
      if (path != null) {
        await _saveDesktopTwingatePath(path);
      }
      return;
    }
  }

  Future<void> _openDesktopTwingate() async {
    // Prova prima con il protocollo URL che dovrebbe aprire l'interfaccia
    final twingateUri = Uri.parse('twingate://');
    if (await canLaunchUrl(twingateUri)) {
      await launchUrl(twingateUri);
      return;
    }

    final path = _desktopTwingatePath;
    if (path == null || path.isEmpty) {
      await _pickDesktopTwingatePath();
      return;
    }

    if (Platform.isWindows) {
      await Process.start(path, const [], runInShell: true);
      return;
    }

    if (Platform.isMacOS) {
      await Process.run('open', [path]);
      return;
    }
  }

  Future<void> _desktopPickOrOpen() async {
    if (_desktopTwingatePath == null) {
      await _pickDesktopTwingatePath();
      return;
    }
    await _openDesktopTwingate();
  }

  Future<void> _desktopDownloadOrChange() async {
    if (_desktopTwingatePath == null) {
      await _openUrl(_twingateDownloadUrl);
      return;
    }
    await _pickDesktopTwingatePath();
  }

  Future<void> _openTwingate() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await _openTwingateMobile();
      return;
    }

    if (Platform.isWindows || Platform.isMacOS) {
      await _openDesktopTwingate();
      return;
    }
  }

  Future<void> _loginToCloud() async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Login al Cloud'),
          content: const Text('TODO'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Chiudi'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('FamilyCloudApp'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VpnStatusWidget(
              isConnected: _status.isConnected,
              hasSiteError: _status.hasSiteError,
              isInternetAvailable: _status.isInternetAvailable,
              isTwingateRunning: _isTwingateRunning,
              isChecking: _isChecking,
              onVerify: _checkStatus,
              onOpenTwingate: _openTwingate,
              onLogin: _loginToCloud,
              desktopTwingatePath: _desktopTwingatePath,
              onDesktopPickOrOpen: _desktopPickOrOpen,
              onDesktopDownloadOrChange: _desktopDownloadOrChange,
            ),
            if (_status.message != null) ...[
              const SizedBox(height: 12),
              Text(_status.message!),
            ],
          ],
        ),
      ),
    );
  }
}
