import 'package:family_cloud_app/controllers/auth_controller.dart';
import 'package:family_cloud_app/services/auth_service.dart';
import 'package:family_cloud_app/services/vpn_detection_service.dart';
 import 'package:family_cloud_app/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const FamilyCloudApp());
}

class FamilyCloudApp extends StatelessWidget {
  const FamilyCloudApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<VpnDetectionService>(
          create: (_) => const VpnDetectionService(),
        ),
        ProxyProvider<VpnDetectionService, AuthService>(
          update: (_, vpnService, __) => AuthService(),
        ),
        ChangeNotifierProxyProvider2<AuthService, VpnDetectionService, AuthController>(
          create: (context) => AuthController(
            authService: context.read<AuthService>(),
            vpnService: context.read<VpnDetectionService>(),
          ),
          update: (context, authService, vpnService, previous) =>
              previous ??
              AuthController(
                authService: authService,
                vpnService: vpnService,
              ),
        ),
      ],
      child: MaterialApp(
        title: 'FamilyCloudApp',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
         home: const HomeView(),
      ),
    );
  }
}
