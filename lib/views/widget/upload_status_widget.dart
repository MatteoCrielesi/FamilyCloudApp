import 'package:flutter/material.dart';

class UploadStatusWidget extends StatelessWidget {
  const UploadStatusWidget({required this.progress, super.key});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(value: progress),
        const SizedBox(height: 8),
        Text('${(progress * 100).toStringAsFixed(0)}%'),
      ],
    );
  }
}
