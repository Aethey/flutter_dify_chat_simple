import 'package:freezed_annotation/freezed_annotation.dart';

part 'attachment_state.freezed.dart';

/// UI-only pending file before / while uploading to Dify.
@freezed
abstract class PendingAttachment with _$PendingAttachment {
  const factory PendingAttachment({
    required String id,
    required String localPath,
    required String type,
    required String name,
    String? uploadFileId,
    @Default(true) bool uploading,
  }) = _PendingAttachment;
}

@freezed
abstract class AttachmentState with _$AttachmentState {
  const AttachmentState._();

  const factory AttachmentState({
    @Default(<PendingAttachment>[]) List<PendingAttachment> items,
  }) = _AttachmentState;

  bool get isUploading => items.any((item) => item.uploading);

  bool get hasReadyFile =>
      items.any((item) => item.uploadFileId != null && !item.uploading);
}
