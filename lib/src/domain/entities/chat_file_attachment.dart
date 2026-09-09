/// File attached to a chat message.
///
/// [type], [transferMethod], [uploadFileId], and [url] map to Dify
/// `/chat-messages` `files[]` fields. [localPath] is UI-only.
class ChatFileAttachment {
  /// Dify file type: image, document, audio, video, custom.
  final String type;

  /// Dify transfer method: remote_url or local_file.
  final String transferMethod;

  /// File id returned by POST /files/upload.
  final String? uploadFileId;

  /// Remote file URL when [transferMethod] is remote_url.
  final String? url;

  /// Local path used to preview the file in the UI.
  final String? localPath;

  /// Display name for non-image attachments. UI-only.
  final String? name;

  const ChatFileAttachment({
    required this.type,
    required this.transferMethod,
    this.uploadFileId,
    this.url,
    this.localPath,
    this.name,
  });

  /// JSON body fragment for POST /chat-messages.
  Map<String, dynamic> toApiJson() {
    final json = <String, dynamic>{
      'type': type,
      'transfer_method': transferMethod,
    };
    if (transferMethod == 'local_file' && uploadFileId != null) {
      json['upload_file_id'] = uploadFileId;
    }
    if (transferMethod == 'remote_url' && url != null) {
      json['url'] = url;
    }
    return json;
  }
}
