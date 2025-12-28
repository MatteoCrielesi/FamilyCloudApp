import 'dart:io';

import 'package:family_cloud_app/infrastructures/certificate_handler.dart';

class HttpClientFactory {
  const HttpClientFactory({required this.certificateHandler});

  final CertificateHandler certificateHandler;

  HttpClient create({required bool allowSelfSignedCertificates}) {
    final client = HttpClient();
    certificateHandler.applyTo(
      client,
      allowSelfSignedCertificates: allowSelfSignedCertificates,
    );
    return client;
  }
}
