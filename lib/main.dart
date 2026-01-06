import 'package:family_cloud_app/controllers/app_controller.dart';
import 'package:family_cloud_app/controllers/auth_controller.dart';
import 'package:family_cloud_app/services/auth_service.dart';
import 'package:family_cloud_app/services/vpn_detection_service.dart';
import 'package:family_cloud_app/views/home_view.dart';
import 'package:family_cloud_app/views/widget/security_manager.dart';
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
        ChangeNotifierProvider(
          create: (_) => AppController()..loadSettings(),
        ),
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
      child: Consumer<AppController>(
        builder: (context, appController, child) {
          final primaryColor = Color(appController.settings.primaryColor);
          final secondaryColor = Color(appController.settings.secondaryColor);
          final isDark = primaryColor.computeLuminance() < 0.5;
          final textColor = isDark ? Colors.white : Colors.black;

          return MaterialApp(
            title: 'FamilyCloudApp',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: primaryColor,
                primary: primaryColor,
                secondary: secondaryColor,
                surface: primaryColor, // Backgrounds
                onSurface: textColor, // Text on backgrounds
              ),
              scaffoldBackgroundColor: primaryColor,
              useMaterial3: true,
              textTheme: Theme.of(context).textTheme.apply(
                bodyColor: textColor,
                displayColor: textColor,
              ),
              inputDecorationTheme: InputDecorationTheme(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: secondaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: secondaryColor, width: 2),
                ),
                labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
                hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
              ),
              cardTheme: CardThemeData(
                color: primaryColor,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: secondaryColor),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              dividerTheme: DividerThemeData(
                color: secondaryColor,
              ),
              iconTheme: IconThemeData(
                color: textColor,
              ),
              listTileTheme: ListTileThemeData(
                iconColor: textColor,
                textColor: textColor,
                selectedColor: secondaryColor,
                selectedTileColor: secondaryColor.withValues(alpha: 0.1),
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                selectedItemColor: secondaryColor,
                unselectedItemColor: textColor.withOpacity(0.6),
                backgroundColor: primaryColor,
              ),
              drawerTheme: DrawerThemeData(
                backgroundColor: primaryColor,
                scrimColor: Colors.black54,
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: primaryColor,
                foregroundColor: textColor,
              ),
              dialogTheme: DialogThemeData(
                backgroundColor: primaryColor,
                titleTextStyle: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
                contentTextStyle: TextStyle(color: textColor),
              ),
              switchTheme: SwitchThemeData(
                thumbColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return secondaryColor;
                  }
                  return null;
                }),
                trackColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return secondaryColor.withValues(alpha: 0.5);
                  }
                  return null;
                }),
              ),
              checkboxTheme: CheckboxThemeData(
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return secondaryColor;
                  }
                  return null;
                }),
              ),
              radioTheme: RadioThemeData(
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return secondaryColor;
                  }
                  return null;
                }),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryColor,
                  foregroundColor: isDark ? Colors.white : Colors.black,
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: secondaryColor,
                ),
              ),
            ),
             home: const SecurityManager(child: HomeView()),
          );
        },
      ),
    );
  }
}
