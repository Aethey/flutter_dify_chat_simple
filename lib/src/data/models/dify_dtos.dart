import 'package:json_annotation/json_annotation.dart';

part 'dify_dtos.g.dart';

/// POST /chat-messages JSON body.
@JsonSerializable()
class DifyChatMessageRequestDto {
  const DifyChatMessageRequestDto({
    required this.query,
    required this.inputs,
    required this.responseMode,
    required this.user,
    this.conversationId,
    this.files,
  });

  factory DifyChatMessageRequestDto.fromJson(Map<String, dynamic> json) =>
      _$DifyChatMessageRequestDtoFromJson(json);

  final String query;
  final Map<String, dynamic> inputs;
  final String responseMode;
  final String user;
  final String? conversationId;
  final List<DifyChatFileDto>? files;

  Map<String, dynamic> toJson() => _$DifyChatMessageRequestDtoToJson(this);
}

/// `files[]` item on POST /chat-messages.
@JsonSerializable()
class DifyChatFileDto {
  const DifyChatFileDto({
    required this.type,
    required this.transferMethod,
    this.uploadFileId,
    this.url,
  });

  factory DifyChatFileDto.fromJson(Map<String, dynamic> json) =>
      _$DifyChatFileDtoFromJson(json);

  final String type;
  final String transferMethod;
  final String? uploadFileId;
  final String? url;

  Map<String, dynamic> toJson() => _$DifyChatFileDtoToJson(this);
}

/// GET /messages list payload.
@JsonSerializable()
class DifyMessagesResponseDto {
  const DifyMessagesResponseDto({required this.data});

  factory DifyMessagesResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DifyMessagesResponseDtoFromJson(json);

  @JsonKey(defaultValue: <DifyMessageItemDto>[])
  final List<DifyMessageItemDto> data;

  Map<String, dynamic> toJson() => _$DifyMessagesResponseDtoToJson(this);
}

/// One history row from GET /messages `data[]`.
@JsonSerializable()
class DifyMessageItemDto {
  const DifyMessageItemDto({this.query, this.answer});

  factory DifyMessageItemDto.fromJson(Map<String, dynamic> json) =>
      _$DifyMessageItemDtoFromJson(json);

  final String? query;
  final String? answer;

  Map<String, dynamic> toJson() => _$DifyMessageItemDtoToJson(this);
}

/// POST /files/upload JSON body.
@JsonSerializable()
class DifyUploadedFileDto {
  const DifyUploadedFileDto({
    required this.id,
    this.name,
    this.mimeType,
    this.size,
  });

  factory DifyUploadedFileDto.fromJson(Map<String, dynamic> json) =>
      _$DifyUploadedFileDtoFromJson(json);

  final String id;
  final String? name;
  final String? mimeType;
  final int? size;

  Map<String, dynamic> toJson() => _$DifyUploadedFileDtoToJson(this);
}

/// POST /audio-to-text JSON body.
@JsonSerializable()
class DifyAudioToTextDto {
  const DifyAudioToTextDto({this.text});

  factory DifyAudioToTextDto.fromJson(Map<String, dynamic> json) =>
      _$DifyAudioToTextDtoFromJson(json);

  final String? text;

  Map<String, dynamic> toJson() => _$DifyAudioToTextDtoToJson(this);
}

/// Dify error JSON (`code`, `message`, `status`).
@JsonSerializable()
class DifyErrorDto {
  const DifyErrorDto({this.code, this.message, this.status});

  factory DifyErrorDto.fromJson(Map<String, dynamic> json) =>
      _$DifyErrorDtoFromJson(json);

  final String? code;
  final String? message;
  final int? status;

  Map<String, dynamic> toJson() => _$DifyErrorDtoToJson(this);
}

/// One SSE `data:` JSON object from POST /chat-messages.
@JsonSerializable()
class DifySseEventDto {
  const DifySseEventDto({
    this.event,
    this.answer,
    this.message,
    this.conversationId,
    this.text,
    this.data,
  });

  factory DifySseEventDto.fromJson(Map<String, dynamic> json) =>
      _$DifySseEventDtoFromJson(json);

  final String? event;
  final String? answer;
  final String? message;
  final String? conversationId;
  final String? text;
  final DifySseEventDataDto? data;

  Map<String, dynamic> toJson() => _$DifySseEventDtoToJson(this);
}

/// Nested `data` on workflow/node SSE events.
@JsonSerializable()
class DifySseEventDataDto {
  const DifySseEventDataDto({
    this.status,
    this.nodeType,
    this.text,
    this.outputs,
  });

  factory DifySseEventDataDto.fromJson(Map<String, dynamic> json) =>
      _$DifySseEventDataDtoFromJson(json);

  final String? status;
  final String? nodeType;
  final String? text;
  final Map<String, dynamic>? outputs;

  Map<String, dynamic> toJson() => _$DifySseEventDataDtoToJson(this);
}
