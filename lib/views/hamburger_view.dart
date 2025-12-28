import 'package:flutter/material.dart';

class HamburgerView extends StatelessWidget {
  const HamburgerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: const [DrawerHeader(child: Text('FamilyCloudApp'))],
      ),
    );
  }
}
