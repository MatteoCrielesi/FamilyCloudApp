import 'package:family_cloud_app/controllers/auth_controller.dart';
import 'package:family_cloud_app/views/widget/login_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nextcloud Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<AuthController>(
          builder: (context, authController, child) {
            // Listen for error changes to show snackbar (better done in a listener, but this works for simple cases)
            // Ideally use addPostFrameCallback or a separate listener widget.
            // For simplicity, we just display the error if it exists in the UI or let the controller handle state.
            
            if (authController.isLoggedIn) {
               return Center(
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     const Icon(Icons.check_circle, color: Colors.green, size: 64),
                     const SizedBox(height: 16),
                     Text(
                       'Login effettuato con successo!\nBenvenuto ${authController.username}',
                       textAlign: TextAlign.center,
                       style: Theme.of(context).textTheme.headlineSmall,
                     ),
                     const SizedBox(height: 24),
                     FilledButton(
                       onPressed: () => authController.logout(),
                       child: const Text('Logout'),
                     ),
                   ],
                 ),
               );
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  if (authController.error != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authController.error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  LoginWidget(
                    isLoading: authController.isLoading,
                    onSubmit: (username, password, isAppPassword) async {
                      // Nota: LoginView non ha accesso diretto all'URL se non glielo passiamo.
                      // Tuttavia LoginView non è più la view principale. 
                      // Per compatibilità, se mai venisse usata, bisognerebbe recuperare l'URL dallo storage o da altrove.
                      // Qui mettiamo un placeholder o recuperiamo quello salvato se possibile.
                      final savedCreds = await authController.getSavedCredentials();
                      final url = savedCreds['url'] ?? '';
                      
                      if (!context.mounted) return;

                      if (url.isEmpty) {
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('URL server non trovato. Usa la verifica VPN.')),
                         );
                         return;
                      }

                      await authController.login(
                        url: url,
                        username: username,
                        password: password,
                        isAppPassword: isAppPassword,
                        saveCredentials: true,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
