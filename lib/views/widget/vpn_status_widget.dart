import 'package:flutter/material.dart';

class VpnStatusWidget extends StatelessWidget {
  const VpnStatusWidget({required this.isConnected, super.key});

  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isConnected ? Icons.lock : Icons.lock_open,
          color: isConnected ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Text(isConnected ? 'VPN attiva' : 'VPN non attiva'),
      ],
    );
  }
}
