import 'package:flutter/material.dart';

import 'package:family_cloud_app/views/widget/upload_status_widget.dart';

class UploadStatusView extends StatelessWidget {
  const UploadStatusView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: UploadStatusWidget(progress: 0),
      ),
    );
  }
}
