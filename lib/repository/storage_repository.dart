import 'dart:io';
import 'package:farm_link/provider/storage_provider.dart';
import 'package:farm_link/repository/base_repository.dart';

class StorageRepository extends BaseRepository {
  final StorageProvider storageProvider;

  StorageRepository({StorageProvider? provider})
      : storageProvider = provider ?? StorageProvider();

  Future<String> uploadFile(File file, String path) =>
      storageProvider.uploadFile(file, path);

  @override
  void dispose() {
    storageProvider.dispose();
  }
}
