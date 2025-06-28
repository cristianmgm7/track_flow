// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_metadata_document.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCacheMetadataDocumentCollection on Isar {
  IsarCollection<CacheMetadataDocument> get cacheMetadataDocuments =>
      this.collection();
}

const CacheMetadataDocumentSchema = CollectionSchema(
  name: r'CacheMetadataDocument',
  id: -6669754813730498067,
  properties: {
    r'downloadAttempts': PropertySchema(
      id: 0,
      name: r'downloadAttempts',
      type: IsarType.long,
    ),
    r'failureReason': PropertySchema(
      id: 1,
      name: r'failureReason',
      type: IsarType.string,
    ),
    r'lastAccessed': PropertySchema(
      id: 2,
      name: r'lastAccessed',
      type: IsarType.dateTime,
    ),
    r'lastDownloadAttempt': PropertySchema(
      id: 3,
      name: r'lastDownloadAttempt',
      type: IsarType.dateTime,
    ),
    r'originalUrl': PropertySchema(
      id: 4,
      name: r'originalUrl',
      type: IsarType.string,
    ),
    r'referenceCount': PropertySchema(
      id: 5,
      name: r'referenceCount',
      type: IsarType.long,
    ),
    r'references': PropertySchema(
      id: 6,
      name: r'references',
      type: IsarType.stringList,
    ),
    r'status': PropertySchema(
      id: 7,
      name: r'status',
      type: IsarType.string,
      enumMap: _CacheMetadataDocumentstatusEnumValueMap,
    ),
    r'trackId': PropertySchema(
      id: 8,
      name: r'trackId',
      type: IsarType.string,
    )
  },
  estimateSize: _cacheMetadataDocumentEstimateSize,
  serialize: _cacheMetadataDocumentSerialize,
  deserialize: _cacheMetadataDocumentDeserialize,
  deserializeProp: _cacheMetadataDocumentDeserializeProp,
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
  getId: _cacheMetadataDocumentGetId,
  getLinks: _cacheMetadataDocumentGetLinks,
  attach: _cacheMetadataDocumentAttach,
  version: '3.1.0+1',
);

int _cacheMetadataDocumentEstimateSize(
  CacheMetadataDocument object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.failureReason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.originalUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.references.length * 3;
  {
    for (var i = 0; i < object.references.length; i++) {
      final value = object.references[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.status.name.length * 3;
  bytesCount += 3 + object.trackId.length * 3;
  return bytesCount;
}

void _cacheMetadataDocumentSerialize(
  CacheMetadataDocument object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.downloadAttempts);
  writer.writeString(offsets[1], object.failureReason);
  writer.writeDateTime(offsets[2], object.lastAccessed);
  writer.writeDateTime(offsets[3], object.lastDownloadAttempt);
  writer.writeString(offsets[4], object.originalUrl);
  writer.writeLong(offsets[5], object.referenceCount);
  writer.writeStringList(offsets[6], object.references);
  writer.writeString(offsets[7], object.status.name);
  writer.writeString(offsets[8], object.trackId);
}

CacheMetadataDocument _cacheMetadataDocumentDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CacheMetadataDocument();
  object.downloadAttempts = reader.readLong(offsets[0]);
  object.failureReason = reader.readStringOrNull(offsets[1]);
  object.lastAccessed = reader.readDateTime(offsets[2]);
  object.lastDownloadAttempt = reader.readDateTimeOrNull(offsets[3]);
  object.originalUrl = reader.readStringOrNull(offsets[4]);
  object.referenceCount = reader.readLong(offsets[5]);
  object.references = reader.readStringList(offsets[6]) ?? [];
  object.status = _CacheMetadataDocumentstatusValueEnumMap[
          reader.readStringOrNull(offsets[7])] ??
      CacheStatus.notCached;
  object.trackId = reader.readString(offsets[8]);
  return object;
}

P _cacheMetadataDocumentDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readStringList(offset) ?? []) as P;
    case 7:
      return (_CacheMetadataDocumentstatusValueEnumMap[
              reader.readStringOrNull(offset)] ??
          CacheStatus.notCached) as P;
    case 8:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _CacheMetadataDocumentstatusEnumValueMap = {
  r'notCached': r'notCached',
  r'downloading': r'downloading',
  r'cached': r'cached',
  r'failed': r'failed',
  r'corrupted': r'corrupted',
};
const _CacheMetadataDocumentstatusValueEnumMap = {
  r'notCached': CacheStatus.notCached,
  r'downloading': CacheStatus.downloading,
  r'cached': CacheStatus.cached,
  r'failed': CacheStatus.failed,
  r'corrupted': CacheStatus.corrupted,
};

Id _cacheMetadataDocumentGetId(CacheMetadataDocument object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _cacheMetadataDocumentGetLinks(
    CacheMetadataDocument object) {
  return [];
}

void _cacheMetadataDocumentAttach(
    IsarCollection<dynamic> col, Id id, CacheMetadataDocument object) {}

extension CacheMetadataDocumentByIndex
    on IsarCollection<CacheMetadataDocument> {
  Future<CacheMetadataDocument?> getByTrackId(String trackId) {
    return getByIndex(r'trackId', [trackId]);
  }

  CacheMetadataDocument? getByTrackIdSync(String trackId) {
    return getByIndexSync(r'trackId', [trackId]);
  }

  Future<bool> deleteByTrackId(String trackId) {
    return deleteByIndex(r'trackId', [trackId]);
  }

  bool deleteByTrackIdSync(String trackId) {
    return deleteByIndexSync(r'trackId', [trackId]);
  }

  Future<List<CacheMetadataDocument?>> getAllByTrackId(
      List<String> trackIdValues) {
    final values = trackIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'trackId', values);
  }

  List<CacheMetadataDocument?> getAllByTrackIdSync(List<String> trackIdValues) {
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

  Future<Id> putByTrackId(CacheMetadataDocument object) {
    return putByIndex(r'trackId', object);
  }

  Id putByTrackIdSync(CacheMetadataDocument object, {bool saveLinks = true}) {
    return putByIndexSync(r'trackId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByTrackId(List<CacheMetadataDocument> objects) {
    return putAllByIndex(r'trackId', objects);
  }

  List<Id> putAllByTrackIdSync(List<CacheMetadataDocument> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'trackId', objects, saveLinks: saveLinks);
  }
}

extension CacheMetadataDocumentQueryWhereSort
    on QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QWhere> {
  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CacheMetadataDocumentQueryWhere on QueryBuilder<CacheMetadataDocument,
    CacheMetadataDocument, QWhereClause> {
  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterWhereClause>
      isarIdBetween(
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterWhereClause>
      trackIdEqualTo(String trackId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'trackId',
        value: [trackId],
      ));
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterWhereClause>
      trackIdNotEqualTo(String trackId) {
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

extension CacheMetadataDocumentQueryFilter on QueryBuilder<
    CacheMetadataDocument, CacheMetadataDocument, QFilterCondition> {
  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> downloadAttemptsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'downloadAttempts',
        value: value,
      ));
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> failureReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'failureReason',
      ));
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> failureReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'failureReason',
      ));
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> failureReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'failureReason',
        value: '',
      ));
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> failureReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'failureReason',
        value: '',
      ));
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> lastAccessedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastAccessed',
        value: value,
      ));
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> lastDownloadAttemptIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastDownloadAttempt',
      ));
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> lastDownloadAttemptIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastDownloadAttempt',
      ));
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> lastDownloadAttemptEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastDownloadAttempt',
        value: value,
      ));
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> originalUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'originalUrl',
      ));
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> originalUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'originalUrl',
      ));
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> originalUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originalUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> originalUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'originalUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> referenceCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'referenceCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> referenceCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'referenceCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> referenceCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'referenceCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> referenceCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'referenceCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> referencesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'references',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> referencesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'references',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> referencesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'references',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> referencesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'references',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> referencesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'references',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> referencesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'references',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
          QAfterFilterCondition>
      referencesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'references',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
          QAfterFilterCondition>
      referencesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'references',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> referencesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'references',
        value: '',
      ));
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> referencesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'references',
        value: '',
      ));
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> referencesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'references',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> referencesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'references',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> referencesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'references',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> referencesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'references',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> referencesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'references',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> referencesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'references',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
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

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> trackIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trackId',
        value: '',
      ));
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument,
      QAfterFilterCondition> trackIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'trackId',
        value: '',
      ));
    });
  }
}

extension CacheMetadataDocumentQueryObject on QueryBuilder<
    CacheMetadataDocument, CacheMetadataDocument, QFilterCondition> {}

extension CacheMetadataDocumentQueryLinks on QueryBuilder<CacheMetadataDocument,
    CacheMetadataDocument, QFilterCondition> {}

extension CacheMetadataDocumentQuerySortBy
    on QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QSortBy> {
  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterSortBy>
      sortByDownloadAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadAttempts', Sort.asc);
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterSortBy>
      sortByDownloadAttemptsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadAttempts', Sort.desc);
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterSortBy>
      sortByFailureReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failureReason', Sort.asc);
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterSortBy>
      sortByFailureReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failureReason', Sort.desc);
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterSortBy>
      sortByLastAccessed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAccessed', Sort.asc);
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterSortBy>
      sortByLastAccessedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAccessed', Sort.desc);
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterSortBy>
      sortByLastDownloadAttempt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDownloadAttempt', Sort.asc);
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterSortBy>
      sortByLastDownloadAttemptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDownloadAttempt', Sort.desc);
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterSortBy>
      sortByOriginalUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalUrl', Sort.asc);
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterSortBy>
      sortByOriginalUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalUrl', Sort.desc);
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterSortBy>
      sortByReferenceCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceCount', Sort.asc);
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterSortBy>
      sortByReferenceCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceCount', Sort.desc);
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterSortBy>
      sortByTrackId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackId', Sort.asc);
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterSortBy>
      sortByTrackIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackId', Sort.desc);
    });
  }
}

extension CacheMetadataDocumentQuerySortThenBy
    on QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QSortThenBy> {
  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterSortBy>
      thenByDownloadAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadAttempts', Sort.asc);
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterSortBy>
      thenByDownloadAttemptsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadAttempts', Sort.desc);
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterSortBy>
      thenByFailureReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failureReason', Sort.asc);
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterSortBy>
      thenByFailureReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failureReason', Sort.desc);
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterSortBy>
      thenByLastAccessed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAccessed', Sort.asc);
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterSortBy>
      thenByLastAccessedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAccessed', Sort.desc);
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterSortBy>
      thenByLastDownloadAttempt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDownloadAttempt', Sort.asc);
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterSortBy>
      thenByLastDownloadAttemptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDownloadAttempt', Sort.desc);
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterSortBy>
      thenByOriginalUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalUrl', Sort.asc);
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterSortBy>
      thenByOriginalUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalUrl', Sort.desc);
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterSortBy>
      thenByReferenceCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceCount', Sort.asc);
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterSortBy>
      thenByReferenceCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceCount', Sort.desc);
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterSortBy>
      thenByTrackId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackId', Sort.asc);
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QAfterSortBy>
      thenByTrackIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackId', Sort.desc);
    });
  }
}

extension CacheMetadataDocumentQueryWhereDistinct
    on QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QDistinct> {
  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QDistinct>
      distinctByDownloadAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'downloadAttempts');
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QDistinct>
      distinctByFailureReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'failureReason',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QDistinct>
      distinctByLastAccessed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastAccessed');
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QDistinct>
      distinctByLastDownloadAttempt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastDownloadAttempt');
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QDistinct>
      distinctByOriginalUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'originalUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QDistinct>
      distinctByReferenceCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'referenceCount');
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QDistinct>
      distinctByReferences() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'references');
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QDistinct>
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheMetadataDocument, QDistinct>
      distinctByTrackId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trackId', caseSensitive: caseSensitive);
    });
  }
}

extension CacheMetadataDocumentQueryProperty on QueryBuilder<
    CacheMetadataDocument, CacheMetadataDocument, QQueryProperty> {
  QueryBuilder<CacheMetadataDocument, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<CacheMetadataDocument, int, QQueryOperations>
      downloadAttemptsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'downloadAttempts');
    });
  }

  QueryBuilder<CacheMetadataDocument, String?, QQueryOperations>
      failureReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'failureReason');
    });
  }

  QueryBuilder<CacheMetadataDocument, DateTime, QQueryOperations>
      lastAccessedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastAccessed');
    });
  }

  QueryBuilder<CacheMetadataDocument, DateTime?, QQueryOperations>
      lastDownloadAttemptProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastDownloadAttempt');
    });
  }

  QueryBuilder<CacheMetadataDocument, String?, QQueryOperations>
      originalUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'originalUrl');
    });
  }

  QueryBuilder<CacheMetadataDocument, int, QQueryOperations>
      referenceCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'referenceCount');
    });
  }

  QueryBuilder<CacheMetadataDocument, List<String>, QQueryOperations>
      referencesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'references');
    });
  }

  QueryBuilder<CacheMetadataDocument, CacheStatus, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<CacheMetadataDocument, String, QQueryOperations>
      trackIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trackId');
    });
  }
}
