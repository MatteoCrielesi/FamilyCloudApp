import 'package:flutter/foundation.dart';

import 'package:family_cloud_app/models/vpn_status.dart';

class VpnController extends ChangeNotifier {
  VpnStatus _status = const VpnStatus(isConnected: false);

  VpnStatus get status => _status;

  void setStatus(VpnStatus status) {
    _status = status;
    notifyListeners();
  }
}
