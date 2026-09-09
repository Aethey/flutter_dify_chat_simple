import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../domain/entities/chat_file_attachment.dart';
import 'attachment_state.dart';
import 'providers.dart';

String difyTypeForPath(String filePath) {
  switch (p.extension(filePath).toLowerCase()) {
    case '.png':
    case '.jpg':
    case '.jpeg':
    case '.gif':
    case '.webp':
      return 'image';
    case '.mp3':
    case '.m4a':
    case '.wav':
    case '.amr':
      return 'audio';
    case '.mp4':
    case '.mov':
    case '.webm':
      return 'video';
    default:
      return 'document';
  }
}

class AttachmentNotifier extends Notifier<AttachmentState> {
  @override
  AttachmentState build() => const AttachmentState();

  Future<void> addFile({
    required String filePath,
    required String userId,
    String? type,
  }) async {
    final pending = PendingAttachment(
      id: const Uuid().v4(),
      localPath: filePath,
      type: type ?? difyTypeForPath(filePath),
      name: p.basename(filePath),
    );
    state = state.copyWith(items: [...state.items, pending]);

    try {
      final uploaded = await ref.read(uploadChatFileUseCaseProvider)(
        filePath: filePath,
        userId: userId,
      );
      state = state.copyWith(
        items: state.items
            .map(
              (item) => item.id == pending.id
                  ? item.copyWith(
                      uploadFileId: uploaded.id,
                      uploading: false,
                    )
                  : item,
            )
            .toList(),
      );
    } catch (_) {
      state = state.copyWith(
        items: state.items.where((item) => item.id != pending.id).toList(),
      );
      rethrow;
    }
  }

  void remove(String id) {
    state = state.copyWith(
      items: state.items.where((item) => item.id != id).toList(),
    );
  }

  List<ChatFileAttachment> takeReadyFiles() {
    final files = state.items
        .where((item) => item.uploadFileId != null && !item.uploading)
        .map(
          (item) => ChatFileAttachment(
            type: item.type,
            transferMethod: 'local_file',
            uploadFileId: item.uploadFileId,
            localPath: item.localPath,
            name: item.name,
          ),
        )
        .toList();
    state = const AttachmentState();
    return files;
  }
}

final attachmentProvider =
    NotifierProvider<AttachmentNotifier, AttachmentState>(
  AttachmentNotifier.new,
);
