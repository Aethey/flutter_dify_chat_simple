/// Configuration for the ChatBot SDK
class SdkConfig {
  /// Singleton instance
  static final SdkConfig instance = SdkConfig._();

  /// Private constructor
  SdkConfig._();

  /// Whether the SDK has been initialized
  bool _initialized = false;

  /// API key for authentication
  late String _apiKey;

  /// API endpoint URL
  late String _apiEndpoint;

  /// Initial message for welcome screen
  String? _initialMessage;

  /// Check if SDK is initialized
  bool get isInitialized => _initialized;

  /// Get API key
  String get apiKey => _apiKey;

  /// Get API endpoint
  String get apiEndpoint => _apiEndpoint;

  /// Get initial message
  String? get initialMessage => _initialMessage;

  /// Initialize the configuration
  void initialize({
    required String apiKey,
    required String apiEndpoint,
    String? appId, // 保留参数但标记为可选，以保持兼容性
    String? initialMessage,
  }) {
    _apiKey = apiKey;
    _apiEndpoint = apiEndpoint;
    _initialMessage = initialMessage;
    _initialized = true;
  }

  /// Set initial message
  void setInitialMessage(String message) {
    _initialMessage = message;
  }
}
