import 'package:chat_bot_sdk/src/data/datasources/dify_remote_datasource.dart';
import 'package:chat_bot_sdk/src/domain/entities/chat_file_attachment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const image = ChatFileAttachment(
    type: 'image',
    transferMethod: 'local_file',
    uploadFileId: 'file-id',
  );

  test('keeps typed query when files are attached', () {
    expect(difyRequestQuery('What is this?', [image]), 'What is this?');
  });

  test('does not send empty query when files are attached', () {
    expect(difyRequestQuery('', [image]), difyFileOnlyQuery);
    expect(difyRequestQuery('   ', [image]), difyFileOnlyQuery);
  });

  test('does not invent query when there are no files', () {
    expect(difyRequestQuery('', []), '');
  });
}
