import 'package:flutter/material.dart';

class VpnStatusWidget extends StatelessWidget {
  const VpnStatusWidget({
    required this.isConnected,
    this.hasSiteError = false,
    this.isInternetAvailable = true,
    this.isTwingateRunning = false,
    required this.isChecking,
    required this.onVerify,
    required this.onOpenTwingate,
    required this.onLogin,
    this.desktopTwingatePath,
    required this.onDesktopPickOrOpen,
    required this.onDesktopDownloadOrChange,
    super.key,
  });

  final bool isConnected;
  final bool hasSiteError;
  final bool isInternetAvailable;
  final bool isTwingateRunning;
  final bool isChecking;
  final VoidCallback onVerify;
  final VoidCallback onOpenTwingate;
  final VoidCallback onLogin;
  final String? desktopTwingatePath;
  final VoidCallback onDesktopPickOrOpen;
  final VoidCallback onDesktopDownloadOrChange;

  @override
  Widget build(BuildContext context) {
    final Color borderColor;
    final Color backgroundColor;
    final IconData icon;
    final String label;

    // Logic updated based on Internet vs VPN availability
    if (!isConnected) {
      if (!isInternetAvailable) {
        // No Internet
        borderColor = Colors.red;
        backgroundColor = Colors.red.withValues(alpha: 0.12);
        icon = Icons.signal_wifi_off;
        label = 'Problema internet assente';
      } else {
        // Internet OK, VPN Off
        borderColor = Colors.red;
        backgroundColor = Colors.red.withValues(alpha: 0.12);
        icon = Icons.lock_open;
        label = 'VPN non attiva';
      }
    } else if (hasSiteError) {
      borderColor = Colors.orange;
      backgroundColor = Colors.orange.withValues(alpha: 0.12);
      icon = Icons.warning_amber_rounded;
      label = 'VPN attiva (problemi server)';
    } else {
      borderColor = Colors.green;
      backgroundColor = Colors.green.withValues(alpha: 0.12);
      icon = Icons.lock;
      label = 'VPN attiva';
    }

    final isDesktop =
        Theme.of(context).platform == TargetPlatform.windows ||
        Theme.of(context).platform == TargetPlatform.macOS;

    final showOnlyVerify = isConnected && hasSiteError;
    // Show Twingate button only if Internet is available but VPN is off AND Twingate is NOT running (on Desktop)
    // On Mobile, we don't check for running process easily, so we usually show it.
    // However, the requirement is "se da pc l'app viene rilevata attiva in background il tasto apri twingate deve sparire".
    // So for desktop we check isTwingateRunning.
    final bool hideTwingateButton = isDesktop && isTwingateRunning;
    final showTwingate = !isConnected && isInternetAvailable && !hideTwingateButton;
    
    final showLogin = isConnected && !hasSiteError;
    
    // Show extra message for PC when VPN is off
    final showVpnMessage = isDesktop && !isConnected && isInternetAvailable;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: borderColor),
              const SizedBox(width: 8),
              Expanded(child: Text(label)),
            ],
          ),
          if (showVpnMessage) ...[
            const SizedBox(height: 4),
            Text(
              'Autentica o attiva la tua vpn per poter accedere al cloud.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton(
                onPressed: isChecking ? null : onVerify,
                child: Text(
                  isChecking ? 'Verifica in corso...' : 'Verifica VPN',
                ),
              ),
              if (!showOnlyVerify && showTwingate)
                if (isDesktop)
                  _DesktopTwingateMenuButton(
                    hasPath: desktopTwingatePath != null,
                    onPickOrOpen: onDesktopPickOrOpen,
                    onDownloadOrChange: onDesktopDownloadOrChange,
                  )
                else
                  FilledButton(
                    onPressed: onOpenTwingate,
                    child: const Text('Apri Twingate'),
                  ),
              if (!showOnlyVerify && showLogin)
                FilledButton(
                  onPressed: onLogin,
                  child: const Text('Login al Cloud'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DesktopTwingateMenuButton extends StatefulWidget {
  const _DesktopTwingateMenuButton({
    required this.hasPath,
    required this.onPickOrOpen,
    required this.onDownloadOrChange,
  });

  final bool hasPath;
  final VoidCallback onPickOrOpen;
  final VoidCallback onDownloadOrChange;

  @override
  State<_DesktopTwingateMenuButton> createState() =>
      _DesktopTwingateMenuButtonState();
}

class _DesktopTwingateMenuButtonState
    extends State<_DesktopTwingateMenuButton> {
  final MenuController _controller = MenuController();

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _controller,
      menuChildren: [
        MenuItemButton(
          onPressed: () {
            _controller.close();
            widget.onPickOrOpen();
          },
          child: Text(widget.hasPath ? 'Apri' : 'Seleziona file'),
        ),
        MenuItemButton(
          onPressed: () {
            _controller.close();
            widget.onDownloadOrChange();
          },
          child: Text(widget.hasPath ? 'Modifica percorso' : "Scarica l'app"),
        ),
      ],
      builder: (context, controller, child) {
        return FilledButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          child: const Text('Apri Twingate'),
        );
      },
    );
  }
}
