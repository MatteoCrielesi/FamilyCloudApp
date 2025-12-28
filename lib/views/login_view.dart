import 'package:flutter/material.dart';

import 'package:family_cloud_app/views/widget/login_widget.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LoginWidget(onSubmit: (_, __) {}),
      ),
    );
  }
}
