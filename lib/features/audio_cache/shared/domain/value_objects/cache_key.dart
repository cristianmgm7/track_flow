import 'package:equatable/equatable.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

abstract class ValueObject<T> extends Equatable {
  const ValueObject(this.value);
  
  final T value;
  
  @override
  List<Object?> get props => [value];
  
  @override
  String toString() => value.toString();
}

class CacheKey extends ValueObject<String> {
  const CacheKey._(super.value);

  /// CRITICAL: Use composite key to avoid collisions
  /// Creates a unique cache key combining trackId and checksum
  factory CacheKey.composite(String trackId, String checksum) {
    return CacheKey._("${trackId}_$checksum");
  }

  /// Creates a cache key from a URL using SHA1 hash
  factory CacheKey.fromUrl(String url) {
    final hash = sha1.convert(utf8.encode(url)).toString();
    return CacheKey._(hash);
  }

  /// Creates a cache key from track ID and URL (recommended approach)
  factory CacheKey.fromTrackAndUrl(String trackId, String url) {
    final urlHash = sha1.convert(utf8.encode(url)).toString();
    return CacheKey.composite(trackId, urlHash);
  }

  /// Extracts track ID from composite key (if possible)
  String? get trackId {
    final parts = value.split('_');
    return parts.length >= 2 ? parts.first : null;
  }

  /// Extracts checksum from composite key (if possible)
  String? get checksum {
    final parts = value.split('_');
    return parts.length >= 2 ? parts.sublist(1).join('_') : null;
  }

  /// Validates if this is a composite key format
  bool get isComposite => value.contains('_');
}