// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_reference_document.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCacheReferenceDocumentCollection on Isar {
  IsarCollection<CacheReferenceDocument> get cacheReferenceDocuments =>
      this.collection();
}

const CacheReferenceDocumentSchema = CollectionSchema(
  name: r'CacheReferenceDocument',
  id: 5361073784748278809,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'lastAccessed': PropertySchema(
      id: 1,
      name: r'lastAccessed',
      type: IsarType.dateTime,
    ),
    r'referenceIds': PropertySchema(
      id: 2,
      name: r'referenceIds',
      type: IsarType.stringList,
    ),
    r'trackId': PropertySchema(
      id: 3,
      name: r'trackId',
      type: IsarType.string,
    )
  },
  estimateSize: _cacheReferenceDocumentEstimateSize,
  serialize: _cacheReferenceDocumentSerialize,
  deserialize: _cacheReferenceDocumentDeserialize,
  deserializeProp: _cacheReferenceDocumentDeserializeProp,
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
  getId: _cacheReferenceDocumentGetId,
  getLinks: _cacheReferenceDocumentGetLinks,
  attach: _cacheReferenceDocumentAttach,
  version: '3.1.0+1',
);

int _cacheReferenceDocumentEstimateSize(
  CacheReferenceDocument object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.referenceIds.length * 3;
  {
    for (var i = 0; i < object.referenceIds.length; i++) {
      final value = object.referenceIds[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.trackId.length * 3;
  return bytesCount;
}

void _cacheReferenceDocumentSerialize(
  CacheReferenceDocument object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeDateTime(offsets[1], object.lastAccessed);
  writer.writeStringList(offsets[2], object.referenceIds);
  writer.writeString(offsets[3], object.trackId);
}

CacheReferenceDocument _cacheReferenceDocumentDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CacheReferenceDocument();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.lastAccessed = reader.readDateTimeOrNull(offsets[1]);
  object.referenceIds = reader.readStringList(offsets[2]) ?? [];
  object.trackId = reader.readString(offsets[3]);
  return object;
}

P _cacheReferenceDocumentDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _cacheReferenceDocumentGetId(CacheReferenceDocument object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _cacheReferenceDocumentGetLinks(
    CacheReferenceDocument object) {
  return [];
}

void _cacheReferenceDocumentAttach(
    IsarCollection<dynamic> col, Id id, CacheReferenceDocument object) {}

extension CacheReferenceDocumentByIndex
    on IsarCollection<CacheReferenceDocument> {
  Future<CacheReferenceDocument?> getByTrackId(String trackId) {
    return getByIndex(r'trackId', [trackId]);
  }

  CacheReferenceDocument? getByTrackIdSync(String trackId) {
    return getByIndexSync(r'trackId', [trackId]);
  }

  Future<bool> deleteByTrackId(String trackId) {
    return deleteByIndex(r'trackId', [trackId]);
  }

  bool deleteByTrackIdSync(String trackId) {
    return deleteByIndexSync(r'trackId', [trackId]);
  }

  Future<List<CacheReferenceDocument?>> getAllByTrackId(
      List<String> trackIdValues) {
    final values = trackIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'trackId', values);
  }

  List<CacheReferenceDocument?> getAllByTrackIdSync(
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

  Future<Id> putByTrackId(CacheReferenceDocument object) {
    return putByIndex(r'trackId', object);
  }

  Id putByTrackIdSync(CacheReferenceDocument object, {bool saveLinks = true}) {
    return putByIndexSync(r'trackId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByTrackId(List<CacheReferenceDocument> objects) {
    return putAllByIndex(r'trackId', objects);
  }

  List<Id> putAllByTrackIdSync(List<CacheReferenceDocument> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'trackId', objects, saveLinks: saveLinks);
  }
}

extension CacheReferenceDocumentQueryWhereSort
    on QueryBuilder<CacheReferenceDocument, CacheReferenceDocument, QWhere> {
  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CacheReferenceDocumentQueryWhere on QueryBuilder<
    CacheReferenceDocument, CacheReferenceDocument, QWhereClause> {
  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
      QAfterWhereClause> isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
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

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
      QAfterWhereClause> isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
      QAfterWhereClause> isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
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

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
      QAfterWhereClause> trackIdEqualTo(String trackId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'trackId',
        value: [trackId],
      ));
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
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

extension CacheReferenceDocumentQueryFilter on QueryBuilder<
    CacheReferenceDocument, CacheReferenceDocument, QFilterCondition> {
  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
      QAfterFilterCondition> createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
      QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
      QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
      QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
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

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
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

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
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

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
      QAfterFilterCondition> lastAccessedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastAccessed',
      ));
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
      QAfterFilterCondition> lastAccessedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastAccessed',
      ));
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
      QAfterFilterCondition> lastAccessedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastAccessed',
        value: value,
      ));
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
      QAfterFilterCondition> lastAccessedGreaterThan(
    DateTime? value, {
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

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
      QAfterFilterCondition> lastAccessedLessThan(
    DateTime? value, {
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

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
      QAfterFilterCondition> lastAccessedBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
      QAfterFilterCondition> referenceIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'referenceIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
      QAfterFilterCondition> referenceIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'referenceIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
      QAfterFilterCondition> referenceIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'referenceIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
      QAfterFilterCondition> referenceIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'referenceIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
      QAfterFilterCondition> referenceIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'referenceIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
      QAfterFilterCondition> referenceIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'referenceIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
          QAfterFilterCondition>
      referenceIdsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'referenceIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
          QAfterFilterCondition>
      referenceIdsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'referenceIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
      QAfterFilterCondition> referenceIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'referenceIds',
        value: '',
      ));
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
      QAfterFilterCondition> referenceIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'referenceIds',
        value: '',
      ));
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
      QAfterFilterCondition> referenceIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'referenceIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
      QAfterFilterCondition> referenceIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'referenceIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
      QAfterFilterCondition> referenceIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'referenceIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
      QAfterFilterCondition> referenceIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'referenceIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
      QAfterFilterCondition> referenceIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'referenceIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
      QAfterFilterCondition> referenceIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'referenceIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
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

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
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

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
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

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
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

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
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

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
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

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
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

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
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

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
      QAfterFilterCondition> trackIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trackId',
        value: '',
      ));
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument,
      QAfterFilterCondition> trackIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'trackId',
        value: '',
      ));
    });
  }
}

extension CacheReferenceDocumentQueryObject on QueryBuilder<
    CacheReferenceDocument, CacheReferenceDocument, QFilterCondition> {}

extension CacheReferenceDocumentQueryLinks on QueryBuilder<
    CacheReferenceDocument, CacheReferenceDocument, QFilterCondition> {}

extension CacheReferenceDocumentQuerySortBy
    on QueryBuilder<CacheReferenceDocument, CacheReferenceDocument, QSortBy> {
  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument, QAfterSortBy>
      sortByLastAccessed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAccessed', Sort.asc);
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument, QAfterSortBy>
      sortByLastAccessedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAccessed', Sort.desc);
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument, QAfterSortBy>
      sortByTrackId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackId', Sort.asc);
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument, QAfterSortBy>
      sortByTrackIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackId', Sort.desc);
    });
  }
}

extension CacheReferenceDocumentQuerySortThenBy on QueryBuilder<
    CacheReferenceDocument, CacheReferenceDocument, QSortThenBy> {
  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument, QAfterSortBy>
      thenByLastAccessed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAccessed', Sort.asc);
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument, QAfterSortBy>
      thenByLastAccessedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAccessed', Sort.desc);
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument, QAfterSortBy>
      thenByTrackId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackId', Sort.asc);
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument, QAfterSortBy>
      thenByTrackIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackId', Sort.desc);
    });
  }
}

extension CacheReferenceDocumentQueryWhereDistinct
    on QueryBuilder<CacheReferenceDocument, CacheReferenceDocument, QDistinct> {
  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument, QDistinct>
      distinctByLastAccessed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastAccessed');
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument, QDistinct>
      distinctByReferenceIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'referenceIds');
    });
  }

  QueryBuilder<CacheReferenceDocument, CacheReferenceDocument, QDistinct>
      distinctByTrackId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trackId', caseSensitive: caseSensitive);
    });
  }
}

extension CacheReferenceDocumentQueryProperty on QueryBuilder<
    CacheReferenceDocument, CacheReferenceDocument, QQueryProperty> {
  QueryBuilder<CacheReferenceDocument, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<CacheReferenceDocument, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<CacheReferenceDocument, DateTime?, QQueryOperations>
      lastAccessedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastAccessed');
    });
  }

  QueryBuilder<CacheReferenceDocument, List<String>, QQueryOperations>
      referenceIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'referenceIds');
    });
  }

  QueryBuilder<CacheReferenceDocument, String, QQueryOperations>
      trackIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trackId');
    });
  }
}
