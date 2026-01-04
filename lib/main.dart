import 'package:family_cloud_app/views/vpn_required_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const FamilyCloudApp());
}

class FamilyCloudApp extends StatelessWidget {
  const FamilyCloudApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FamilyCloudApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const VpnRequiredView(),
    );
  }
}
