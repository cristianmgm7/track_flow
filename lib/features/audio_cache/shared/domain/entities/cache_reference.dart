import 'package:equatable/equatable.dart';

enum CacheReferenceType { individual, playlist, album, artist }

class CacheReference extends Equatable {
  const CacheReference({
    required this.trackId,
    required this.referenceIds,
    required this.createdAt,
    this.lastAccessed,
  });

  final String trackId;
  final List<String> referenceIds; // ['playlist_123', 'individual']
  final DateTime createdAt;
  final DateTime? lastAccessed;

  /// CRITICAL: Reference counting to prevent data loss
  bool get canDelete => referenceIds.isEmpty;
  
  int get referenceCount => referenceIds.length;

  bool get hasIndividualReference => referenceIds.contains('individual');

  bool hasPlaylistReference(String playlistId) => 
    referenceIds.contains('playlist_$playlistId');

  CacheReference addReference(String referenceId) {
    if (referenceIds.contains(referenceId)) {
      return this;
    }
    
    return copyWith(
      referenceIds: [...referenceIds, referenceId],
      lastAccessed: DateTime.now(),
    );
  }

  CacheReference removeReference(String referenceId) {
    if (!referenceIds.contains(referenceId)) {
      return this;
    }
    
    final updatedReferences = referenceIds.where((id) => id != referenceId).toList();
    
    return copyWith(
      referenceIds: updatedReferences,
      lastAccessed: DateTime.now(),
    );
  }

  CacheReference updateLastAccessed() {
    return copyWith(lastAccessed: DateTime.now());
  }

  CacheReference copyWith({
    String? trackId,
    List<String>? referenceIds,
    DateTime? createdAt,
    DateTime? lastAccessed,
  }) {
    return CacheReference(
      trackId: trackId ?? this.trackId,
      referenceIds: referenceIds ?? this.referenceIds,
      createdAt: createdAt ?? this.createdAt,
      lastAccessed: lastAccessed ?? this.lastAccessed,
    );
  }

  @override
  List<Object?> get props => [
    trackId,
    referenceIds,
    createdAt,
    lastAccessed,
  ];
}