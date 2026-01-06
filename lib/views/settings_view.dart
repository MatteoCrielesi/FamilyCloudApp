import 'package:family_cloud_app/controllers/app_controller.dart';
import 'package:family_cloud_app/models/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = info.version;
      _buildNumber = info.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appController = context.watch<AppController>();
    final settings = appController.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildColorSection(context, appController, settings),
          const SizedBox(height: 24),
          _buildNotificationSection(context, appController, settings),
          const SizedBox(height: 24),
          _buildSecuritySection(context, appController, settings),
          const SizedBox(height: 24),
          _buildUploadSection(context, appController, settings),
          const SizedBox(height: 24),
          _buildInfoSection(context),
        ],
      ),
    );
  }

  Widget _buildColorSection(BuildContext context, AppController controller, AppSettings settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Colori', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Colore Principale (Sfondi)'),
              trailing: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(settings.secondaryColor), width: 2),
                ),
                child: CircleAvatar(backgroundColor: Color(settings.primaryColor)),
              ),
              onTap: () => _showColorPicker(context, Color(settings.primaryColor), (color) {
                controller.updateSettings(settings.copyWith(primaryColor: color.value));
              }),
            ),
            ListTile(
              title: const Text('Colore Secondario (Bordi)'),
              trailing: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(settings.secondaryColor), width: 2),
                ),
                child: CircleAvatar(backgroundColor: Color(settings.secondaryColor)),
              ),
              onTap: () => _showColorPicker(context, Color(settings.secondaryColor), (color) {
                controller.updateSettings(settings.copyWith(secondaryColor: color.value));
              }),
            ),
            const SizedBox(height: 8),
            Text(
              'Nota: Il colore del testo (bianco o nero) verrà scelto automaticamente in base al colore principale.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection(BuildContext context, AppController controller, AppSettings settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notifiche', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Abilita Notifiche'),
              value: settings.notificationsEnabled,
              onChanged: (value) {
                controller.updateSettings(settings.copyWith(notificationsEnabled: value));
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Non Disturbare'),
              subtitle: const Text('Disabilita le notifiche in orari specifici'),
              value: settings.dndEnabled,
              onChanged: settings.notificationsEnabled
                  ? (value) {
                      controller.updateSettings(settings.copyWith(dndEnabled: value));
                    }
                  : null,
            ),
            if (settings.dndEnabled && settings.notificationsEnabled) ...[
              ListTile(
                title: const Text('Inizio'),
                trailing: Text(settings.dndStartTime),
                onTap: () => _selectTime(context, settings.dndStartTime, (time) {
                  controller.updateSettings(settings.copyWith(dndStartTime: time));
                }),
              ),
              ListTile(
                title: const Text('Fine'),
                trailing: Text(settings.dndEndTime),
                onTap: () => _selectTime(context, settings.dndEndTime, (time) {
                  controller.updateSettings(settings.copyWith(dndEndTime: time));
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection(BuildContext context, AppController controller, AppSettings settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sicurezza', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Blocco App'),
              subtitle: const Text('Richiedi autenticazione all\'avvio'),
              value: settings.appLockEnabled,
              onChanged: (value) {
                controller.updateSettings(settings.copyWith(appLockEnabled: value));
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Logout Automatico'),
              subtitle: const Text('Dopo un periodo di inattività'),
              value: settings.autoLogoutEnabled,
              onChanged: (value) {
                controller.updateSettings(settings.copyWith(autoLogoutEnabled: value));
              },
            ),
            if (settings.autoLogoutEnabled)
              ListTile(
                title: const Text('Timeout'),
                trailing: DropdownButton<int>(
                  value: settings.autoLogoutMinutes,
                  items: const [
                    DropdownMenuItem(value: 5, child: Text('5 minuti')),
                    DropdownMenuItem(value: 15, child: Text('15 minuti')),
                    DropdownMenuItem(value: 30, child: Text('30 minuti')),
                    DropdownMenuItem(value: 60, child: Text('1 ora')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.updateSettings(settings.copyWith(autoLogoutMinutes: value));
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection(BuildContext context, AppController controller, AppSettings settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gestione Upload/Download', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Solo Wi-Fi'),
              subtitle: const Text('Carica/Scarica file pesanti solo sotto Wi-Fi'),
              value: settings.wifiOnlyUpload,
              onChanged: (value) {
                controller.updateSettings(settings.copyWith(wifiOnlyUpload: value));
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Comprimi Immagini'),
              subtitle: const Text('Riduci dimensione prima dell\'upload'),
              value: settings.compressImages,
              onChanged: (value) {
                controller.updateSettings(settings.copyWith(compressImages: value));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Info App', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Versione'),
              subtitle: Text('$_version (Build $_buildNumber)'),
              leading: const Icon(Icons.info_outline),
            ),
            ListTile(
              title: const Text('Privacy Policy'),
              leading: const Icon(Icons.privacy_tip_outlined),
              onTap: () async {
                const url = 'https://family.cloud/privacy'; // Placeholder URL
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                }
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Svuota Cache'),
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              textColor: Colors.red,
              onTap: () => _clearCache(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _clearCache(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Svuota Cache'),
        content: const Text('Sei sicuro di voler eliminare tutti i file temporanei?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annulla')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Elimina')),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final cacheDir = await getTemporaryDirectory();
        if (cacheDir.existsSync()) {
          cacheDir.deleteSync(recursive: true);
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cache svuotata con successo')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Errore durante lo svuotamento della cache: $e')),
          );
        }
      }
    }
  }

  void _showColorPicker(
    BuildContext context,
    Color currentColor,
    Function(Color) onColorSelected,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        Color tempColor = currentColor;
        return AlertDialog(
          title: const Text('Seleziona un colore'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: tempColor,
              onColorChanged: (color) => tempColor = color,
              enableAlpha: false,
              labelTypes: const [],
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () {
                onColorSelected(tempColor);
                Navigator.of(context).pop();
              },
              child: const Text('Salva'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectTime(BuildContext context, String currentTime, Function(String) onTimeSelected) async {
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      final formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      onTimeSelected(formattedTime);
    }
  }
}
