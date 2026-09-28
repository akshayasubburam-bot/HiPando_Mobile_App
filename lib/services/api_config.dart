/// API base URL configuration for each environment.
///
/// Android emulator:  http://10.0.2.2:5000/api/v1
///   (10.0.2.2 is the emulator's alias for the host machine's localhost)
///
/// Physical Android device on the same Wi-Fi:
///   Replace with your PC's LAN IP, e.g. http://192.168.1.42:5000/api/v1
///
/// Production: replace with your deployed HTTPS backend URL.
class ApiConfig {
  ApiConfig._(); // prevent instantiation

  static const String _emulatorBase  = 'http://10.0.2.2:5000/api/v1';
  static const String _lanBase       = 'http://192.168.0.77:5000/api/v1'; // PC Wi-Fi IP — physical device
  static const String _productionBase = 'https://your-production-url.com/api/v1'; // update on deploy

  // Toggle this to switch environments during development
  static const _env = _Env.lan; // physical device on same Wi-Fi

  static String get baseUrl {
    switch (_env) {
      case _Env.emulator:
        return _emulatorBase;
      case _Env.lan:
        return _lanBase;
      case _Env.production:
        return _productionBase;
    }
  }

  static const int connectTimeoutSeconds = 10;
  static const int receiveTimeoutSeconds = 15;
}

enum _Env { emulator, lan, production }
