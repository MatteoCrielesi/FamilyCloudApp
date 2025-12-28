import 'package:flutter/material.dart';

class FileSelectorWidget extends StatelessWidget {
  const FileSelectorWidget({required this.onPickFiles, super.key});

  final VoidCallback onPickFiles;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPickFiles,
      child: const Text('Seleziona file'),
    );
  }
}
