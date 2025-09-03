// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_waveform_document.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAudioWaveformDocumentCollection on Isar {
  IsarCollection<AudioWaveformDocument> get audioWaveformDocuments =>
      this.collection();
}

const AudioWaveformDocumentSchema = CollectionSchema(
  name: r'AudioWaveformDocument',
  id: 2013557821864051059,
  properties: {
    r'algorithmVersion': PropertySchema(
      id: 0,
      name: r'algorithmVersion',
      type: IsarType.long,
    ),
    r'amplitudesJson': PropertySchema(
      id: 1,
      name: r'amplitudesJson',
      type: IsarType.string,
    ),
    r'audioSourceHash': PropertySchema(
      id: 2,
      name: r'audioSourceHash',
      type: IsarType.string,
    ),
    r'compressionLevel': PropertySchema(
      id: 3,
      name: r'compressionLevel',
      type: IsarType.long,
    ),
    r'durationMs': PropertySchema(
      id: 4,
      name: r'durationMs',
      type: IsarType.long,
    ),
    r'generatedAt': PropertySchema(
      id: 5,
      name: r'generatedAt',
      type: IsarType.dateTime,
    ),
    r'generationMethod': PropertySchema(
      id: 6,
      name: r'generationMethod',
      type: IsarType.string,
    ),
    r'id': PropertySchema(
      id: 7,
      name: r'id',
      type: IsarType.string,
    ),
    r'maxAmplitude': PropertySchema(
      id: 8,
      name: r'maxAmplitude',
      type: IsarType.double,
    ),
    r'rmsLevel': PropertySchema(
      id: 9,
      name: r'rmsLevel',
      type: IsarType.double,
    ),
    r'sampleRate': PropertySchema(
      id: 10,
      name: r'sampleRate',
      type: IsarType.long,
    ),
    r'syncMetadata': PropertySchema(
      id: 11,
      name: r'syncMetadata',
      type: IsarType.object,
      target: r'SyncMetadataDocument',
    ),
    r'targetSampleCount': PropertySchema(
      id: 12,
      name: r'targetSampleCount',
      type: IsarType.long,
    ),
    r'trackId': PropertySchema(
      id: 13,
      name: r'trackId',
      type: IsarType.string,
    )
  },
  estimateSize: _audioWaveformDocumentEstimateSize,
  serialize: _audioWaveformDocumentSerialize,
  deserialize: _audioWaveformDocumentDeserialize,
  deserializeProp: _audioWaveformDocumentDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'id': IndexSchema(
      id: -3268401673993471357,
      name: r'id',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'id',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'trackId': IndexSchema(
      id: -8614467705999066844,
      name: r'trackId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'trackId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'audioSourceHash': IndexSchema(
      id: 8954058033052885577,
      name: r'audioSourceHash',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'audioSourceHash',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'algorithmVersion': IndexSchema(
      id: -6794433698428730184,
      name: r'algorithmVersion',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'algorithmVersion',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {r'SyncMetadataDocument': SyncMetadataDocumentSchema},
  getId: _audioWaveformDocumentGetId,
  getLinks: _audioWaveformDocumentGetLinks,
  attach: _audioWaveformDocumentAttach,
  version: '3.1.0+1',
);

int _audioWaveformDocumentEstimateSize(
  AudioWaveformDocument object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.amplitudesJson.length * 3;
  {
    final value = object.audioSourceHash;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.generationMethod.length * 3;
  bytesCount += 3 + object.id.length * 3;
  {
    final value = object.syncMetadata;
    if (value != null) {
      bytesCount += 3 +
          SyncMetadataDocumentSchema.estimateSize(
              value, allOffsets[SyncMetadataDocument]!, allOffsets);
    }
  }
  bytesCount += 3 + object.trackId.length * 3;
  return bytesCount;
}

void _audioWaveformDocumentSerialize(
  AudioWaveformDocument object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.algorithmVersion);
  writer.writeString(offsets[1], object.amplitudesJson);
  writer.writeString(offsets[2], object.audioSourceHash);
  writer.writeLong(offsets[3], object.compressionLevel);
  writer.writeLong(offsets[4], object.durationMs);
  writer.writeDateTime(offsets[5], object.generatedAt);
  writer.writeString(offsets[6], object.generationMethod);
  writer.writeString(offsets[7], object.id);
  writer.writeDouble(offsets[8], object.maxAmplitude);
  writer.writeDouble(offsets[9], object.rmsLevel);
  writer.writeLong(offsets[10], object.sampleRate);
  writer.writeObject<SyncMetadataDocument>(
    offsets[11],
    allOffsets,
    SyncMetadataDocumentSchema.serialize,
    object.syncMetadata,
  );
  writer.writeLong(offsets[12], object.targetSampleCount);
  writer.writeString(offsets[13], object.trackId);
}

AudioWaveformDocument _audioWaveformDocumentDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AudioWaveformDocument();
  object.algorithmVersion = reader.readLongOrNull(offsets[0]);
  object.amplitudesJson = reader.readString(offsets[1]);
  object.audioSourceHash = reader.readStringOrNull(offsets[2]);
  object.compressionLevel = reader.readLong(offsets[3]);
  object.durationMs = reader.readLong(offsets[4]);
  object.generatedAt = reader.readDateTime(offsets[5]);
  object.generationMethod = reader.readString(offsets[6]);
  object.id = reader.readString(offsets[7]);
  object.maxAmplitude = reader.readDouble(offsets[8]);
  object.rmsLevel = reader.readDouble(offsets[9]);
  object.sampleRate = reader.readLong(offsets[10]);
  object.syncMetadata = reader.readObjectOrNull<SyncMetadataDocument>(
    offsets[11],
    SyncMetadataDocumentSchema.deserialize,
    allOffsets,
  );
  object.targetSampleCount = reader.readLong(offsets[12]);
  object.trackId = reader.readString(offsets[13]);
  return object;
}

P _audioWaveformDocumentDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
    case 9:
      return (reader.readDouble(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readObjectOrNull<SyncMetadataDocument>(
        offset,
        SyncMetadataDocumentSchema.deserialize,
        allOffsets,
      )) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _audioWaveformDocumentGetId(AudioWaveformDocument object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _audioWaveformDocumentGetLinks(
    AudioWaveformDocument object) {
  return [];
}

void _audioWaveformDocumentAttach(
    IsarCollection<dynamic> col, Id id, AudioWaveformDocument object) {}

extension AudioWaveformDocumentByIndex
    on IsarCollection<AudioWaveformDocument> {
  Future<AudioWaveformDocument?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  AudioWaveformDocument? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<AudioWaveformDocument?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<AudioWaveformDocument?> getAllByIdSync(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'id', values);
  }

  Future<int> deleteAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'id', values);
  }

  int deleteAllByIdSync(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'id', values);
  }

  Future<Id> putById(AudioWaveformDocument object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(AudioWaveformDocument object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<AudioWaveformDocument> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<AudioWaveformDocument> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension AudioWaveformDocumentQueryWhereSort
    on QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QWhere> {
  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterWhere>
      anyAlgorithmVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'algorithmVersion'),
      );
    });
  }
}

extension AudioWaveformDocumentQueryWhere on QueryBuilder<AudioWaveformDocument,
    AudioWaveformDocument, QWhereClause> {
  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterWhereClause>
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

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterWhereClause>
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

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterWhereClause>
      idEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterWhereClause>
      idNotEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [],
              upper: [id],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [id],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [id],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [],
              upper: [id],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterWhereClause>
      trackIdEqualTo(String trackId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'trackId',
        value: [trackId],
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterWhereClause>
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

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterWhereClause>
      audioSourceHashIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'audioSourceHash',
        value: [null],
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterWhereClause>
      audioSourceHashIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'audioSourceHash',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterWhereClause>
      audioSourceHashEqualTo(String? audioSourceHash) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'audioSourceHash',
        value: [audioSourceHash],
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterWhereClause>
      audioSourceHashNotEqualTo(String? audioSourceHash) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'audioSourceHash',
              lower: [],
              upper: [audioSourceHash],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'audioSourceHash',
              lower: [audioSourceHash],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'audioSourceHash',
              lower: [audioSourceHash],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'audioSourceHash',
              lower: [],
              upper: [audioSourceHash],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterWhereClause>
      algorithmVersionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'algorithmVersion',
        value: [null],
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterWhereClause>
      algorithmVersionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'algorithmVersion',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterWhereClause>
      algorithmVersionEqualTo(int? algorithmVersion) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'algorithmVersion',
        value: [algorithmVersion],
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterWhereClause>
      algorithmVersionNotEqualTo(int? algorithmVersion) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'algorithmVersion',
              lower: [],
              upper: [algorithmVersion],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'algorithmVersion',
              lower: [algorithmVersion],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'algorithmVersion',
              lower: [algorithmVersion],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'algorithmVersion',
              lower: [],
              upper: [algorithmVersion],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterWhereClause>
      algorithmVersionGreaterThan(
    int? algorithmVersion, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'algorithmVersion',
        lower: [algorithmVersion],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterWhereClause>
      algorithmVersionLessThan(
    int? algorithmVersion, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'algorithmVersion',
        lower: [],
        upper: [algorithmVersion],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterWhereClause>
      algorithmVersionBetween(
    int? lowerAlgorithmVersion,
    int? upperAlgorithmVersion, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'algorithmVersion',
        lower: [lowerAlgorithmVersion],
        includeLower: includeLower,
        upper: [upperAlgorithmVersion],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AudioWaveformDocumentQueryFilter on QueryBuilder<
    AudioWaveformDocument, AudioWaveformDocument, QFilterCondition> {
  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> algorithmVersionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'algorithmVersion',
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> algorithmVersionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'algorithmVersion',
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> algorithmVersionEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'algorithmVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> algorithmVersionGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'algorithmVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> algorithmVersionLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'algorithmVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> algorithmVersionBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'algorithmVersion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> amplitudesJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amplitudesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> amplitudesJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'amplitudesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> amplitudesJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'amplitudesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> amplitudesJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'amplitudesJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> amplitudesJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'amplitudesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> amplitudesJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'amplitudesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
          QAfterFilterCondition>
      amplitudesJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'amplitudesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
          QAfterFilterCondition>
      amplitudesJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'amplitudesJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> amplitudesJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amplitudesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> amplitudesJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'amplitudesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> audioSourceHashIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'audioSourceHash',
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> audioSourceHashIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'audioSourceHash',
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> audioSourceHashEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'audioSourceHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> audioSourceHashGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'audioSourceHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> audioSourceHashLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'audioSourceHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> audioSourceHashBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'audioSourceHash',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> audioSourceHashStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'audioSourceHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> audioSourceHashEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'audioSourceHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
          QAfterFilterCondition>
      audioSourceHashContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'audioSourceHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
          QAfterFilterCondition>
      audioSourceHashMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'audioSourceHash',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> audioSourceHashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'audioSourceHash',
        value: '',
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> audioSourceHashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'audioSourceHash',
        value: '',
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> compressionLevelEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'compressionLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> compressionLevelGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'compressionLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> compressionLevelLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'compressionLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> compressionLevelBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'compressionLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> durationMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'durationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> durationMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'durationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> durationMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'durationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> durationMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'durationMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> generatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'generatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> generatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'generatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> generatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'generatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> generatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'generatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> generationMethodEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'generationMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> generationMethodGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'generationMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> generationMethodLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'generationMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> generationMethodBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'generationMethod',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> generationMethodStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'generationMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> generationMethodEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'generationMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
          QAfterFilterCondition>
      generationMethodContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'generationMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
          QAfterFilterCondition>
      generationMethodMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'generationMethod',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> generationMethodIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'generationMethod',
        value: '',
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> generationMethodIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'generationMethod',
        value: '',
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> idGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> idLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> idBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
          QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
          QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
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

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
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

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
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

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> maxAmplitudeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxAmplitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> maxAmplitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxAmplitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> maxAmplitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxAmplitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> maxAmplitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxAmplitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> rmsLevelEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rmsLevel',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> rmsLevelGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rmsLevel',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> rmsLevelLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rmsLevel',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> rmsLevelBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rmsLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> sampleRateEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sampleRate',
        value: value,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> sampleRateGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sampleRate',
        value: value,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> sampleRateLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sampleRate',
        value: value,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> sampleRateBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sampleRate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> syncMetadataIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'syncMetadata',
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> syncMetadataIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'syncMetadata',
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> targetSampleCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetSampleCount',
        value: value,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> targetSampleCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetSampleCount',
        value: value,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> targetSampleCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetSampleCount',
        value: value,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> targetSampleCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetSampleCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
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

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
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

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
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

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
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

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
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

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
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

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
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

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
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

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> trackIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trackId',
        value: '',
      ));
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> trackIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'trackId',
        value: '',
      ));
    });
  }
}

extension AudioWaveformDocumentQueryObject on QueryBuilder<
    AudioWaveformDocument, AudioWaveformDocument, QFilterCondition> {
  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument,
      QAfterFilterCondition> syncMetadata(FilterQuery<SyncMetadataDocument> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'syncMetadata');
    });
  }
}

extension AudioWaveformDocumentQueryLinks on QueryBuilder<AudioWaveformDocument,
    AudioWaveformDocument, QFilterCondition> {}

extension AudioWaveformDocumentQuerySortBy
    on QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QSortBy> {
  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      sortByAlgorithmVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'algorithmVersion', Sort.asc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      sortByAlgorithmVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'algorithmVersion', Sort.desc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      sortByAmplitudesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amplitudesJson', Sort.asc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      sortByAmplitudesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amplitudesJson', Sort.desc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      sortByAudioSourceHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioSourceHash', Sort.asc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      sortByAudioSourceHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioSourceHash', Sort.desc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      sortByCompressionLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'compressionLevel', Sort.asc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      sortByCompressionLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'compressionLevel', Sort.desc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      sortByDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMs', Sort.asc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      sortByDurationMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMs', Sort.desc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      sortByGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedAt', Sort.asc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      sortByGeneratedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedAt', Sort.desc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      sortByGenerationMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generationMethod', Sort.asc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      sortByGenerationMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generationMethod', Sort.desc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      sortByMaxAmplitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxAmplitude', Sort.asc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      sortByMaxAmplitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxAmplitude', Sort.desc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      sortByRmsLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rmsLevel', Sort.asc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      sortByRmsLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rmsLevel', Sort.desc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      sortBySampleRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleRate', Sort.asc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      sortBySampleRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleRate', Sort.desc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      sortByTargetSampleCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetSampleCount', Sort.asc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      sortByTargetSampleCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetSampleCount', Sort.desc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      sortByTrackId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackId', Sort.asc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      sortByTrackIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackId', Sort.desc);
    });
  }
}

extension AudioWaveformDocumentQuerySortThenBy
    on QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QSortThenBy> {
  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      thenByAlgorithmVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'algorithmVersion', Sort.asc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      thenByAlgorithmVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'algorithmVersion', Sort.desc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      thenByAmplitudesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amplitudesJson', Sort.asc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      thenByAmplitudesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amplitudesJson', Sort.desc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      thenByAudioSourceHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioSourceHash', Sort.asc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      thenByAudioSourceHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioSourceHash', Sort.desc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      thenByCompressionLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'compressionLevel', Sort.asc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      thenByCompressionLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'compressionLevel', Sort.desc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      thenByDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMs', Sort.asc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      thenByDurationMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMs', Sort.desc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      thenByGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedAt', Sort.asc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      thenByGeneratedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedAt', Sort.desc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      thenByGenerationMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generationMethod', Sort.asc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      thenByGenerationMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generationMethod', Sort.desc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      thenByMaxAmplitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxAmplitude', Sort.asc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      thenByMaxAmplitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxAmplitude', Sort.desc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      thenByRmsLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rmsLevel', Sort.asc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      thenByRmsLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rmsLevel', Sort.desc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      thenBySampleRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleRate', Sort.asc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      thenBySampleRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleRate', Sort.desc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      thenByTargetSampleCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetSampleCount', Sort.asc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      thenByTargetSampleCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetSampleCount', Sort.desc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      thenByTrackId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackId', Sort.asc);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QAfterSortBy>
      thenByTrackIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackId', Sort.desc);
    });
  }
}

extension AudioWaveformDocumentQueryWhereDistinct
    on QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QDistinct> {
  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QDistinct>
      distinctByAlgorithmVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'algorithmVersion');
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QDistinct>
      distinctByAmplitudesJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amplitudesJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QDistinct>
      distinctByAudioSourceHash({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'audioSourceHash',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QDistinct>
      distinctByCompressionLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'compressionLevel');
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QDistinct>
      distinctByDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationMs');
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QDistinct>
      distinctByGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'generatedAt');
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QDistinct>
      distinctByGenerationMethod({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'generationMethod',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QDistinct>
      distinctById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QDistinct>
      distinctByMaxAmplitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxAmplitude');
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QDistinct>
      distinctByRmsLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rmsLevel');
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QDistinct>
      distinctBySampleRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sampleRate');
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QDistinct>
      distinctByTargetSampleCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetSampleCount');
    });
  }

  QueryBuilder<AudioWaveformDocument, AudioWaveformDocument, QDistinct>
      distinctByTrackId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trackId', caseSensitive: caseSensitive);
    });
  }
}

extension AudioWaveformDocumentQueryProperty on QueryBuilder<
    AudioWaveformDocument, AudioWaveformDocument, QQueryProperty> {
  QueryBuilder<AudioWaveformDocument, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<AudioWaveformDocument, int?, QQueryOperations>
      algorithmVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'algorithmVersion');
    });
  }

  QueryBuilder<AudioWaveformDocument, String, QQueryOperations>
      amplitudesJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amplitudesJson');
    });
  }

  QueryBuilder<AudioWaveformDocument, String?, QQueryOperations>
      audioSourceHashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'audioSourceHash');
    });
  }

  QueryBuilder<AudioWaveformDocument, int, QQueryOperations>
      compressionLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'compressionLevel');
    });
  }

  QueryBuilder<AudioWaveformDocument, int, QQueryOperations>
      durationMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationMs');
    });
  }

  QueryBuilder<AudioWaveformDocument, DateTime, QQueryOperations>
      generatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'generatedAt');
    });
  }

  QueryBuilder<AudioWaveformDocument, String, QQueryOperations>
      generationMethodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'generationMethod');
    });
  }

  QueryBuilder<AudioWaveformDocument, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AudioWaveformDocument, double, QQueryOperations>
      maxAmplitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxAmplitude');
    });
  }

  QueryBuilder<AudioWaveformDocument, double, QQueryOperations>
      rmsLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rmsLevel');
    });
  }

  QueryBuilder<AudioWaveformDocument, int, QQueryOperations>
      sampleRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sampleRate');
    });
  }

  QueryBuilder<AudioWaveformDocument, SyncMetadataDocument?, QQueryOperations>
      syncMetadataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncMetadata');
    });
  }

  QueryBuilder<AudioWaveformDocument, int, QQueryOperations>
      targetSampleCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetSampleCount');
    });
  }

  QueryBuilder<AudioWaveformDocument, String, QQueryOperations>
      trackIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trackId');
    });
  }
}
