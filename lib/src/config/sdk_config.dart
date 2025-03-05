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
  
  /// Check if SDK is initialized
  bool get isInitialized => _initialized;
  
  /// Get API key
  String get apiKey => _apiKey;
  
  /// Get API endpoint
  String get apiEndpoint => _apiEndpoint;
  
  /// Initialize the configuration
  void initialize({
    required String apiKey,
    required String apiEndpoint,
    String? appId, // 保留参数但标记为可选，以保持兼容性
  }) {
    _apiKey = apiKey;
    _apiEndpoint = apiEndpoint;
    _initialized = true;
  }
} 