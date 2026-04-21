// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_event_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AdminEventRequest _$AdminEventRequestFromJson(Map<String, dynamic> json) {
  return _AdminEventRequest.fromJson(json);
}

/// @nodoc
mixin _$AdminEventRequest {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  DateTime get eventDate => throw _privateConstructorUsedError;
  int get guestCount => throw _privateConstructorUsedError;
  String get location => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  double? get quotedTotal => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this AdminEventRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AdminEventRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminEventRequestCopyWith<AdminEventRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminEventRequestCopyWith<$Res> {
  factory $AdminEventRequestCopyWith(
    AdminEventRequest value,
    $Res Function(AdminEventRequest) then,
  ) = _$AdminEventRequestCopyWithImpl<$Res, AdminEventRequest>;
  @useResult
  $Res call({
    String id,
    String userId,
    DateTime eventDate,
    int guestCount,
    String location,
    String status,
    String? notes,
    double? quotedTotal,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$AdminEventRequestCopyWithImpl<$Res, $Val extends AdminEventRequest>
    implements $AdminEventRequestCopyWith<$Res> {
  _$AdminEventRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdminEventRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? eventDate = null,
    Object? guestCount = null,
    Object? location = null,
    Object? status = null,
    Object? notes = freezed,
    Object? quotedTotal = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            eventDate: null == eventDate
                ? _value.eventDate
                : eventDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            guestCount: null == guestCount
                ? _value.guestCount
                : guestCount // ignore: cast_nullable_to_non_nullable
                      as int,
            location: null == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            quotedTotal: freezed == quotedTotal
                ? _value.quotedTotal
                : quotedTotal // ignore: cast_nullable_to_non_nullable
                      as double?,
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
abstract class _$$AdminEventRequestImplCopyWith<$Res>
    implements $AdminEventRequestCopyWith<$Res> {
  factory _$$AdminEventRequestImplCopyWith(
    _$AdminEventRequestImpl value,
    $Res Function(_$AdminEventRequestImpl) then,
  ) = __$$AdminEventRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    DateTime eventDate,
    int guestCount,
    String location,
    String status,
    String? notes,
    double? quotedTotal,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$AdminEventRequestImplCopyWithImpl<$Res>
    extends _$AdminEventRequestCopyWithImpl<$Res, _$AdminEventRequestImpl>
    implements _$$AdminEventRequestImplCopyWith<$Res> {
  __$$AdminEventRequestImplCopyWithImpl(
    _$AdminEventRequestImpl _value,
    $Res Function(_$AdminEventRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AdminEventRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? eventDate = null,
    Object? guestCount = null,
    Object? location = null,
    Object? status = null,
    Object? notes = freezed,
    Object? quotedTotal = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$AdminEventRequestImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        eventDate: null == eventDate
            ? _value.eventDate
            : eventDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        guestCount: null == guestCount
            ? _value.guestCount
            : guestCount // ignore: cast_nullable_to_non_nullable
                  as int,
        location: null == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        quotedTotal: freezed == quotedTotal
            ? _value.quotedTotal
            : quotedTotal // ignore: cast_nullable_to_non_nullable
                  as double?,
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
class _$AdminEventRequestImpl implements _AdminEventRequest {
  const _$AdminEventRequestImpl({
    required this.id,
    required this.userId,
    required this.eventDate,
    required this.guestCount,
    required this.location,
    required this.status,
    this.notes,
    this.quotedTotal,
    this.createdAt,
  });

  factory _$AdminEventRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdminEventRequestImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final DateTime eventDate;
  @override
  final int guestCount;
  @override
  final String location;
  @override
  final String status;
  @override
  final String? notes;
  @override
  final double? quotedTotal;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'AdminEventRequest(id: $id, userId: $userId, eventDate: $eventDate, guestCount: $guestCount, location: $location, status: $status, notes: $notes, quotedTotal: $quotedTotal, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminEventRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.eventDate, eventDate) ||
                other.eventDate == eventDate) &&
            (identical(other.guestCount, guestCount) ||
                other.guestCount == guestCount) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.quotedTotal, quotedTotal) ||
                other.quotedTotal == quotedTotal) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    eventDate,
    guestCount,
    location,
    status,
    notes,
    quotedTotal,
    createdAt,
  );

  /// Create a copy of AdminEventRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminEventRequestImplCopyWith<_$AdminEventRequestImpl> get copyWith =>
      __$$AdminEventRequestImplCopyWithImpl<_$AdminEventRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AdminEventRequestImplToJson(this);
  }
}

abstract class _AdminEventRequest implements AdminEventRequest {
  const factory _AdminEventRequest({
    required final String id,
    required final String userId,
    required final DateTime eventDate,
    required final int guestCount,
    required final String location,
    required final String status,
    final String? notes,
    final double? quotedTotal,
    final DateTime? createdAt,
  }) = _$AdminEventRequestImpl;

  factory _AdminEventRequest.fromJson(Map<String, dynamic> json) =
      _$AdminEventRequestImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  DateTime get eventDate;
  @override
  int get guestCount;
  @override
  String get location;
  @override
  String get status;
  @override
  String? get notes;
  @override
  double? get quotedTotal;
  @override
  DateTime? get createdAt;

  /// Create a copy of AdminEventRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminEventRequestImplCopyWith<_$AdminEventRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
