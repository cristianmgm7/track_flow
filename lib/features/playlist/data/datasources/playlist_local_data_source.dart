import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/playlist/data/models/playlist_document.dart';
import '../models/playlist_dto.dart';

abstract class PlaylistLocalDataSource {
  Future<Either<Failure, Unit>> addPlaylist(PlaylistDto playlist);
  Future<Either<Failure, List<PlaylistDto>>> getAllPlaylists();
  Future<Either<Failure, PlaylistDto?>> getPlaylistById(String uuid);
  Future<Either<Failure, Unit>> updatePlaylist(PlaylistDto playlist);
  Future<Either<Failure, Unit>> deletePlaylist(String uuid);
}

@LazySingleton(as: PlaylistLocalDataSource)
class PlaylistLocalDataSourceImpl implements PlaylistLocalDataSource {
  final Isar isar;

  PlaylistLocalDataSourceImpl(this.isar);

  @override
  Future<Either<Failure, Unit>> addPlaylist(PlaylistDto playlist) async {
    try {
      await isar.writeTxn(() async {
        await isar.playlistDocuments.put(PlaylistDocument.fromDTO(playlist));
      });
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to add playlist: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PlaylistDto>>> getAllPlaylists() async {
    try {
      final docs = await isar.playlistDocuments.where().findAll();
      return Right(docs.map((doc) => doc.toDTO()).toList());
    } catch (e) {
      return Left(CacheFailure('Failed to get all playlists: $e'));
    }
  }

  @override
  Future<Either<Failure, PlaylistDto?>> getPlaylistById(String uuid) async {
    try {
      final doc =
          await isar.playlistDocuments.filter().uuidEqualTo(uuid).findFirst();
      return Right(doc?.toDTO());
    } catch (e) {
      return Left(CacheFailure('Failed to get playlist by id: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updatePlaylist(PlaylistDto playlist) async {
    try {
      await isar.writeTxn(() async {
        await isar.playlistDocuments.put(PlaylistDocument.fromDTO(playlist));
      });
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to update playlist: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deletePlaylist(String uuid) async {
    try {
      await isar.writeTxn(() async {
        final doc =
            await isar.playlistDocuments.filter().uuidEqualTo(uuid).findFirst();
        if (doc != null) {
          await isar.playlistDocuments.delete(doc.id);
        }
      });
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to delete playlist: $e'));
    }
  }
}
