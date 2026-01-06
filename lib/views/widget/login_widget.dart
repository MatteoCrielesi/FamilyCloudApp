import 'package:flutter/material.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({
    required this.onSubmit,
    this.isLoading = false,
    this.isLoggedIn = false,
    this.username,
    this.onCancel,
    super.key,
  });

  final void Function(
    String username,
    String password,
    bool isAppPassword,
  ) onSubmit;
  final bool isLoading;
  final bool isLoggedIn;
  final String? username;
  final VoidCallback? onCancel;

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isAppPassword = false;
  bool _showForm = true; // Mostra form di default, ma se loggato mostra prima lo stato

  @override
  void initState() {
    super.initState();
    // Se l'utente è loggato, nascondiamo il form inizialmente
    _showForm = !widget.isLoggedIn;
  }

  @override
  void didUpdateWidget(covariant LoginWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Se lo stato di login cambia, aggiorna la vista
    if (widget.isLoggedIn != oldWidget.isLoggedIn) {
       _showForm = !widget.isLoggedIn;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleForm() {
    setState(() {
      _showForm = !_showForm;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 300),
      crossFadeState: _showForm ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      // FORM DI LOGIN
      firstChild: Column(
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
            Row(
              children: [
                if (widget.isLoggedIn) ...[
                   Expanded(
                     child: OutlinedButton(
                       onPressed: _toggleForm,
                       child: const Text('Annulla'),
                     ),
                   ),
                   const SizedBox(width: 16),
                ],
                Expanded(
                  child: FilledButton(
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
                    child: Text(widget.isLoggedIn ? 'Conferma' : 'Accedi'),
                  ),
                ),
              ],
            ),
        ],
      ),
      
      // STATO LOGGATO
      secondChild: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
           Container(
             padding: const EdgeInsets.all(16),
             decoration: BoxDecoration(
               color: Colors.green.withValues(alpha: 0.1),
               borderRadius: BorderRadius.circular(8),
               border: Border.all(color: Colors.green),
             ),
             child: Column(
               children: [
                 const Icon(Icons.check_circle, color: Colors.green, size: 48),
                 const SizedBox(height: 8),
                 Text(
                   'Attualmente sei connesso come',
                   style: Theme.of(context).textTheme.bodyMedium,
                 ),
                 Text(
                   widget.username ?? 'Utente',
                   style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                 ),
               ],
             ),
           ),
           const SizedBox(height: 16),
           FilledButton(
             onPressed: _toggleForm,
             child: const Text('Cambia credenziali'),
           ),
        ],
      ),
    );
  }
}
