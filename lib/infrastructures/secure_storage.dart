class SecureStorage {
  SecureStorage();

  final Map<String, String> _values = <String, String>{};

  Future<void> write(String key, String value) async {
    _values[key] = value;
  }

  Future<String?> read(String key) async {
    return _values[key];
  }

  Future<void> delete(String key) async {
    _values.remove(key);
  }
}
