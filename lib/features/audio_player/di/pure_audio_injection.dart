library;

/// Pure Audio Player dependency injection module
/// 
/// All services are automatically registered via @Injectable annotations:
/// - AudioContentRepositoryImpl
/// - AudioSourceResolverImpl 
/// - All use cases
/// - AudioPlayerBloc
/// 
/// This module ensures proper integration with the main DI container
/// while maintaining separation between pure audio and business domains.
/// 
/// The @Injectable annotations will be discovered by the main app's
/// build_runner process when running:
/// flutter packages pub run build_runner build
/// 
/// Integration points:
/// 1. AudioContentRepositoryImpl depends on:
///    - AudioTrackRepository (business domain)
///    - AudioSourceResolver (pure audio)
/// 
/// 2. AudioSourceResolverImpl depends on:
///    - CacheOrchestrationService (existing)
///    - OfflineModeService (existing)
/// 
/// 3. Use cases depend on:
///    - AudioPlaybackService (pure audio)
///    - AudioContentRepository (pure audio)
/// 
/// 4. AudioPlayerBloc depends on:
///    - All use cases (pure audio)
///    - AudioPlaybackService (pure audio)
/// 
/// This architecture maintains clean boundaries and allows
/// the pure audio system to work independently of business logic.