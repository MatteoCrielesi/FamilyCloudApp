import 'package:flutter/material.dart';

class VpnRequiredView extends StatelessWidget {
  const VpnRequiredView({required this.onOpenVpn, super.key});

  final VoidCallback onOpenVpn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VPN richiesta')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Attiva la VPN per accedere a Nextcloud.'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onOpenVpn,
                child: const Text('Apri Twingate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
