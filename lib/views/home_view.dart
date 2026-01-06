import 'dart:io';
import 'package:family_cloud_app/controllers/auth_controller.dart';
import 'package:family_cloud_app/models/vpn_status.dart';
import 'package:family_cloud_app/services/vpn_detection_service.dart';
import 'package:family_cloud_app/views/widget/login_widget.dart';
import 'package:family_cloud_app/views/widget/vpn_status_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  VpnStatus _status = const VpnStatus(isConnected: false);
  bool _isChecking = false;
  bool _showLoginForm = false;
  String? _desktopTwingatePath;
  bool _isTwingateRunning = false;
  int _currentIndex = 0;

  static final _defaultReachabilityUrl = Uri.parse('https://family.cloud/');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkStatus();
    });
  }

  Future<void> _checkStatus() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);

    final vpnService = context.read<VpnDetectionService>();
    final status = await vpnService.checkVpnStatus(_defaultReachabilityUrl);

    setState(() {
      _status = status;
      _isChecking = false;
    });

    if (!status.isConnected || status.hasSiteError || context.read<AuthController>().username == null) {
      _scaffoldKey.currentState?.openDrawer();
    }
  }

  Future<void> _openTwingate() async {
    final playStoreUrl = Uri.parse(
      'https://play.google.com/store/apps/details?id=com.twingate&pcampaignid=web_share',
    );
    final appStoreUrl = Uri.parse('https://apps.apple.com/it/app/twingate/id1501686317');
    final desktopUrl = Uri.parse('https://www.twingate.com/download');
    final url = Platform.isAndroid
        ? playStoreUrl
        : Platform.isIOS
            ? appStoreUrl
            : desktopUrl;
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _toggleLoginForm() {
    setState(() {
      _showLoginForm = !_showLoginForm;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    Navigator.pop(context);
  }

  Color _getVpnColor() {
    if (!_status.isConnected) {
      return Colors.red;
    } else if (_status.hasSiteError) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final username = context.select<AuthController, String?>((c) => c.username);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu, color: _getVpnColor()),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Home'),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Consumer<AuthController>(
            builder: (context, authController, child) {
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                    const Text('FamilyCloudApp', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    VpnStatusWidget(
                      isConnected: _status.isConnected,
                      hasSiteError: _status.hasSiteError,
                      isInternetAvailable: _status.isInternetAvailable,
                      isTwingateRunning: _isTwingateRunning,
                      isChecking: _isChecking,
                      onVerify: _checkStatus,
                      onOpenTwingate: _openTwingate,
                      onLogin: _toggleLoginForm,
                      desktopTwingatePath: _desktopTwingatePath,
                      onDesktopPickOrOpen: () {},
                      onDesktopDownloadOrChange: () {},
                    ),
                    if (_status.isConnected && !_status.hasSiteError && _showLoginForm) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text('Accesso Nextcloud', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
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
                          isLoggedIn: authController.isLoggedIn,
                          username: authController.username,
                          onSubmit: (u, p, isAppPassword) async {
                            final url = _defaultReachabilityUrl.toString();
                           await authController.login(
                              url: url,
                              username: u,
                              password: p,
                              isAppPassword: isAppPassword,
                              saveCredentials: true,
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 16),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.perm_media),
                        title: const Text('Media'),
                        selected: _currentIndex == 0,
                        onTap: () => _onItemTapped(0),
                        trailing: const Text('TODO', style: TextStyle(color: Colors.grey, fontSize: 10)),
                      ),
                      ListTile(
                        leading: const Icon(Icons.folder),
                        title: const Text('File'),
                        selected: _currentIndex == 1,
                        onTap: () => _onItemTapped(1),
                        trailing: const Text('TODO', style: TextStyle(color: Colors.grey, fontSize: 10)),
                      ),
                      ListTile(
                        leading: const Icon(Icons.computer),
                        title: const Text('Programma'),
                        selected: _currentIndex == 2,
                        onTap: () => _onItemTapped(2),
                        trailing: const Text('TODO', style: TextStyle(color: Colors.grey, fontSize: 10)),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () => context.read<AuthController>().logout(),
                      tooltip: 'Logout',
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () {}, // TODO
                      tooltip: 'Impostazioni',
                    ),
                  ],
                ),
              ),
            ],
          );
        },
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.perm_media, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text('Media', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text('Benvenuto, ${username ?? 'Utente'}!', style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
          const Center(child: Text('File Content (TODO)')),
          const Center(child: Text('Programma Content (TODO)')),
        ],
      ),
    );
  }
}
