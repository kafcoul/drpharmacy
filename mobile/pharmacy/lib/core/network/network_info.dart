abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  // Setup real connection checker later if needed
  // For emulator/local dev we assume always connected usually
  // Or inject a checker
  
  @override
  Future<bool> get isConnected => Future.value(true);
}
