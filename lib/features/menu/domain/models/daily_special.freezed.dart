// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_special.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DailySpecial _$DailySpecialFromJson(Map<String, dynamic> json) {
  return _DailySpecial.fromJson(json);
}

/// @nodoc
mixin _$DailySpecial {
  String get id => throw _privateConstructorUsedError;
  String get dishId => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  int? get discountPercent => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this DailySpecial to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailySpecial
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailySpecialCopyWith<DailySpecial> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailySpecialCopyWith<$Res> {
  factory $DailySpecialCopyWith(
    DailySpecial value,
    $Res Function(DailySpecial) then,
  ) = _$DailySpecialCopyWithImpl<$Res, DailySpecial>;
  @useResult
  $Res call({
    String id,
    String dishId,
    DateTime date,
    int? discountPercent,
    String? note,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$DailySpecialCopyWithImpl<$Res, $Val extends DailySpecial>
    implements $DailySpecialCopyWith<$Res> {
  _$DailySpecialCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailySpecial
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dishId = null,
    Object? date = null,
    Object? discountPercent = freezed,
    Object? note = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            dishId: null == dishId
                ? _value.dishId
                : dishId // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            discountPercent: freezed == discountPercent
                ? _value.discountPercent
                : discountPercent // ignore: cast_nullable_to_non_nullable
                      as int?,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailySpecialImplCopyWith<$Res>
    implements $DailySpecialCopyWith<$Res> {
  factory _$$DailySpecialImplCopyWith(
    _$DailySpecialImpl value,
    $Res Function(_$DailySpecialImpl) then,
  ) = __$$DailySpecialImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String dishId,
    DateTime date,
    int? discountPercent,
    String? note,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$DailySpecialImplCopyWithImpl<$Res>
    extends _$DailySpecialCopyWithImpl<$Res, _$DailySpecialImpl>
    implements _$$DailySpecialImplCopyWith<$Res> {
  __$$DailySpecialImplCopyWithImpl(
    _$DailySpecialImpl _value,
    $Res Function(_$DailySpecialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailySpecial
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dishId = null,
    Object? date = null,
    Object? discountPercent = freezed,
    Object? note = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$DailySpecialImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        dishId: null == dishId
            ? _value.dishId
            : dishId // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        discountPercent: freezed == discountPercent
            ? _value.discountPercent
            : discountPercent // ignore: cast_nullable_to_non_nullable
                  as int?,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DailySpecialImpl implements _DailySpecial {
  const _$DailySpecialImpl({
    required this.id,
    required this.dishId,
    required this.date,
    this.discountPercent,
    this.note,
    this.createdAt,
  });

  factory _$DailySpecialImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailySpecialImplFromJson(json);

  @override
  final String id;
  @override
  final String dishId;
  @override
  final DateTime date;
  @override
  final int? discountPercent;
  @override
  final String? note;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'DailySpecial(id: $id, dishId: $dishId, date: $date, discountPercent: $discountPercent, note: $note, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailySpecialImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.dishId, dishId) || other.dishId == dishId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.discountPercent, discountPercent) ||
                other.discountPercent == discountPercent) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    dishId,
    date,
    discountPercent,
    note,
    createdAt,
  );

  /// Create a copy of DailySpecial
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailySpecialImplCopyWith<_$DailySpecialImpl> get copyWith =>
      __$$DailySpecialImplCopyWithImpl<_$DailySpecialImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailySpecialImplToJson(this);
  }
}

abstract class _DailySpecial implements DailySpecial {
  const factory _DailySpecial({
    required final String id,
    required final String dishId,
    required final DateTime date,
    final int? discountPercent,
    final String? note,
    final DateTime? createdAt,
  }) = _$DailySpecialImpl;

  factory _DailySpecial.fromJson(Map<String, dynamic> json) =
      _$DailySpecialImpl.fromJson;

  @override
  String get id;
  @override
  String get dishId;
  @override
  DateTime get date;
  @override
  int? get discountPercent;
  @override
  String? get note;
  @override
  DateTime? get createdAt;

  /// Create a copy of DailySpecial
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailySpecialImplCopyWith<_$DailySpecialImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
