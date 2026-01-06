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
        backgroundColor = Colors.red.withValues(alpha: 0.40);
        icon = Icons.signal_wifi_off;
        label = 'Problema internet assente';
      } else {
        // Internet OK, VPN Off
        borderColor = Colors.red;
        backgroundColor = Colors.red.withValues(alpha: 0.4);
        icon = Icons.lock_open;
        label = 'VPN non attiva';
      }
    } else if (hasSiteError) {
      borderColor = Colors.orange;
      backgroundColor = Colors.orange.withValues(alpha: 0.4);
      icon = Icons.warning_amber_rounded;
      label = 'VPN attiva (problemi server)';
    } else {
      borderColor = Colors.green;
      backgroundColor = Colors.green.withValues(alpha: 0.4);
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

    // Button style
    // "stesso colore della vpn" -> backgroundColor (pale)
    // "bordo come la vpn solo 1% più scuro" -> borderColor darkened by 1%
    final hslBorder = HSLColor.fromColor(borderColor);
    final darkenedBorder = hslBorder.withLightness((hslBorder.lightness - 0.01).clamp(0.0, 1.0)).toColor();
    
    final buttonStyle = FilledButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: Theme.of(context).textTheme.bodyMedium?.color, // Text color matches the main element text
      side: BorderSide(color: darkenedBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );

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
                style: buttonStyle,
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
                    style: buttonStyle,
                    dropdownBackgroundColor: backgroundColor,
                    dropdownBorderColor: darkenedBorder,
                  )
                else
                  FilledButton(
                    onPressed: onOpenTwingate,
                    style: buttonStyle,
                    child: const Text('Apri Twingate'),
                  ),
              if (!showOnlyVerify && showLogin)
                FilledButton(
                  onPressed: onLogin,
                  style: buttonStyle,
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
    required this.style,
    required this.dropdownBackgroundColor,
    required this.dropdownBorderColor,
  });

  final bool hasPath;
  final VoidCallback onPickOrOpen;
  final VoidCallback onDownloadOrChange;
  final ButtonStyle style;
  final Color dropdownBackgroundColor;
  final Color dropdownBorderColor;

  @override
  State<_DesktopTwingateMenuButton> createState() =>
      _DesktopTwingateMenuButtonState();
}

class _DesktopTwingateMenuButtonState
    extends State<_DesktopTwingateMenuButton> {
  final MenuController _controller = MenuController();
  final GlobalKey _buttonKey = GlobalKey();
  double? _buttonWidth;

  void _updateWidth() {
    final RenderBox? renderBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _buttonWidth = renderBox.size.width;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return MenuAnchor(
      controller: _controller,
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(widget.dropdownBackgroundColor),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: widget.dropdownBorderColor),
          ),
        ),
        minimumSize: _buttonWidth != null
            ? WidgetStatePropertyAll(Size(_buttonWidth!, 0))
            : null,
        maximumSize: _buttonWidth != null
            ? WidgetStatePropertyAll(Size(_buttonWidth!, double.infinity))
            : null,
      ),
      menuChildren: [
        MenuItemButton(
          onPressed: () {
            _controller.close();
            widget.onPickOrOpen();
          },
          style: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(theme.textTheme.bodyMedium?.color),
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.hovered)) {
                return theme.colorScheme.secondary.withValues(alpha: 0.1);
              }
              return null;
            }),
          ),
          child: Text(widget.hasPath ? 'Apri' : 'Seleziona file'),
        ),
        MenuItemButton(
          onPressed: () {
            _controller.close();
            widget.onDownloadOrChange();
          },
          style: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(theme.textTheme.bodyMedium?.color),
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.hovered)) {
                return theme.colorScheme.secondary.withValues(alpha: 0.1);
              }
              return null;
            }),
          ),
          child: Text(widget.hasPath ? 'Modifica percorso' : "Scarica l'app"),
        ),
      ],
      builder: (context, controller, child) {
        return FilledButton(
          key: _buttonKey,
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              _updateWidth();
              // Wait for the rebuild to apply the new style with the correct width
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) controller.open();
              });
            }
          },
          style: widget.style,
          child: const Text('Apri Twingate'),
        );
      },
    );
  }
}
