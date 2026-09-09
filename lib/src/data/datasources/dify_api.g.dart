// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dify_api.dart';

// dart format off

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: type=lint
// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter,avoid_unused_constructor_parameters,unreachable_from_main,avoid_redundant_argument_values

class _DifyApi implements DifyApi {
  _DifyApi(this._dio, {this.baseUrl, this.errorLogger});

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<DifyMessagesResponseDto> getMessages({
    required String conversationId,
    required String user,
    int limit = 20,
    String? firstId,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'conversation_id': conversationId,
      r'user': user,
      r'limit': limit,
      r'first_id': firstId,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<DifyMessagesResponseDto>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/messages',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late DifyMessagesResponseDto _value;
    try {
      _value = DifyMessagesResponseDto.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Stream<Uint8List> streamChatMessages(DifyChatMessageRequestDto body) async* {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{
      r'Accept': 'text/event-stream',
      r'Content-Type': 'application/json',
    };
    _headers.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final _options = _setStreamType<Uint8List>(
      Options(
            method: 'POST',
            headers: _headers,
            extra: _extra,
            contentType: 'application/json',
            responseType: ResponseType.stream,
          )
          .compose(
            _dio.options,
            '/chat-messages',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = _dio.fetch<ResponseBody>(_options);
    final _value = _result.asStream().asyncExpand(
      (response) => response.data!.stream,
    );
    yield* _value;
  }

  @override
  Future<DifyUploadedFileDto> uploadFile({
    required File file,
    required String user,
    Map<String, dynamic>? metadata,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = FormData();
    final _file_fileName =
        (metadata?['file_fileName'] as String?) ??
        file.path.split(Platform.pathSeparator).last;
    final DioMediaType? _file_contentType =
        (metadata?['file_contentType'] as String?) != null
        ? DioMediaType.parse(metadata!['file_contentType'] as String)
        : null;
    _data.files.add(
      MapEntry(
        'file',
        MultipartFile.fromFileSync(
          file.path,
          filename: _file_fileName,
          contentType: _file_contentType,
        ),
      ),
    );
    _data.fields.add(MapEntry('user', user));
    final _options = _setStreamType<DifyUploadedFileDto>(
      Options(
            method: 'POST',
            headers: _headers,
            extra: _extra,
            contentType: 'multipart/form-data',
          )
          .compose(
            _dio.options,
            '/files/upload',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late DifyUploadedFileDto _value;
    try {
      _value = DifyUploadedFileDto.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<DifyAudioToTextDto> audioToText({
    required File file,
    required String user,
    Map<String, dynamic>? metadata,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = FormData();
    final _file_fileName =
        (metadata?['file_fileName'] as String?) ??
        file.path.split(Platform.pathSeparator).last;
    final DioMediaType? _file_contentType =
        (metadata?['file_contentType'] as String?) != null
        ? DioMediaType.parse(metadata!['file_contentType'] as String)
        : null;
    _data.files.add(
      MapEntry(
        'file',
        MultipartFile.fromFileSync(
          file.path,
          filename: _file_fileName,
          contentType: _file_contentType,
        ),
      ),
    );
    _data.fields.add(MapEntry('user', user));
    final _options = _setStreamType<DifyAudioToTextDto>(
      Options(
            method: 'POST',
            headers: _headers,
            extra: _extra,
            contentType: 'multipart/form-data',
          )
          .compose(
            _dio.options,
            '/audio-to-text',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late DifyAudioToTextDto _value;
    try {
      _value = DifyAudioToTextDto.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}

// dart format on
