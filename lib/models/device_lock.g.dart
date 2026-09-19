// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_lock.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDeviceLockCollection on Isar {
  IsarCollection<DeviceLock> get deviceLocks => this.collection();
}

const DeviceLockSchema = CollectionSchema(
  name: r'DeviceLock',
  id: 4094593153363828161,
  properties: {
    r'activationToken': PropertySchema(
      id: 0,
      name: r'activationToken',
      type: IsarType.string,
    ),
    r'hardwareSignature': PropertySchema(
      id: 1,
      name: r'hardwareSignature',
      type: IsarType.string,
    ),
    r'isActivated': PropertySchema(
      id: 2,
      name: r'isActivated',
      type: IsarType.bool,
    )
  },
  estimateSize: _deviceLockEstimateSize,
  serialize: _deviceLockSerialize,
  deserialize: _deviceLockDeserialize,
  deserializeProp: _deviceLockDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _deviceLockGetId,
  getLinks: _deviceLockGetLinks,
  attach: _deviceLockAttach,
  version: '3.1.0+1',
);

int _deviceLockEstimateSize(
  DeviceLock object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.activationToken;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.hardwareSignature.length * 3;
  return bytesCount;
}

void _deviceLockSerialize(
  DeviceLock object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.activationToken);
  writer.writeString(offsets[1], object.hardwareSignature);
  writer.writeBool(offsets[2], object.isActivated);
}

DeviceLock _deviceLockDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DeviceLock();
  object.activationToken = reader.readStringOrNull(offsets[0]);
  object.hardwareSignature = reader.readString(offsets[1]);
  object.id = id;
  object.isActivated = reader.readBool(offsets[2]);
  return object;
}

P _deviceLockDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _deviceLockGetId(DeviceLock object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _deviceLockGetLinks(DeviceLock object) {
  return [];
}

void _deviceLockAttach(IsarCollection<dynamic> col, Id id, DeviceLock object) {
  object.id = id;
}

extension DeviceLockQueryWhereSort
    on QueryBuilder<DeviceLock, DeviceLock, QWhere> {
  QueryBuilder<DeviceLock, DeviceLock, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DeviceLockQueryWhere
    on QueryBuilder<DeviceLock, DeviceLock, QWhereClause> {
  QueryBuilder<DeviceLock, DeviceLock, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<DeviceLock, DeviceLock, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DeviceLockQueryFilter
    on QueryBuilder<DeviceLock, DeviceLock, QFilterCondition> {
  QueryBuilder<DeviceLock, DeviceLock, QAfterFilterCondition>
      activationTokenIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'activationToken',
      ));
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterFilterCondition>
      activationTokenIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'activationToken',
      ));
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterFilterCondition>
      activationTokenEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activationToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterFilterCondition>
      activationTokenGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activationToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterFilterCondition>
      activationTokenLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activationToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterFilterCondition>
      activationTokenBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activationToken',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterFilterCondition>
      activationTokenStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'activationToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterFilterCondition>
      activationTokenEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'activationToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterFilterCondition>
      activationTokenContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'activationToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterFilterCondition>
      activationTokenMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'activationToken',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterFilterCondition>
      activationTokenIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activationToken',
        value: '',
      ));
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterFilterCondition>
      activationTokenIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'activationToken',
        value: '',
      ));
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterFilterCondition>
      hardwareSignatureEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hardwareSignature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterFilterCondition>
      hardwareSignatureGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hardwareSignature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterFilterCondition>
      hardwareSignatureLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hardwareSignature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterFilterCondition>
      hardwareSignatureBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hardwareSignature',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterFilterCondition>
      hardwareSignatureStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'hardwareSignature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterFilterCondition>
      hardwareSignatureEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'hardwareSignature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterFilterCondition>
      hardwareSignatureContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'hardwareSignature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterFilterCondition>
      hardwareSignatureMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'hardwareSignature',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterFilterCondition>
      hardwareSignatureIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hardwareSignature',
        value: '',
      ));
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterFilterCondition>
      hardwareSignatureIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'hardwareSignature',
        value: '',
      ));
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterFilterCondition>
      isActivatedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActivated',
        value: value,
      ));
    });
  }
}

extension DeviceLockQueryObject
    on QueryBuilder<DeviceLock, DeviceLock, QFilterCondition> {}

extension DeviceLockQueryLinks
    on QueryBuilder<DeviceLock, DeviceLock, QFilterCondition> {}

extension DeviceLockQuerySortBy
    on QueryBuilder<DeviceLock, DeviceLock, QSortBy> {
  QueryBuilder<DeviceLock, DeviceLock, QAfterSortBy> sortByActivationToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activationToken', Sort.asc);
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterSortBy>
      sortByActivationTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activationToken', Sort.desc);
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterSortBy> sortByHardwareSignature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hardwareSignature', Sort.asc);
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterSortBy>
      sortByHardwareSignatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hardwareSignature', Sort.desc);
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterSortBy> sortByIsActivated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActivated', Sort.asc);
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterSortBy> sortByIsActivatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActivated', Sort.desc);
    });
  }
}

extension DeviceLockQuerySortThenBy
    on QueryBuilder<DeviceLock, DeviceLock, QSortThenBy> {
  QueryBuilder<DeviceLock, DeviceLock, QAfterSortBy> thenByActivationToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activationToken', Sort.asc);
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterSortBy>
      thenByActivationTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activationToken', Sort.desc);
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterSortBy> thenByHardwareSignature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hardwareSignature', Sort.asc);
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterSortBy>
      thenByHardwareSignatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hardwareSignature', Sort.desc);
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterSortBy> thenByIsActivated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActivated', Sort.asc);
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QAfterSortBy> thenByIsActivatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActivated', Sort.desc);
    });
  }
}

extension DeviceLockQueryWhereDistinct
    on QueryBuilder<DeviceLock, DeviceLock, QDistinct> {
  QueryBuilder<DeviceLock, DeviceLock, QDistinct> distinctByActivationToken(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activationToken',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QDistinct> distinctByHardwareSignature(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hardwareSignature',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DeviceLock, DeviceLock, QDistinct> distinctByIsActivated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActivated');
    });
  }
}

extension DeviceLockQueryProperty
    on QueryBuilder<DeviceLock, DeviceLock, QQueryProperty> {
  QueryBuilder<DeviceLock, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DeviceLock, String?, QQueryOperations>
      activationTokenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activationToken');
    });
  }

  QueryBuilder<DeviceLock, String, QQueryOperations>
      hardwareSignatureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hardwareSignature');
    });
  }

  QueryBuilder<DeviceLock, bool, QQueryOperations> isActivatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActivated');
    });
  }
}
