class AppSettings {
  const AppSettings({
    required this.nextcloudBaseUrl,
    this.nextcloudReachabilityUrl,
    this.allowSelfSignedCertificates = false,
  });

  final Uri nextcloudBaseUrl;
  final Uri? nextcloudReachabilityUrl;
  final bool allowSelfSignedCertificates;
}
