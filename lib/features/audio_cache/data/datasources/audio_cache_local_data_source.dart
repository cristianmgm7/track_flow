import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

abstract class AudioCacheLocalDataSource {
  Future<bool> isCached(String remoteUrl);
  Future<String> getLocalPath(String remoteUrl);
  Future<String> downloadAndCache(
    String remoteUrl, {
    void Function(double progress)? onProgress,
  });
  Future<void> cleanCache({int maxFiles});
}

@LazySingleton(as: AudioCacheLocalDataSource)
class AudioCacheLocalDataSourceImpl implements AudioCacheLocalDataSource {
  final FirebaseStorage storage;
  final Directory cacheDir;

  AudioCacheLocalDataSourceImpl(this.storage, this.cacheDir);

  String _fileNameFromUrl(String url) {
    final bytes = utf8.encode(url);
    final digest = sha1.convert(bytes);
    return '$digest.mp3'; // o la extensión que corresponda
  }

  @override
  Future<bool> isCached(String remoteUrl) async {
    final file = File('${cacheDir.path}/${_fileNameFromUrl(remoteUrl)}');
    return file.exists();
  }

  @override
  Future<String> getLocalPath(String remoteUrl) async {
    return '${cacheDir.path}/${_fileNameFromUrl(remoteUrl)}';
  }

  @override
  Future<String> downloadAndCache(
    String remoteUrl, {
    void Function(double progress)? onProgress,
  }) async {
    final file = File('${cacheDir.path}/${_fileNameFromUrl(remoteUrl)}');
    try {
      final ref = storage.refFromURL(remoteUrl);
      final task = ref.writeToFile(file);

      // Escuchar progreso
      if (onProgress != null) {
        task.snapshotEvents.listen((TaskSnapshot snapshot) {
          if (snapshot.totalBytes > 0) {
            final progress = snapshot.bytesTransferred / snapshot.totalBytes;
            onProgress(progress);
          }
        });
      }

      final result = await task;
      if (result.state == TaskState.success) {
        await cleanCache();
        return file.path;
      } else {
        if (await file.exists()) await file.delete();
        throw Exception('Error downloading audio: \\${result.state}');
      }
    } on FirebaseException catch (e) {
      if (await file.exists()) await file.delete();
      throw Exception('Firebase error: \\${e.message}');
    } on FileSystemException catch (e) {
      if (await file.exists()) await file.delete();
      throw Exception('File system error: \\${e.message}');
    } catch (e) {
      if (await file.exists()) await file.delete();
      throw Exception('Unknown error: \\${e.toString()}');
    }
  }

  @override
  Future<void> cleanCache({int maxFiles = 50}) async {
    final files = cacheDir.listSync().whereType<File>().toList();
    if (files.length > maxFiles) {
      files.sort(
        (a, b) => a.statSync().accessed.compareTo(b.statSync().accessed),
      );
      for (var i = 0; i < files.length - maxFiles; i++) {
        await files[i].delete();
      }
    }
  }
}
