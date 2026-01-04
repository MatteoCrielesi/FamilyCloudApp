import 'package:flutter/material.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({
    required this.onSubmit,
    this.isLoading = false,
    super.key,
  });

  final void Function(
    String username,
    String password,
    bool isAppPassword,
  ) onSubmit;
  final bool isLoading;

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isAppPassword = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Switch per scegliere il tipo di password
        Row(
          children: [
            const Text('Account Password'),
            Switch(
              value: _isAppPassword,
              onChanged: widget.isLoading 
                  ? null 
                  : (value) {
                      setState(() {
                        _isAppPassword = value;
                      });
                    },
            ),
            const Text('App Password'),
          ],
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _usernameController,
          decoration: const InputDecoration(
            labelText: 'Username',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          enabled: !widget.isLoading,
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: _isAppPassword ? 'App Password' : 'Password',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.lock),
            helperText: _isAppPassword 
                ? 'Usa una password specifica per app generata in Nextcloud' 
                : 'Usa la tua password di login principale',
          ),
          obscureText: true,
          enabled: !widget.isLoading,
        ),
        const SizedBox(height: 24),

        if (widget.isLoading)
          const Center(child: CircularProgressIndicator())
        else
          FilledButton(
            onPressed: () {
              final username = _usernameController.text.trim();
              final password = _passwordController.text.trim();

              if (username.isEmpty || password.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Compila tutti i campi')),
                );
                return;
              }

              widget.onSubmit(username, password, _isAppPassword);
            },
            child: const Text('Login'),
          ),
      ],
    );
  }
}
