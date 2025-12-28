import 'package:flutter/material.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({required this.onSubmit, super.key});

  final void Function(String username, String password) onSubmit;

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _usernameController,
          decoration: const InputDecoration(labelText: 'Username'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => widget.onSubmit(
            _usernameController.text.trim(),
            _passwordController.text,
          ),
          child: const Text('Accedi'),
        ),
      ],
    );
  }
}
