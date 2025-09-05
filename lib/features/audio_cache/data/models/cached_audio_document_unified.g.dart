// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_audio_document_unified.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCachedAudioDocumentUnifiedCollection on Isar {
  IsarCollection<CachedAudioDocumentUnified> get cachedAudioDocumentUnifieds =>
      this.collection();
}

const CachedAudioDocumentUnifiedSchema = CollectionSchema(
  name: r'CachedAudioDocumentUnified',
  id: 8456100307378259410,
  properties: {
    r'cachedAt': PropertySchema(
      id: 0,
      name: r'cachedAt',
      type: IsarType.dateTime,
    ),
    r'checksum': PropertySchema(
      id: 1,
      name: r'checksum',
      type: IsarType.string,
    ),
    r'downloadAttempts': PropertySchema(
      id: 2,
      name: r'downloadAttempts',
      type: IsarType.long,
    ),
    r'failureReason': PropertySchema(
      id: 3,
      name: r'failureReason',
      type: IsarType.string,
    ),
    r'filePath': PropertySchema(
      id: 4,
      name: r'filePath',
      type: IsarType.string,
    ),
    r'fileSizeBytes': PropertySchema(
      id: 5,
      name: r'fileSizeBytes',
      type: IsarType.long,
    ),
    r'isCached': PropertySchema(
      id: 6,
      name: r'isCached',
      type: IsarType.bool,
    ),
    r'isCorrupted': PropertySchema(
      id: 7,
      name: r'isCorrupted',
      type: IsarType.bool,
    ),
    r'isDownloading': PropertySchema(
      id: 8,
      name: r'isDownloading',
      type: IsarType.bool,
    ),
    r'isFailed': PropertySchema(
      id: 9,
      name: r'isFailed',
      type: IsarType.bool,
    ),
    r'lastAccessed': PropertySchema(
      id: 10,
      name: r'lastAccessed',
      type: IsarType.dateTime,
    ),
    r'lastDownloadAttempt': PropertySchema(
      id: 11,
      name: r'lastDownloadAttempt',
      type: IsarType.dateTime,
    ),
    r'originalUrl': PropertySchema(
      id: 12,
      name: r'originalUrl',
      type: IsarType.string,
    ),
    r'quality': PropertySchema(
      id: 13,
      name: r'quality',
      type: IsarType.string,
      enumMap: _CachedAudioDocumentUnifiedqualityEnumValueMap,
    ),
    r'shouldRetry': PropertySchema(
      id: 14,
      name: r'shouldRetry',
      type: IsarType.bool,
    ),
    r'status': PropertySchema(
      id: 15,
      name: r'status',
      type: IsarType.string,
      enumMap: _CachedAudioDocumentUnifiedstatusEnumValueMap,
    ),
    r'trackId': PropertySchema(
      id: 16,
      name: r'trackId',
      type: IsarType.string,
    )
  },
  estimateSize: _cachedAudioDocumentUnifiedEstimateSize,
  serialize: _cachedAudioDocumentUnifiedSerialize,
  deserialize: _cachedAudioDocumentUnifiedDeserialize,
  deserializeProp: _cachedAudioDocumentUnifiedDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'trackId': IndexSchema(
      id: -8614467705999066844,
      name: r'trackId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'trackId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _cachedAudioDocumentUnifiedGetId,
  getLinks: _cachedAudioDocumentUnifiedGetLinks,
  attach: _cachedAudioDocumentUnifiedAttach,
  version: '3.1.0+1',
);

int _cachedAudioDocumentUnifiedEstimateSize(
  CachedAudioDocumentUnified object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.checksum.length * 3;
  {
    final value = object.failureReason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.filePath.length * 3;
  {
    final value = object.originalUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.quality.name.length * 3;
  bytesCount += 3 + object.status.name.length * 3;
  bytesCount += 3 + object.trackId.length * 3;
  return bytesCount;
}

void _cachedAudioDocumentUnifiedSerialize(
  CachedAudioDocumentUnified object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.cachedAt);
  writer.writeString(offsets[1], object.checksum);
  writer.writeLong(offsets[2], object.downloadAttempts);
  writer.writeString(offsets[3], object.failureReason);
  writer.writeString(offsets[4], object.filePath);
  writer.writeLong(offsets[5], object.fileSizeBytes);
  writer.writeBool(offsets[6], object.isCached);
  writer.writeBool(offsets[7], object.isCorrupted);
  writer.writeBool(offsets[8], object.isDownloading);
  writer.writeBool(offsets[9], object.isFailed);
  writer.writeDateTime(offsets[10], object.lastAccessed);
  writer.writeDateTime(offsets[11], object.lastDownloadAttempt);
  writer.writeString(offsets[12], object.originalUrl);
  writer.writeString(offsets[13], object.quality.name);
  writer.writeBool(offsets[14], object.shouldRetry);
  writer.writeString(offsets[15], object.status.name);
  writer.writeString(offsets[16], object.trackId);
}

CachedAudioDocumentUnified _cachedAudioDocumentUnifiedDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CachedAudioDocumentUnified();
  object.cachedAt = reader.readDateTime(offsets[0]);
  object.checksum = reader.readString(offsets[1]);
  object.downloadAttempts = reader.readLong(offsets[2]);
  object.failureReason = reader.readStringOrNull(offsets[3]);
  object.filePath = reader.readString(offsets[4]);
  object.fileSizeBytes = reader.readLong(offsets[5]);
  object.lastAccessed = reader.readDateTime(offsets[10]);
  object.lastDownloadAttempt = reader.readDateTimeOrNull(offsets[11]);
  object.originalUrl = reader.readStringOrNull(offsets[12]);
  object.quality = _CachedAudioDocumentUnifiedqualityValueEnumMap[
          reader.readStringOrNull(offsets[13])] ??
      AudioQuality.low;
  object.status = _CachedAudioDocumentUnifiedstatusValueEnumMap[
          reader.readStringOrNull(offsets[15])] ??
      CacheStatus.notCached;
  object.trackId = reader.readString(offsets[16]);
  return object;
}

P _cachedAudioDocumentUnifiedDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readDateTime(offset)) as P;
    case 11:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (_CachedAudioDocumentUnifiedqualityValueEnumMap[
              reader.readStringOrNull(offset)] ??
          AudioQuality.low) as P;
    case 14:
      return (reader.readBool(offset)) as P;
    case 15:
      return (_CachedAudioDocumentUnifiedstatusValueEnumMap[
              reader.readStringOrNull(offset)] ??
          CacheStatus.notCached) as P;
    case 16:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _CachedAudioDocumentUnifiedqualityEnumValueMap = {
  r'low': r'low',
  r'medium': r'medium',
  r'high': r'high',
  r'lossless': r'lossless',
};
const _CachedAudioDocumentUnifiedqualityValueEnumMap = {
  r'low': AudioQuality.low,
  r'medium': AudioQuality.medium,
  r'high': AudioQuality.high,
  r'lossless': AudioQuality.lossless,
};
const _CachedAudioDocumentUnifiedstatusEnumValueMap = {
  r'notCached': r'notCached',
  r'downloading': r'downloading',
  r'cached': r'cached',
  r'failed': r'failed',
  r'corrupted': r'corrupted',
};
const _CachedAudioDocumentUnifiedstatusValueEnumMap = {
  r'notCached': CacheStatus.notCached,
  r'downloading': CacheStatus.downloading,
  r'cached': CacheStatus.cached,
  r'failed': CacheStatus.failed,
  r'corrupted': CacheStatus.corrupted,
};

Id _cachedAudioDocumentUnifiedGetId(CachedAudioDocumentUnified object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _cachedAudioDocumentUnifiedGetLinks(
    CachedAudioDocumentUnified object) {
  return [];
}

void _cachedAudioDocumentUnifiedAttach(
    IsarCollection<dynamic> col, Id id, CachedAudioDocumentUnified object) {}

extension CachedAudioDocumentUnifiedByIndex
    on IsarCollection<CachedAudioDocumentUnified> {
  Future<CachedAudioDocumentUnified?> getByTrackId(String trackId) {
    return getByIndex(r'trackId', [trackId]);
  }

  CachedAudioDocumentUnified? getByTrackIdSync(String trackId) {
    return getByIndexSync(r'trackId', [trackId]);
  }

  Future<bool> deleteByTrackId(String trackId) {
    return deleteByIndex(r'trackId', [trackId]);
  }

  bool deleteByTrackIdSync(String trackId) {
    return deleteByIndexSync(r'trackId', [trackId]);
  }

  Future<List<CachedAudioDocumentUnified?>> getAllByTrackId(
      List<String> trackIdValues) {
    final values = trackIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'trackId', values);
  }

  List<CachedAudioDocumentUnified?> getAllByTrackIdSync(
      List<String> trackIdValues) {
    final values = trackIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'trackId', values);
  }

  Future<int> deleteAllByTrackId(List<String> trackIdValues) {
    final values = trackIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'trackId', values);
  }

  int deleteAllByTrackIdSync(List<String> trackIdValues) {
    final values = trackIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'trackId', values);
  }

  Future<Id> putByTrackId(CachedAudioDocumentUnified object) {
    return putByIndex(r'trackId', object);
  }

  Id putByTrackIdSync(CachedAudioDocumentUnified object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'trackId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByTrackId(List<CachedAudioDocumentUnified> objects) {
    return putAllByIndex(r'trackId', objects);
  }

  List<Id> putAllByTrackIdSync(List<CachedAudioDocumentUnified> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'trackId', objects, saveLinks: saveLinks);
  }
}

extension CachedAudioDocumentUnifiedQueryWhereSort on QueryBuilder<
    CachedAudioDocumentUnified, CachedAudioDocumentUnified, QWhere> {
  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CachedAudioDocumentUnifiedQueryWhere on QueryBuilder<
    CachedAudioDocumentUnified, CachedAudioDocumentUnified, QWhereClause> {
  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterWhereClause> isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterWhereClause> isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterWhereClause> isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterWhereClause> isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterWhereClause> isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterWhereClause> trackIdEqualTo(String trackId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'trackId',
        value: [trackId],
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterWhereClause> trackIdNotEqualTo(String trackId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'trackId',
              lower: [],
              upper: [trackId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'trackId',
              lower: [trackId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'trackId',
              lower: [trackId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'trackId',
              lower: [],
              upper: [trackId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension CachedAudioDocumentUnifiedQueryFilter on QueryBuilder<
    CachedAudioDocumentUnified, CachedAudioDocumentUnified, QFilterCondition> {
  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> cachedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cachedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> cachedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cachedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> cachedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cachedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> cachedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cachedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> checksumEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'checksum',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> checksumGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'checksum',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> checksumLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'checksum',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> checksumBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'checksum',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> checksumStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'checksum',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> checksumEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'checksum',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
          QAfterFilterCondition>
      checksumContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'checksum',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
          QAfterFilterCondition>
      checksumMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'checksum',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> checksumIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'checksum',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> checksumIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'checksum',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> downloadAttemptsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'downloadAttempts',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> downloadAttemptsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'downloadAttempts',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> downloadAttemptsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'downloadAttempts',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> downloadAttemptsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'downloadAttempts',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> failureReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'failureReason',
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> failureReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'failureReason',
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> failureReasonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'failureReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> failureReasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'failureReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> failureReasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'failureReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> failureReasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'failureReason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> failureReasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'failureReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> failureReasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'failureReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
          QAfterFilterCondition>
      failureReasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'failureReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
          QAfterFilterCondition>
      failureReasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'failureReason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> failureReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'failureReason',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> failureReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'failureReason',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> filePathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> filePathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> filePathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> filePathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'filePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> filePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> filePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
          QAfterFilterCondition>
      filePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
          QAfterFilterCondition>
      filePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'filePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> filePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'filePath',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> filePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'filePath',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> fileSizeBytesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileSizeBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> fileSizeBytesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fileSizeBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> fileSizeBytesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fileSizeBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> fileSizeBytesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fileSizeBytes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> isCachedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCached',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> isCorruptedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCorrupted',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> isDownloadingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDownloading',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> isFailedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isFailed',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> lastAccessedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastAccessed',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> lastAccessedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastAccessed',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> lastAccessedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastAccessed',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> lastAccessedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastAccessed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> lastDownloadAttemptIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastDownloadAttempt',
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> lastDownloadAttemptIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastDownloadAttempt',
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> lastDownloadAttemptEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastDownloadAttempt',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> lastDownloadAttemptGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastDownloadAttempt',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> lastDownloadAttemptLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastDownloadAttempt',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> lastDownloadAttemptBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastDownloadAttempt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> originalUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'originalUrl',
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> originalUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'originalUrl',
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> originalUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originalUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> originalUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'originalUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> originalUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'originalUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> originalUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'originalUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> originalUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'originalUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> originalUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'originalUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
          QAfterFilterCondition>
      originalUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'originalUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
          QAfterFilterCondition>
      originalUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'originalUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> originalUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originalUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> originalUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'originalUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> qualityEqualTo(
    AudioQuality value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> qualityGreaterThan(
    AudioQuality value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> qualityLessThan(
    AudioQuality value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> qualityBetween(
    AudioQuality lower,
    AudioQuality upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quality',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> qualityStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'quality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> qualityEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'quality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
          QAfterFilterCondition>
      qualityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'quality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
          QAfterFilterCondition>
      qualityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'quality',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> qualityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quality',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> qualityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'quality',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> shouldRetryEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shouldRetry',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> statusEqualTo(
    CacheStatus value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> statusGreaterThan(
    CacheStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> statusLessThan(
    CacheStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> statusBetween(
    CacheStatus lower,
    CacheStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
          QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
          QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> trackIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trackId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> trackIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'trackId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> trackIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'trackId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> trackIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'trackId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> trackIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'trackId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> trackIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'trackId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
          QAfterFilterCondition>
      trackIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'trackId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
          QAfterFilterCondition>
      trackIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'trackId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> trackIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trackId',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterFilterCondition> trackIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'trackId',
        value: '',
      ));
    });
  }
}

extension CachedAudioDocumentUnifiedQueryObject on QueryBuilder<
    CachedAudioDocumentUnified, CachedAudioDocumentUnified, QFilterCondition> {}

extension CachedAudioDocumentUnifiedQueryLinks on QueryBuilder<
    CachedAudioDocumentUnified, CachedAudioDocumentUnified, QFilterCondition> {}

extension CachedAudioDocumentUnifiedQuerySortBy on QueryBuilder<
    CachedAudioDocumentUnified, CachedAudioDocumentUnified, QSortBy> {
  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> sortByCachedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.asc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> sortByCachedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.desc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> sortByChecksum() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checksum', Sort.asc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> sortByChecksumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checksum', Sort.desc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> sortByDownloadAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadAttempts', Sort.asc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> sortByDownloadAttemptsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadAttempts', Sort.desc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> sortByFailureReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failureReason', Sort.asc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> sortByFailureReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failureReason', Sort.desc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> sortByFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.asc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> sortByFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.desc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> sortByFileSizeBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSizeBytes', Sort.asc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> sortByFileSizeBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSizeBytes', Sort.desc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> sortByIsCached() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCached', Sort.asc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> sortByIsCachedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCached', Sort.desc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> sortByIsCorrupted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCorrupted', Sort.asc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> sortByIsCorruptedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCorrupted', Sort.desc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> sortByIsDownloading() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDownloading', Sort.asc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> sortByIsDownloadingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDownloading', Sort.desc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> sortByIsFailed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFailed', Sort.asc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> sortByIsFailedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFailed', Sort.desc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> sortByLastAccessed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAccessed', Sort.asc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> sortByLastAccessedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAccessed', Sort.desc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> sortByLastDownloadAttempt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDownloadAttempt', Sort.asc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> sortByLastDownloadAttemptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDownloadAttempt', Sort.desc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> sortByOriginalUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalUrl', Sort.asc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> sortByOriginalUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalUrl', Sort.desc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> sortByQuality() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quality', Sort.asc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> sortByQualityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quality', Sort.desc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> sortByShouldRetry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shouldRetry', Sort.asc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> sortByShouldRetryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shouldRetry', Sort.desc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> sortByTrackId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackId', Sort.asc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> sortByTrackIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackId', Sort.desc);
    });
  }
}

extension CachedAudioDocumentUnifiedQuerySortThenBy on QueryBuilder<
    CachedAudioDocumentUnified, CachedAudioDocumentUnified, QSortThenBy> {
  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByCachedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.asc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByCachedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.desc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByChecksum() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checksum', Sort.asc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByChecksumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checksum', Sort.desc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByDownloadAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadAttempts', Sort.asc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByDownloadAttemptsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadAttempts', Sort.desc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByFailureReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failureReason', Sort.asc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByFailureReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failureReason', Sort.desc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.asc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.desc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByFileSizeBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSizeBytes', Sort.asc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByFileSizeBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSizeBytes', Sort.desc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByIsCached() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCached', Sort.asc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByIsCachedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCached', Sort.desc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByIsCorrupted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCorrupted', Sort.asc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByIsCorruptedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCorrupted', Sort.desc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByIsDownloading() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDownloading', Sort.asc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByIsDownloadingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDownloading', Sort.desc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByIsFailed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFailed', Sort.asc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByIsFailedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFailed', Sort.desc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByLastAccessed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAccessed', Sort.asc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByLastAccessedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAccessed', Sort.desc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByLastDownloadAttempt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDownloadAttempt', Sort.asc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByLastDownloadAttemptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDownloadAttempt', Sort.desc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByOriginalUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalUrl', Sort.asc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByOriginalUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalUrl', Sort.desc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByQuality() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quality', Sort.asc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByQualityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quality', Sort.desc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByShouldRetry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shouldRetry', Sort.asc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByShouldRetryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shouldRetry', Sort.desc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByTrackId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackId', Sort.asc);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QAfterSortBy> thenByTrackIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackId', Sort.desc);
    });
  }
}

extension CachedAudioDocumentUnifiedQueryWhereDistinct on QueryBuilder<
    CachedAudioDocumentUnified, CachedAudioDocumentUnified, QDistinct> {
  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QDistinct> distinctByCachedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cachedAt');
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QDistinct> distinctByChecksum({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'checksum', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QDistinct> distinctByDownloadAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'downloadAttempts');
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QDistinct> distinctByFailureReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'failureReason',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QDistinct> distinctByFilePath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'filePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QDistinct> distinctByFileSizeBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileSizeBytes');
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QDistinct> distinctByIsCached() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCached');
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QDistinct> distinctByIsCorrupted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCorrupted');
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QDistinct> distinctByIsDownloading() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDownloading');
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QDistinct> distinctByIsFailed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFailed');
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QDistinct> distinctByLastAccessed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastAccessed');
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QDistinct> distinctByLastDownloadAttempt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastDownloadAttempt');
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QDistinct> distinctByOriginalUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'originalUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QDistinct> distinctByQuality({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quality', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QDistinct> distinctByShouldRetry() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shouldRetry');
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QDistinct> distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CachedAudioDocumentUnified,
      QDistinct> distinctByTrackId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trackId', caseSensitive: caseSensitive);
    });
  }
}

extension CachedAudioDocumentUnifiedQueryProperty on QueryBuilder<
    CachedAudioDocumentUnified, CachedAudioDocumentUnified, QQueryProperty> {
  QueryBuilder<CachedAudioDocumentUnified, int, QQueryOperations>
      isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, DateTime, QQueryOperations>
      cachedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cachedAt');
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, String, QQueryOperations>
      checksumProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'checksum');
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, int, QQueryOperations>
      downloadAttemptsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'downloadAttempts');
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, String?, QQueryOperations>
      failureReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'failureReason');
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, String, QQueryOperations>
      filePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'filePath');
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, int, QQueryOperations>
      fileSizeBytesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileSizeBytes');
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, bool, QQueryOperations>
      isCachedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCached');
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, bool, QQueryOperations>
      isCorruptedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCorrupted');
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, bool, QQueryOperations>
      isDownloadingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDownloading');
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, bool, QQueryOperations>
      isFailedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFailed');
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, DateTime, QQueryOperations>
      lastAccessedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastAccessed');
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, DateTime?, QQueryOperations>
      lastDownloadAttemptProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastDownloadAttempt');
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, String?, QQueryOperations>
      originalUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'originalUrl');
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, AudioQuality, QQueryOperations>
      qualityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quality');
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, bool, QQueryOperations>
      shouldRetryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shouldRetry');
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, CacheStatus, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<CachedAudioDocumentUnified, String, QQueryOperations>
      trackIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trackId');
    });
  }
}
