import 'package:family_cloud_app/models/file_item.dart';
import 'package:family_cloud_app/models/folder_item.dart';

class WebDavService {
  const WebDavService();

  Future<List<Object>> listItems({
    required Uri baseUrl,
    required String username,
    required String appPassword,
    required String path,
  }) async {
    throw UnimplementedError();
  }

  Future<void> createFolder({
    required Uri baseUrl,
    required String username,
    required String appPassword,
    required String folderPath,
  }) async {
    throw UnimplementedError();
  }

  Future<FileItem> statFile({
    required Uri baseUrl,
    required String username,
    required String appPassword,
    required String path,
  }) async {
    throw UnimplementedError();
  }

  Future<FolderItem> statFolder({
    required Uri baseUrl,
    required String username,
    required String appPassword,
    required String path,
  }) async {
    throw UnimplementedError();
  }
}
