import 'package:injectable/injectable.dart';

@module
abstract class AudioCacheModule {
  // This module ensures all audio cache dependencies are properly registered
  // All services and use cases use @injectable or @LazySingleton annotations
  // and will be automatically discovered by injectable code generation
}

// Note: All dependencies are registered via their class annotations:
//
// DATA LAYER:
// - CacheMetadataLocalDataSourceImpl (@LazySingleton)
// - CacheStorageLocalDataSourceImpl (@LazySingleton)
// - CacheMetadataRepositoryImpl (@LazySingleton)
// - CacheStorageRepositoryImpl (@LazySingleton)
//
// INFRASTRUCTURE LAYER:
// - CacheOrchestrationServiceImpl (@LazySingleton)
// - EnhancedDownloadManagementServiceImpl (@LazySingleton)
// - EnhancedStorageManagementServiceImpl (@LazySingleton)
//
// USE CASES:
// - CacheTrackUseCase (@injectable)
// - GetTrackCacheStatusUseCase (@injectable)
// - RemoveTrackCacheUseCase (@injectable)
// - CachePlaylistUseCase (@injectable)
// - GetPlaylistCacheStatusUseCase (@injectable)
// - RemovePlaylistCacheUseCase (@injectable)
// - CleanupCacheUseCase (@injectable)
// - GetCacheStorageStatsUseCase (@injectable)