import 'dart:io';

class CertificateHandler {
  const CertificateHandler();

  void applyTo(HttpClient client, {required bool allowSelfSignedCertificates}) {
    if (!allowSelfSignedCertificates) {
      return;
    }

    client.badCertificateCallback = (_, __, ___) => true;
  }
}
