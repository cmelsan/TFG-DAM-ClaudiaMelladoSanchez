// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'business_config_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BusinessConfigItem _$BusinessConfigItemFromJson(Map<String, dynamic> json) {
  return _BusinessConfigItem.fromJson(json);
}

/// @nodoc
mixin _$BusinessConfigItem {
  String get id => throw _privateConstructorUsedError;
  String get key => throw _privateConstructorUsedError;
  String get value => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this BusinessConfigItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BusinessConfigItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BusinessConfigItemCopyWith<BusinessConfigItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BusinessConfigItemCopyWith<$Res> {
  factory $BusinessConfigItemCopyWith(
    BusinessConfigItem value,
    $Res Function(BusinessConfigItem) then,
  ) = _$BusinessConfigItemCopyWithImpl<$Res, BusinessConfigItem>;
  @useResult
  $Res call({String id, String key, String value, DateTime? updatedAt});
}

/// @nodoc
class _$BusinessConfigItemCopyWithImpl<$Res, $Val extends BusinessConfigItem>
    implements $BusinessConfigItemCopyWith<$Res> {
  _$BusinessConfigItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BusinessConfigItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? key = null,
    Object? value = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            key: null == key
                ? _value.key
                : key // ignore: cast_nullable_to_non_nullable
                      as String,
            value: null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as String,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BusinessConfigItemImplCopyWith<$Res>
    implements $BusinessConfigItemCopyWith<$Res> {
  factory _$$BusinessConfigItemImplCopyWith(
    _$BusinessConfigItemImpl value,
    $Res Function(_$BusinessConfigItemImpl) then,
  ) = __$$BusinessConfigItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String key, String value, DateTime? updatedAt});
}

/// @nodoc
class __$$BusinessConfigItemImplCopyWithImpl<$Res>
    extends _$BusinessConfigItemCopyWithImpl<$Res, _$BusinessConfigItemImpl>
    implements _$$BusinessConfigItemImplCopyWith<$Res> {
  __$$BusinessConfigItemImplCopyWithImpl(
    _$BusinessConfigItemImpl _value,
    $Res Function(_$BusinessConfigItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BusinessConfigItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? key = null,
    Object? value = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$BusinessConfigItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        key: null == key
            ? _value.key
            : key // ignore: cast_nullable_to_non_nullable
                  as String,
        value: null == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as String,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$BusinessConfigItemImpl implements _BusinessConfigItem {
  const _$BusinessConfigItemImpl({
    required this.id,
    required this.key,
    required this.value,
    this.updatedAt,
  });

  factory _$BusinessConfigItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$BusinessConfigItemImplFromJson(json);

  @override
  final String id;
  @override
  final String key;
  @override
  final String value;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'BusinessConfigItem(id: $id, key: $key, value: $value, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BusinessConfigItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, key, value, updatedAt);

  /// Create a copy of BusinessConfigItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BusinessConfigItemImplCopyWith<_$BusinessConfigItemImpl> get copyWith =>
      __$$BusinessConfigItemImplCopyWithImpl<_$BusinessConfigItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BusinessConfigItemImplToJson(this);
  }
}

abstract class _BusinessConfigItem implements BusinessConfigItem {
  const factory _BusinessConfigItem({
    required final String id,
    required final String key,
    required final String value,
    final DateTime? updatedAt,
  }) = _$BusinessConfigItemImpl;

  factory _BusinessConfigItem.fromJson(Map<String, dynamic> json) =
      _$BusinessConfigItemImpl.fromJson;

  @override
  String get id;
  @override
  String get key;
  @override
  String get value;
  @override
  DateTime? get updatedAt;

  /// Create a copy of BusinessConfigItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BusinessConfigItemImplCopyWith<_$BusinessConfigItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
