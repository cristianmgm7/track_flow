import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackflow/core/error/failures.dart';
import '../models/playlist_dto.dart';

abstract class PlaylistRemoteDataSource {
  Future<Either<Failure, Unit>> addPlaylist(PlaylistDto playlist);
  Future<Either<Failure, List<PlaylistDto>>> getAllPlaylists();
  Future<Either<Failure, PlaylistDto?>> getPlaylistById(String id);
  Future<Either<Failure, Unit>> updatePlaylist(PlaylistDto playlist);
  Future<Either<Failure, Unit>> deletePlaylist(String id);
}

@LazySingleton(as: PlaylistRemoteDataSource)
class PlaylistRemoteDataSourceImpl implements PlaylistRemoteDataSource {
  final FirebaseFirestore firestore;

  PlaylistRemoteDataSourceImpl(this.firestore);

  @override
  Future<Either<Failure, Unit>> addPlaylist(PlaylistDto playlist) async {
    try {
      await firestore
          .collection('playlists')
          .doc(playlist.id)
          .set(playlist.toJson());
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to add playlist: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PlaylistDto>>> getAllPlaylists() async {
    try {
      final querySnapshot = await firestore.collection('playlists').get();
      final playlists = querySnapshot.docs
          .map((doc) => PlaylistDto.fromJson(doc.data()))
          .toList();
      return Right(playlists);
    } catch (e) {
      return Left(ServerFailure('Failed to get all playlists: $e'));
    }
  }

  @override
  Future<Either<Failure, PlaylistDto?>> getPlaylistById(String id) async {
    try {
      final doc = await firestore.collection('playlists').doc(id).get();
      if (doc.exists) {
        return Right(PlaylistDto.fromJson(doc.data()!));
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to get playlist by id: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updatePlaylist(PlaylistDto playlist) async {
    try {
      await firestore
          .collection('playlists')
          .doc(playlist.id)
          .update(playlist.toJson());
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to update playlist: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deletePlaylist(String id) async {
    try {
      await firestore.collection('playlists').doc(id).delete();
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to delete playlist: $e'));
    }
  }
}
