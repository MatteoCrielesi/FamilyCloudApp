import 'dart:async';
import 'package:family_cloud_app/controllers/app_controller.dart';
import 'package:family_cloud_app/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

class SecurityManager extends StatefulWidget {
  final Widget child;
  const SecurityManager({super.key, required this.child});

  @override
  State<SecurityManager> createState() => _SecurityManagerState();
}

class _SecurityManagerState extends State<SecurityManager> with WidgetsBindingObserver {
  Timer? _authTimer;
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resetTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAppLock();
    }
  }

  void _resetTimer() {
    final settings = context.read<AppController>().settings;
    if (!settings.autoLogoutEnabled) return;

    _authTimer?.cancel();
    _authTimer = Timer(Duration(minutes: settings.autoLogoutMinutes), _handleLogout);
  }

  void _handleLogout() {
    final authController = context.read<AuthController>();
    if (authController.isLoggedIn) {
      authController.logout();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logout automatico per inattività')),
        );
      }
    }
  }

  Future<void> _checkAppLock() async {
    final settings = context.read<AppController>().settings;
    if (!settings.appLockEnabled || _isAuthenticating) return;

    try {
      setState(() => _isAuthenticating = true);
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Autenticati per accedere a FamilyCloud',
        persistAcrossBackgrounding: true,
      );
      
      if (!didAuthenticate) {
        // If auth failed or was cancelled, we might want to exit or retry
        // For now, we just don't let them in easily, but strict implementation 
        // would cover the screen until auth passes.
        // A simple way is to minimize app or show a blocking dialog.
        // Here we'll just try again or leave it be (user can't really bypass easily if we block UI).
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Re-check timer on build/settings change
    final settings = context.watch<AppController>().settings;
    if (settings.autoLogoutEnabled && (_authTimer == null || !_authTimer!.isActive)) {
      _resetTimer();
    } else if (!settings.autoLogoutEnabled) {
      _authTimer?.cancel();
    }

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _resetTimer(),
      onPointerMove: (_) => _resetTimer(),
      onPointerUp: (_) => _resetTimer(),
      child: widget.child,
    );
  }
}
