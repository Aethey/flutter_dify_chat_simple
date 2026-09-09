// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dify_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DifyChatMessageRequestDto _$DifyChatMessageRequestDtoFromJson(Map json) =>
    DifyChatMessageRequestDto(
      query: json['query'] as String,
      inputs: Map<String, dynamic>.from(json['inputs'] as Map),
      responseMode: json['response_mode'] as String,
      user: json['user'] as String,
      conversationId: json['conversation_id'] as String?,
      files: (json['files'] as List<dynamic>?)
          ?.map(
            (e) =>
                DifyChatFileDto.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
    );

Map<String, dynamic> _$DifyChatMessageRequestDtoToJson(
  DifyChatMessageRequestDto instance,
) => <String, dynamic>{
  'query': instance.query,
  'inputs': instance.inputs,
  'response_mode': instance.responseMode,
  'user': instance.user,
  'conversation_id': ?instance.conversationId,
  'files': ?instance.files?.map((e) => e.toJson()).toList(),
};

DifyChatFileDto _$DifyChatFileDtoFromJson(Map json) => DifyChatFileDto(
  type: json['type'] as String,
  transferMethod: json['transfer_method'] as String,
  uploadFileId: json['upload_file_id'] as String?,
  url: json['url'] as String?,
);

Map<String, dynamic> _$DifyChatFileDtoToJson(DifyChatFileDto instance) =>
    <String, dynamic>{
      'type': instance.type,
      'transfer_method': instance.transferMethod,
      'upload_file_id': ?instance.uploadFileId,
      'url': ?instance.url,
    };

DifyMessagesResponseDto _$DifyMessagesResponseDtoFromJson(Map json) =>
    DifyMessagesResponseDto(
      data:
          (json['data'] as List<dynamic>?)
              ?.map(
                (e) => DifyMessageItemDto.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          [],
    );

Map<String, dynamic> _$DifyMessagesResponseDtoToJson(
  DifyMessagesResponseDto instance,
) => <String, dynamic>{'data': instance.data.map((e) => e.toJson()).toList()};

DifyMessageItemDto _$DifyMessageItemDtoFromJson(Map json) => DifyMessageItemDto(
  query: json['query'] as String?,
  answer: json['answer'] as String?,
);

Map<String, dynamic> _$DifyMessageItemDtoToJson(DifyMessageItemDto instance) =>
    <String, dynamic>{'query': ?instance.query, 'answer': ?instance.answer};

DifyUploadedFileDto _$DifyUploadedFileDtoFromJson(Map json) =>
    DifyUploadedFileDto(
      id: json['id'] as String,
      name: json['name'] as String?,
      mimeType: json['mime_type'] as String?,
      size: (json['size'] as num?)?.toInt(),
    );

Map<String, dynamic> _$DifyUploadedFileDtoToJson(
  DifyUploadedFileDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': ?instance.name,
  'mime_type': ?instance.mimeType,
  'size': ?instance.size,
};

DifyAudioToTextDto _$DifyAudioToTextDtoFromJson(Map json) =>
    DifyAudioToTextDto(text: json['text'] as String?);

Map<String, dynamic> _$DifyAudioToTextDtoToJson(DifyAudioToTextDto instance) =>
    <String, dynamic>{'text': ?instance.text};

DifyErrorDto _$DifyErrorDtoFromJson(Map json) => DifyErrorDto(
  code: json['code'] as String?,
  message: json['message'] as String?,
  status: (json['status'] as num?)?.toInt(),
);

Map<String, dynamic> _$DifyErrorDtoToJson(DifyErrorDto instance) =>
    <String, dynamic>{
      'code': ?instance.code,
      'message': ?instance.message,
      'status': ?instance.status,
    };

DifySseEventDto _$DifySseEventDtoFromJson(Map json) => DifySseEventDto(
  event: json['event'] as String?,
  answer: json['answer'] as String?,
  message: json['message'] as String?,
  conversationId: json['conversation_id'] as String?,
  text: json['text'] as String?,
  data: json['data'] == null
      ? null
      : DifySseEventDataDto.fromJson(
          Map<String, dynamic>.from(json['data'] as Map),
        ),
);

Map<String, dynamic> _$DifySseEventDtoToJson(DifySseEventDto instance) =>
    <String, dynamic>{
      'event': ?instance.event,
      'answer': ?instance.answer,
      'message': ?instance.message,
      'conversation_id': ?instance.conversationId,
      'text': ?instance.text,
      'data': ?instance.data?.toJson(),
    };

DifySseEventDataDto _$DifySseEventDataDtoFromJson(Map json) =>
    DifySseEventDataDto(
      status: json['status'] as String?,
      nodeType: json['node_type'] as String?,
      text: json['text'] as String?,
      outputs: (json['outputs'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e),
      ),
    );

Map<String, dynamic> _$DifySseEventDataDtoToJson(
  DifySseEventDataDto instance,
) => <String, dynamic>{
  'status': ?instance.status,
  'node_type': ?instance.nodeType,
  'text': ?instance.text,
  'outputs': ?instance.outputs,
};
