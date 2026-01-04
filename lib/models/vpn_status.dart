class VpnStatus {
  const VpnStatus({
    required this.isConnected,
    this.hasSiteError = false,
    this.isInternetAvailable = true,
    this.message,
  });

  final bool isConnected;
  final bool hasSiteError;
  final bool isInternetAvailable;
  final String? message;
}
