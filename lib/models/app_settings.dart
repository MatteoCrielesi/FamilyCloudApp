class AppSettings {
  const AppSettings({
    required this.nextcloudBaseUrl,
    this.nextcloudReachabilityUrl,
    this.allowSelfSignedCertificates = false,
    this.primaryColor = 0xFF673AB7, // Colors.deepPurple default value
    this.secondaryColor = 0xFF9575CD, // Lighter purple default value
    this.notificationsEnabled = true,
    this.dndEnabled = false,
    this.dndStartTime = "22:00",
    this.dndEndTime = "07:00",
    this.appLockEnabled = false,
    this.autoLogoutEnabled = false,
    this.autoLogoutMinutes = 15,
    this.wifiOnlyUpload = false,
    this.compressImages = false,
  });

  final Uri nextcloudBaseUrl;
  final Uri? nextcloudReachabilityUrl;
  final bool allowSelfSignedCertificates;
  final int primaryColor;
  final int secondaryColor;
  final bool notificationsEnabled;
  final bool dndEnabled;
  final String dndStartTime;
  final String dndEndTime;
  final bool appLockEnabled;
  final bool autoLogoutEnabled;
  final int autoLogoutMinutes;
  final bool wifiOnlyUpload;
  final bool compressImages;

  AppSettings copyWith({
    Uri? nextcloudBaseUrl,
    Uri? nextcloudReachabilityUrl,
    bool? allowSelfSignedCertificates,
    int? primaryColor,
    int? secondaryColor,
    bool? notificationsEnabled,
    bool? dndEnabled,
    String? dndStartTime,
    String? dndEndTime,
    bool? appLockEnabled,
    bool? autoLogoutEnabled,
    int? autoLogoutMinutes,
    bool? wifiOnlyUpload,
    bool? compressImages,
  }) {
    return AppSettings(
      nextcloudBaseUrl: nextcloudBaseUrl ?? this.nextcloudBaseUrl,
      nextcloudReachabilityUrl: nextcloudReachabilityUrl ?? this.nextcloudReachabilityUrl,
      allowSelfSignedCertificates: allowSelfSignedCertificates ?? this.allowSelfSignedCertificates,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dndEnabled: dndEnabled ?? this.dndEnabled,
      dndStartTime: dndStartTime ?? this.dndStartTime,
      dndEndTime: dndEndTime ?? this.dndEndTime,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      autoLogoutEnabled: autoLogoutEnabled ?? this.autoLogoutEnabled,
      autoLogoutMinutes: autoLogoutMinutes ?? this.autoLogoutMinutes,
      wifiOnlyUpload: wifiOnlyUpload ?? this.wifiOnlyUpload,
      compressImages: compressImages ?? this.compressImages,
    );
  }
}
