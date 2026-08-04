// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_split_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetGroupSplitModelCollection on Isar {
  IsarCollection<GroupSplitModel> get groupSplitModels => this.collection();
}

const GroupSplitModelSchema = CollectionSchema(
  name: r'GroupSplitModel',
  id: 7896064718567814961,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'currencyCode': PropertySchema(
      id: 1,
      name: r'currencyCode',
      type: IsarType.string,
    ),
    r'currencyScale': PropertySchema(
      id: 2,
      name: r'currencyScale',
      type: IsarType.long,
    ),
    r'deletedAt': PropertySchema(
      id: 3,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'groupId': PropertySchema(id: 4, name: r'groupId', type: IsarType.string),
    r'linkedExpenseId': PropertySchema(
      id: 5,
      name: r'linkedExpenseId',
      type: IsarType.string,
    ),
    r'localId': PropertySchema(id: 6, name: r'localId', type: IsarType.string),
    r'notes': PropertySchema(id: 7, name: r'notes', type: IsarType.string),
    r'occurredAt': PropertySchema(
      id: 8,
      name: r'occurredAt',
      type: IsarType.dateTime,
    ),
    r'paidByMemberId': PropertySchema(
      id: 9,
      name: r'paidByMemberId',
      type: IsarType.string,
    ),
    r'revision': PropertySchema(id: 10, name: r'revision', type: IsarType.long),
    r'shares': PropertySchema(
      id: 11,
      name: r'shares',
      type: IsarType.objectList,

      target: r'GroupSplitShareModel',
    ),
    r'splitMethod': PropertySchema(
      id: 12,
      name: r'splitMethod',
      type: IsarType.string,
      enumMap: _GroupSplitModelsplitMethodEnumValueMap,
    ),
    r'title': PropertySchema(id: 13, name: r'title', type: IsarType.string),
    r'totalAmountMinor': PropertySchema(
      id: 14,
      name: r'totalAmountMinor',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 15,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _groupSplitModelEstimateSize,
  serialize: _groupSplitModelSerialize,
  deserialize: _groupSplitModelDeserialize,
  deserializeProp: _groupSplitModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'localId': IndexSchema(
      id: 1199848425898359622,
      name: r'localId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'localId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'groupId': IndexSchema(
      id: -8523216633229774932,
      name: r'groupId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'groupId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'paidByMemberId': IndexSchema(
      id: 3888134982811724266,
      name: r'paidByMemberId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'paidByMemberId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'occurredAt': IndexSchema(
      id: 1229694562040044173,
      name: r'occurredAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'occurredAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'linkedExpenseId': IndexSchema(
      id: -8722540768232253689,
      name: r'linkedExpenseId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'linkedExpenseId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {r'GroupSplitShareModel': GroupSplitShareModelSchema},

  getId: _groupSplitModelGetId,
  getLinks: _groupSplitModelGetLinks,
  attach: _groupSplitModelAttach,
  version: '3.3.2',
);

int _groupSplitModelEstimateSize(
  GroupSplitModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.currencyCode.length * 3;
  bytesCount += 3 + object.groupId.length * 3;
  {
    final value = object.linkedExpenseId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.localId.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.paidByMemberId.length * 3;
  bytesCount += 3 + object.shares.length * 3;
  {
    final offsets = allOffsets[GroupSplitShareModel]!;
    for (var i = 0; i < object.shares.length; i++) {
      final value = object.shares[i];
      bytesCount += GroupSplitShareModelSchema.estimateSize(
        value,
        offsets,
        allOffsets,
      );
    }
  }
  bytesCount += 3 + object.splitMethod.name.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _groupSplitModelSerialize(
  GroupSplitModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.currencyCode);
  writer.writeLong(offsets[2], object.currencyScale);
  writer.writeDateTime(offsets[3], object.deletedAt);
  writer.writeString(offsets[4], object.groupId);
  writer.writeString(offsets[5], object.linkedExpenseId);
  writer.writeString(offsets[6], object.localId);
  writer.writeString(offsets[7], object.notes);
  writer.writeDateTime(offsets[8], object.occurredAt);
  writer.writeString(offsets[9], object.paidByMemberId);
  writer.writeLong(offsets[10], object.revision);
  writer.writeObjectList<GroupSplitShareModel>(
    offsets[11],
    allOffsets,
    GroupSplitShareModelSchema.serialize,
    object.shares,
  );
  writer.writeString(offsets[12], object.splitMethod.name);
  writer.writeString(offsets[13], object.title);
  writer.writeLong(offsets[14], object.totalAmountMinor);
  writer.writeDateTime(offsets[15], object.updatedAt);
}

GroupSplitModel _groupSplitModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = GroupSplitModel();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.currencyCode = reader.readString(offsets[1]);
  object.currencyScale = reader.readLong(offsets[2]);
  object.deletedAt = reader.readDateTimeOrNull(offsets[3]);
  object.groupId = reader.readString(offsets[4]);
  object.id = id;
  object.linkedExpenseId = reader.readStringOrNull(offsets[5]);
  object.localId = reader.readString(offsets[6]);
  object.notes = reader.readStringOrNull(offsets[7]);
  object.occurredAt = reader.readDateTime(offsets[8]);
  object.paidByMemberId = reader.readString(offsets[9]);
  object.revision = reader.readLong(offsets[10]);
  object.shares =
      reader.readObjectList<GroupSplitShareModel>(
        offsets[11],
        GroupSplitShareModelSchema.deserialize,
        allOffsets,
        GroupSplitShareModel(),
      ) ??
      [];
  object.splitMethod =
      _GroupSplitModelsplitMethodValueEnumMap[reader.readStringOrNull(
        offsets[12],
      )] ??
      SplitMethod.equal;
  object.title = reader.readString(offsets[13]);
  object.totalAmountMinor = reader.readLong(offsets[14]);
  object.updatedAt = reader.readDateTime(offsets[15]);
  return object;
}

P _groupSplitModelDeserializeProp<P>(
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
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readObjectList<GroupSplitShareModel>(
                offset,
                GroupSplitShareModelSchema.deserialize,
                allOffsets,
                GroupSplitShareModel(),
              ) ??
              [])
          as P;
    case 12:
      return (_GroupSplitModelsplitMethodValueEnumMap[reader.readStringOrNull(
                offset,
              )] ??
              SplitMethod.equal)
          as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    case 15:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _GroupSplitModelsplitMethodEnumValueMap = {
  r'equal': r'equal',
  r'exact': r'exact',
  r'percentage': r'percentage',
  r'shares': r'shares',
};
const _GroupSplitModelsplitMethodValueEnumMap = {
  r'equal': SplitMethod.equal,
  r'exact': SplitMethod.exact,
  r'percentage': SplitMethod.percentage,
  r'shares': SplitMethod.shares,
};

Id _groupSplitModelGetId(GroupSplitModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _groupSplitModelGetLinks(GroupSplitModel object) {
  return [];
}

void _groupSplitModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  GroupSplitModel object,
) {
  object.id = id;
}

extension GroupSplitModelByIndex on IsarCollection<GroupSplitModel> {
  Future<GroupSplitModel?> getByLocalId(String localId) {
    return getByIndex(r'localId', [localId]);
  }

  GroupSplitModel? getByLocalIdSync(String localId) {
    return getByIndexSync(r'localId', [localId]);
  }

  Future<bool> deleteByLocalId(String localId) {
    return deleteByIndex(r'localId', [localId]);
  }

  bool deleteByLocalIdSync(String localId) {
    return deleteByIndexSync(r'localId', [localId]);
  }

  Future<List<GroupSplitModel?>> getAllByLocalId(List<String> localIdValues) {
    final values = localIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'localId', values);
  }

  List<GroupSplitModel?> getAllByLocalIdSync(List<String> localIdValues) {
    final values = localIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'localId', values);
  }

  Future<int> deleteAllByLocalId(List<String> localIdValues) {
    final values = localIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'localId', values);
  }

  int deleteAllByLocalIdSync(List<String> localIdValues) {
    final values = localIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'localId', values);
  }

  Future<Id> putByLocalId(GroupSplitModel object) {
    return putByIndex(r'localId', object);
  }

  Id putByLocalIdSync(GroupSplitModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'localId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByLocalId(List<GroupSplitModel> objects) {
    return putAllByIndex(r'localId', objects);
  }

  List<Id> putAllByLocalIdSync(
    List<GroupSplitModel> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'localId', objects, saveLinks: saveLinks);
  }
}

extension GroupSplitModelQueryWhereSort
    on QueryBuilder<GroupSplitModel, GroupSplitModel, QWhere> {
  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterWhere> anyOccurredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'occurredAt'),
      );
    });
  }
}

extension GroupSplitModelQueryWhere
    on QueryBuilder<GroupSplitModel, GroupSplitModel, QWhereClause> {
  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterWhereClause>
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterWhereClause>
  localIdEqualTo(String localId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'localId', value: [localId]),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterWhereClause>
  localIdNotEqualTo(String localId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'localId',
                lower: [],
                upper: [localId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'localId',
                lower: [localId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'localId',
                lower: [localId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'localId',
                lower: [],
                upper: [localId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterWhereClause>
  groupIdEqualTo(String groupId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'groupId', value: [groupId]),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterWhereClause>
  groupIdNotEqualTo(String groupId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'groupId',
                lower: [],
                upper: [groupId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'groupId',
                lower: [groupId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'groupId',
                lower: [groupId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'groupId',
                lower: [],
                upper: [groupId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterWhereClause>
  paidByMemberIdEqualTo(String paidByMemberId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'paidByMemberId',
          value: [paidByMemberId],
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterWhereClause>
  paidByMemberIdNotEqualTo(String paidByMemberId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'paidByMemberId',
                lower: [],
                upper: [paidByMemberId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'paidByMemberId',
                lower: [paidByMemberId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'paidByMemberId',
                lower: [paidByMemberId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'paidByMemberId',
                lower: [],
                upper: [paidByMemberId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterWhereClause>
  occurredAtEqualTo(DateTime occurredAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'occurredAt', value: [occurredAt]),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterWhereClause>
  occurredAtNotEqualTo(DateTime occurredAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'occurredAt',
                lower: [],
                upper: [occurredAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'occurredAt',
                lower: [occurredAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'occurredAt',
                lower: [occurredAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'occurredAt',
                lower: [],
                upper: [occurredAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterWhereClause>
  occurredAtGreaterThan(DateTime occurredAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'occurredAt',
          lower: [occurredAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterWhereClause>
  occurredAtLessThan(DateTime occurredAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'occurredAt',
          lower: [],
          upper: [occurredAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterWhereClause>
  occurredAtBetween(
    DateTime lowerOccurredAt,
    DateTime upperOccurredAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'occurredAt',
          lower: [lowerOccurredAt],
          includeLower: includeLower,
          upper: [upperOccurredAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterWhereClause>
  linkedExpenseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'linkedExpenseId', value: [null]),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterWhereClause>
  linkedExpenseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'linkedExpenseId',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterWhereClause>
  linkedExpenseIdEqualTo(String? linkedExpenseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'linkedExpenseId',
          value: [linkedExpenseId],
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterWhereClause>
  linkedExpenseIdNotEqualTo(String? linkedExpenseId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'linkedExpenseId',
                lower: [],
                upper: [linkedExpenseId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'linkedExpenseId',
                lower: [linkedExpenseId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'linkedExpenseId',
                lower: [linkedExpenseId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'linkedExpenseId',
                lower: [],
                upper: [linkedExpenseId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension GroupSplitModelQueryFilter
    on QueryBuilder<GroupSplitModel, GroupSplitModel, QFilterCondition> {
  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  currencyCodeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'currencyCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  currencyCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currencyCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  currencyCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currencyCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  currencyCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currencyCode',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  currencyCodeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'currencyCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  currencyCodeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'currencyCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  currencyCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'currencyCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  currencyCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'currencyCode',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  currencyCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'currencyCode', value: ''),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  currencyCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'currencyCode', value: ''),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  currencyScaleEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'currencyScale', value: value),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  currencyScaleGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currencyScale',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  currencyScaleLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currencyScale',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  currencyScaleBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currencyScale',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'deletedAt'),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'deletedAt'),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  deletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deletedAt', value: value),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  deletedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'deletedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  deletedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'deletedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  deletedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'deletedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  groupIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  groupIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  groupIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  groupIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'groupId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  groupIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  groupIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  groupIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  groupIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'groupId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  groupIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'groupId', value: ''),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  groupIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'groupId', value: ''),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  linkedExpenseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'linkedExpenseId'),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  linkedExpenseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'linkedExpenseId'),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  linkedExpenseIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'linkedExpenseId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  linkedExpenseIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'linkedExpenseId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  linkedExpenseIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'linkedExpenseId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  linkedExpenseIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'linkedExpenseId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  linkedExpenseIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'linkedExpenseId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  linkedExpenseIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'linkedExpenseId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  linkedExpenseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'linkedExpenseId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  linkedExpenseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'linkedExpenseId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  linkedExpenseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'linkedExpenseId', value: ''),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  linkedExpenseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'linkedExpenseId', value: ''),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  localIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'localId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  localIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'localId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  localIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'localId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  localIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'localId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  localIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'localId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  localIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'localId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  localIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'localId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  localIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'localId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  localIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'localId', value: ''),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  localIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'localId', value: ''),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  notesEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'notes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  notesStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  notesEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'notes',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  occurredAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'occurredAt', value: value),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  occurredAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'occurredAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  occurredAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'occurredAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  occurredAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'occurredAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  paidByMemberIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'paidByMemberId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  paidByMemberIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'paidByMemberId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  paidByMemberIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'paidByMemberId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  paidByMemberIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'paidByMemberId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  paidByMemberIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'paidByMemberId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  paidByMemberIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'paidByMemberId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  paidByMemberIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'paidByMemberId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  paidByMemberIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'paidByMemberId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  paidByMemberIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'paidByMemberId', value: ''),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  paidByMemberIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'paidByMemberId', value: ''),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  revisionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'revision', value: value),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  revisionGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'revision',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  revisionLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'revision',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  revisionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'revision',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  sharesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'shares', length, true, length, true);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  sharesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'shares', 0, true, 0, true);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  sharesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'shares', 0, false, 999999, true);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  sharesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'shares', 0, true, length, include);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  sharesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'shares', length, include, 999999, true);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  sharesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'shares',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  splitMethodEqualTo(SplitMethod value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'splitMethod',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  splitMethodGreaterThan(
    SplitMethod value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'splitMethod',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  splitMethodLessThan(
    SplitMethod value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'splitMethod',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  splitMethodBetween(
    SplitMethod lower,
    SplitMethod upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'splitMethod',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  splitMethodStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'splitMethod',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  splitMethodEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'splitMethod',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  splitMethodContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'splitMethod',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  splitMethodMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'splitMethod',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  splitMethodIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'splitMethod', value: ''),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  splitMethodIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'splitMethod', value: ''),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  titleEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'title',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  titleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  titleEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'title',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  totalAmountMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'totalAmountMinor', value: value),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  totalAmountMinorGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'totalAmountMinor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  totalAmountMinorLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'totalAmountMinor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  totalAmountMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'totalAmountMinor',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  updatedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension GroupSplitModelQueryObject
    on QueryBuilder<GroupSplitModel, GroupSplitModel, QFilterCondition> {
  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterFilterCondition>
  sharesElement(FilterQuery<GroupSplitShareModel> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'shares');
    });
  }
}

extension GroupSplitModelQueryLinks
    on QueryBuilder<GroupSplitModel, GroupSplitModel, QFilterCondition> {}

extension GroupSplitModelQuerySortBy
    on QueryBuilder<GroupSplitModel, GroupSplitModel, QSortBy> {
  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  sortByCurrencyCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyCode', Sort.asc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  sortByCurrencyCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyCode', Sort.desc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  sortByCurrencyScale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyScale', Sort.asc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  sortByCurrencyScaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyScale', Sort.desc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy> sortByGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.asc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  sortByGroupIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.desc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  sortByLinkedExpenseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedExpenseId', Sort.asc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  sortByLinkedExpenseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedExpenseId', Sort.desc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy> sortByLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.asc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  sortByLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.desc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  sortByOccurredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurredAt', Sort.asc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  sortByOccurredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurredAt', Sort.desc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  sortByPaidByMemberId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidByMemberId', Sort.asc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  sortByPaidByMemberIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidByMemberId', Sort.desc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  sortByRevision() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revision', Sort.asc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  sortByRevisionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revision', Sort.desc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  sortBySplitMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'splitMethod', Sort.asc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  sortBySplitMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'splitMethod', Sort.desc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  sortByTotalAmountMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmountMinor', Sort.asc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  sortByTotalAmountMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmountMinor', Sort.desc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension GroupSplitModelQuerySortThenBy
    on QueryBuilder<GroupSplitModel, GroupSplitModel, QSortThenBy> {
  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  thenByCurrencyCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyCode', Sort.asc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  thenByCurrencyCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyCode', Sort.desc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  thenByCurrencyScale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyScale', Sort.asc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  thenByCurrencyScaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyScale', Sort.desc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy> thenByGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.asc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  thenByGroupIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.desc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  thenByLinkedExpenseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedExpenseId', Sort.asc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  thenByLinkedExpenseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedExpenseId', Sort.desc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy> thenByLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.asc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  thenByLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.desc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  thenByOccurredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurredAt', Sort.asc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  thenByOccurredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurredAt', Sort.desc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  thenByPaidByMemberId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidByMemberId', Sort.asc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  thenByPaidByMemberIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidByMemberId', Sort.desc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  thenByRevision() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revision', Sort.asc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  thenByRevisionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revision', Sort.desc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  thenBySplitMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'splitMethod', Sort.asc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  thenBySplitMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'splitMethod', Sort.desc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  thenByTotalAmountMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmountMinor', Sort.asc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  thenByTotalAmountMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmountMinor', Sort.desc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension GroupSplitModelQueryWhereDistinct
    on QueryBuilder<GroupSplitModel, GroupSplitModel, QDistinct> {
  QueryBuilder<GroupSplitModel, GroupSplitModel, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QDistinct>
  distinctByCurrencyCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currencyCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QDistinct>
  distinctByCurrencyScale() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currencyScale');
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QDistinct>
  distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QDistinct> distinctByGroupId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'groupId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QDistinct>
  distinctByLinkedExpenseId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'linkedExpenseId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QDistinct> distinctByLocalId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QDistinct> distinctByNotes({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QDistinct>
  distinctByOccurredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'occurredAt');
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QDistinct>
  distinctByPaidByMemberId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'paidByMemberId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QDistinct>
  distinctByRevision() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'revision');
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QDistinct>
  distinctBySplitMethod({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'splitMethod', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QDistinct>
  distinctByTotalAmountMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalAmountMinor');
    });
  }

  QueryBuilder<GroupSplitModel, GroupSplitModel, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension GroupSplitModelQueryProperty
    on QueryBuilder<GroupSplitModel, GroupSplitModel, QQueryProperty> {
  QueryBuilder<GroupSplitModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<GroupSplitModel, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<GroupSplitModel, String, QQueryOperations>
  currencyCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currencyCode');
    });
  }

  QueryBuilder<GroupSplitModel, int, QQueryOperations> currencyScaleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currencyScale');
    });
  }

  QueryBuilder<GroupSplitModel, DateTime?, QQueryOperations>
  deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<GroupSplitModel, String, QQueryOperations> groupIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'groupId');
    });
  }

  QueryBuilder<GroupSplitModel, String?, QQueryOperations>
  linkedExpenseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linkedExpenseId');
    });
  }

  QueryBuilder<GroupSplitModel, String, QQueryOperations> localIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localId');
    });
  }

  QueryBuilder<GroupSplitModel, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<GroupSplitModel, DateTime, QQueryOperations>
  occurredAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'occurredAt');
    });
  }

  QueryBuilder<GroupSplitModel, String, QQueryOperations>
  paidByMemberIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paidByMemberId');
    });
  }

  QueryBuilder<GroupSplitModel, int, QQueryOperations> revisionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'revision');
    });
  }

  QueryBuilder<GroupSplitModel, List<GroupSplitShareModel>, QQueryOperations>
  sharesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shares');
    });
  }

  QueryBuilder<GroupSplitModel, SplitMethod, QQueryOperations>
  splitMethodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'splitMethod');
    });
  }

  QueryBuilder<GroupSplitModel, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<GroupSplitModel, int, QQueryOperations>
  totalAmountMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalAmountMinor');
    });
  }

  QueryBuilder<GroupSplitModel, DateTime, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const GroupSplitShareModelSchema = Schema(
  name: r'GroupSplitShareModel',
  id: -328138712071383855,
  properties: {
    r'memberId': PropertySchema(
      id: 0,
      name: r'memberId',
      type: IsarType.string,
    ),
    r'owedAmountMinor': PropertySchema(
      id: 1,
      name: r'owedAmountMinor',
      type: IsarType.long,
    ),
    r'percentageBasisPoints': PropertySchema(
      id: 2,
      name: r'percentageBasisPoints',
      type: IsarType.long,
    ),
    r'shareWeight': PropertySchema(
      id: 3,
      name: r'shareWeight',
      type: IsarType.long,
    ),
  },

  estimateSize: _groupSplitShareModelEstimateSize,
  serialize: _groupSplitShareModelSerialize,
  deserialize: _groupSplitShareModelDeserialize,
  deserializeProp: _groupSplitShareModelDeserializeProp,
);

int _groupSplitShareModelEstimateSize(
  GroupSplitShareModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.memberId.length * 3;
  return bytesCount;
}

void _groupSplitShareModelSerialize(
  GroupSplitShareModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.memberId);
  writer.writeLong(offsets[1], object.owedAmountMinor);
  writer.writeLong(offsets[2], object.percentageBasisPoints);
  writer.writeLong(offsets[3], object.shareWeight);
}

GroupSplitShareModel _groupSplitShareModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = GroupSplitShareModel();
  object.memberId = reader.readString(offsets[0]);
  object.owedAmountMinor = reader.readLong(offsets[1]);
  object.percentageBasisPoints = reader.readLongOrNull(offsets[2]);
  object.shareWeight = reader.readLongOrNull(offsets[3]);
  return object;
}

P _groupSplitShareModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension GroupSplitShareModelQueryFilter
    on
        QueryBuilder<
          GroupSplitShareModel,
          GroupSplitShareModel,
          QFilterCondition
        > {
  QueryBuilder<
    GroupSplitShareModel,
    GroupSplitShareModel,
    QAfterFilterCondition
  >
  memberIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'memberId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    GroupSplitShareModel,
    GroupSplitShareModel,
    QAfterFilterCondition
  >
  memberIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'memberId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    GroupSplitShareModel,
    GroupSplitShareModel,
    QAfterFilterCondition
  >
  memberIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'memberId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    GroupSplitShareModel,
    GroupSplitShareModel,
    QAfterFilterCondition
  >
  memberIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'memberId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    GroupSplitShareModel,
    GroupSplitShareModel,
    QAfterFilterCondition
  >
  memberIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'memberId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    GroupSplitShareModel,
    GroupSplitShareModel,
    QAfterFilterCondition
  >
  memberIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'memberId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    GroupSplitShareModel,
    GroupSplitShareModel,
    QAfterFilterCondition
  >
  memberIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'memberId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    GroupSplitShareModel,
    GroupSplitShareModel,
    QAfterFilterCondition
  >
  memberIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'memberId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    GroupSplitShareModel,
    GroupSplitShareModel,
    QAfterFilterCondition
  >
  memberIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'memberId', value: ''),
      );
    });
  }

  QueryBuilder<
    GroupSplitShareModel,
    GroupSplitShareModel,
    QAfterFilterCondition
  >
  memberIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'memberId', value: ''),
      );
    });
  }

  QueryBuilder<
    GroupSplitShareModel,
    GroupSplitShareModel,
    QAfterFilterCondition
  >
  owedAmountMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'owedAmountMinor', value: value),
      );
    });
  }

  QueryBuilder<
    GroupSplitShareModel,
    GroupSplitShareModel,
    QAfterFilterCondition
  >
  owedAmountMinorGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'owedAmountMinor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    GroupSplitShareModel,
    GroupSplitShareModel,
    QAfterFilterCondition
  >
  owedAmountMinorLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'owedAmountMinor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    GroupSplitShareModel,
    GroupSplitShareModel,
    QAfterFilterCondition
  >
  owedAmountMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'owedAmountMinor',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    GroupSplitShareModel,
    GroupSplitShareModel,
    QAfterFilterCondition
  >
  percentageBasisPointsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'percentageBasisPoints'),
      );
    });
  }

  QueryBuilder<
    GroupSplitShareModel,
    GroupSplitShareModel,
    QAfterFilterCondition
  >
  percentageBasisPointsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'percentageBasisPoints'),
      );
    });
  }

  QueryBuilder<
    GroupSplitShareModel,
    GroupSplitShareModel,
    QAfterFilterCondition
  >
  percentageBasisPointsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'percentageBasisPoints',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    GroupSplitShareModel,
    GroupSplitShareModel,
    QAfterFilterCondition
  >
  percentageBasisPointsGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'percentageBasisPoints',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    GroupSplitShareModel,
    GroupSplitShareModel,
    QAfterFilterCondition
  >
  percentageBasisPointsLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'percentageBasisPoints',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    GroupSplitShareModel,
    GroupSplitShareModel,
    QAfterFilterCondition
  >
  percentageBasisPointsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'percentageBasisPoints',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    GroupSplitShareModel,
    GroupSplitShareModel,
    QAfterFilterCondition
  >
  shareWeightIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'shareWeight'),
      );
    });
  }

  QueryBuilder<
    GroupSplitShareModel,
    GroupSplitShareModel,
    QAfterFilterCondition
  >
  shareWeightIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'shareWeight'),
      );
    });
  }

  QueryBuilder<
    GroupSplitShareModel,
    GroupSplitShareModel,
    QAfterFilterCondition
  >
  shareWeightEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'shareWeight', value: value),
      );
    });
  }

  QueryBuilder<
    GroupSplitShareModel,
    GroupSplitShareModel,
    QAfterFilterCondition
  >
  shareWeightGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'shareWeight',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    GroupSplitShareModel,
    GroupSplitShareModel,
    QAfterFilterCondition
  >
  shareWeightLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'shareWeight',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    GroupSplitShareModel,
    GroupSplitShareModel,
    QAfterFilterCondition
  >
  shareWeightBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'shareWeight',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension GroupSplitShareModelQueryObject
    on
        QueryBuilder<
          GroupSplitShareModel,
          GroupSplitShareModel,
          QFilterCondition
        > {}
