import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

abstract class AvatarCacheManager {
  Future<String> copyAvatarToCache(String userId, String sourcePath);
  Future<bool> avatarExists(String localPath);
  Future<void> deleteAvatar(String localPath);
}

@LazySingleton(as: AvatarCacheManager)
class AvatarCacheManagerImpl implements AvatarCacheManager {
  Future<Directory> _userDir(String userId) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'avatars', userId));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  @override
  Future<String> copyAvatarToCache(String userId, String sourcePath) async {
    final src = File(
      sourcePath.startsWith('file://')
          ? Uri.parse(sourcePath).toFilePath()
          : sourcePath,
    );
    if (!await src.exists()) {
      throw StateError('Source avatar file not found: $sourcePath');
    }
    final dir = await _userDir(userId);
    final ext = p.extension(src.path);
    final tmpPath = p.join(
      dir.path,
      'tmp_${DateTime.now().microsecondsSinceEpoch}$ext',
    );
    final finalPath = p.join(
      dir.path,
      'avatar_${DateTime.now().millisecondsSinceEpoch}$ext',
    );

    // Write atomically: copy to tmp then rename
    await src.copy(tmpPath);
    await File(tmpPath).rename(finalPath);
    return finalPath;
  }

  @override
  Future<bool> avatarExists(String localPath) async {
    if (localPath.isEmpty) return false;
    return File(localPath).exists();
  }

  @override
  Future<void> deleteAvatar(String localPath) async {
    if (localPath.isEmpty) return;
    final f = File(localPath);
    if (await f.exists()) {
      await f.delete();
    }
  }
}
