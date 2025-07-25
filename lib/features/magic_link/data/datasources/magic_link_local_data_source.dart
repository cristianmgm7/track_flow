import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/magic_link/data/models/magic_link_dto.dart';
import 'package:trackflow/features/magic_link/data/models/magic_link_cache_dto.dart';

abstract class MagicLinkLocalDataSource {
  Future<Either<Failure, MagicLinkDto>> cacheMagicLink(
    MagicLinkCacheRequestDto request,
  );
  Future<Either<Failure, MagicLinkDto>> getCachedMagicLink(
    MagicLinkCacheQueryDto query,
  );
  Future<Either<Failure, Unit>> clearCachedMagicLink(
    MagicLinkCacheQueryDto query,
  );
}

@LazySingleton(as: MagicLinkLocalDataSource)
class MagicLinkLocalDataSourceImpl extends MagicLinkLocalDataSource {
  static const String _magicLinkKey = 'magic_link_cache';
  static const String _magicLinkExpiryKey = 'magic_link_expiry';

  MagicLinkLocalDataSourceImpl();

  @override
  Future<Either<Failure, MagicLinkDto>> cacheMagicLink(
    MagicLinkCacheRequestDto request,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Store simple cache data
      final cacheData = {
        'userId': request.userId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      await prefs.setString(_magicLinkKey, jsonEncode(cacheData));
      await prefs.setInt(
        _magicLinkExpiryKey,
        DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch,
      );

      // Return a placeholder DTO for now
      // In a real implementation, this would be a proper MagicLinkDto
      return Left(DatabaseFailure('Magic link caching not fully implemented'));
    } catch (e) {
      return Left(DatabaseFailure('Failed to cache magic link: $e'));
    }
  }

  @override
  Future<Either<Failure, MagicLinkDto>> getCachedMagicLink(
    MagicLinkCacheQueryDto query,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if magic link exists
      if (!prefs.containsKey(_magicLinkKey)) {
        return Left(DatabaseFailure('No cached magic link found'));
      }

      // Get cached data
      final cacheData = prefs.getString(_magicLinkKey);
      if (cacheData == null) {
        return Left(DatabaseFailure('Cached magic link data is null'));
      }

      final data = jsonDecode(cacheData) as Map<String, dynamic>;
      final cachedUserId = data['userId'] as String;
      final expiresAt = prefs.getInt(_magicLinkExpiryKey) ?? 0;

      // Check if magic link has expired
      if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
        await clearCachedMagicLink(query);
        return Left(DatabaseFailure('Magic link has expired'));
      }

      // Check if query matches cached data
      if (cachedUserId != query.userId) {
        return Left(DatabaseFailure('User ID mismatch for cached magic link'));
      }

      // For now, return an error indicating this needs proper implementation
      return Left(
        DatabaseFailure('Magic link retrieval not fully implemented'),
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to get cached magic link: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearCachedMagicLink(
    MagicLinkCacheQueryDto query,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear all magic link related data
      await prefs.remove(_magicLinkKey);
      await prefs.remove(_magicLinkExpiryKey);

      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Failed to clear cached magic link: $e'));
    }
  }
}
