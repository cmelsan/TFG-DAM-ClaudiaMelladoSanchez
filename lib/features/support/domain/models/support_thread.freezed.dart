// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'support_thread.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SupportThread _$SupportThreadFromJson(Map<String, dynamic> json) {
  return _SupportThread.fromJson(json);
}

/// @nodoc
mixin _$SupportThread {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get subject => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  int get unreadForAdmin => throw _privateConstructorUsedError;
  int get unreadForCustomer => throw _privateConstructorUsedError;
  DateTime? get lastMessageAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  String? get lastMessage => throw _privateConstructorUsedError;
  String? get userFullName => throw _privateConstructorUsedError;
  String? get userEmail => throw _privateConstructorUsedError;

  /// Serializes this SupportThread to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SupportThread
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SupportThreadCopyWith<SupportThread> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SupportThreadCopyWith<$Res> {
  factory $SupportThreadCopyWith(
    SupportThread value,
    $Res Function(SupportThread) then,
  ) = _$SupportThreadCopyWithImpl<$Res, SupportThread>;
  @useResult
  $Res call({
    String id,
    String userId,
    String subject,
    String category,
    String status,
    int unreadForAdmin,
    int unreadForCustomer,
    DateTime? lastMessageAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lastMessage,
    String? userFullName,
    String? userEmail,
  });
}

/// @nodoc
class _$SupportThreadCopyWithImpl<$Res, $Val extends SupportThread>
    implements $SupportThreadCopyWith<$Res> {
  _$SupportThreadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SupportThread
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? subject = null,
    Object? category = null,
    Object? status = null,
    Object? unreadForAdmin = null,
    Object? unreadForCustomer = null,
    Object? lastMessageAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? lastMessage = freezed,
    Object? userFullName = freezed,
    Object? userEmail = freezed,
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
            subject: null == subject
                ? _value.subject
                : subject // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            unreadForAdmin: null == unreadForAdmin
                ? _value.unreadForAdmin
                : unreadForAdmin // ignore: cast_nullable_to_non_nullable
                      as int,
            unreadForCustomer: null == unreadForCustomer
                ? _value.unreadForCustomer
                : unreadForCustomer // ignore: cast_nullable_to_non_nullable
                      as int,
            lastMessageAt: freezed == lastMessageAt
                ? _value.lastMessageAt
                : lastMessageAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            lastMessage: freezed == lastMessage
                ? _value.lastMessage
                : lastMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            userFullName: freezed == userFullName
                ? _value.userFullName
                : userFullName // ignore: cast_nullable_to_non_nullable
                      as String?,
            userEmail: freezed == userEmail
                ? _value.userEmail
                : userEmail // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SupportThreadImplCopyWith<$Res>
    implements $SupportThreadCopyWith<$Res> {
  factory _$$SupportThreadImplCopyWith(
    _$SupportThreadImpl value,
    $Res Function(_$SupportThreadImpl) then,
  ) = __$$SupportThreadImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String subject,
    String category,
    String status,
    int unreadForAdmin,
    int unreadForCustomer,
    DateTime? lastMessageAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lastMessage,
    String? userFullName,
    String? userEmail,
  });
}

/// @nodoc
class __$$SupportThreadImplCopyWithImpl<$Res>
    extends _$SupportThreadCopyWithImpl<$Res, _$SupportThreadImpl>
    implements _$$SupportThreadImplCopyWith<$Res> {
  __$$SupportThreadImplCopyWithImpl(
    _$SupportThreadImpl _value,
    $Res Function(_$SupportThreadImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SupportThread
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? subject = null,
    Object? category = null,
    Object? status = null,
    Object? unreadForAdmin = null,
    Object? unreadForCustomer = null,
    Object? lastMessageAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? lastMessage = freezed,
    Object? userFullName = freezed,
    Object? userEmail = freezed,
  }) {
    return _then(
      _$SupportThreadImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        subject: null == subject
            ? _value.subject
            : subject // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        unreadForAdmin: null == unreadForAdmin
            ? _value.unreadForAdmin
            : unreadForAdmin // ignore: cast_nullable_to_non_nullable
                  as int,
        unreadForCustomer: null == unreadForCustomer
            ? _value.unreadForCustomer
            : unreadForCustomer // ignore: cast_nullable_to_non_nullable
                  as int,
        lastMessageAt: freezed == lastMessageAt
            ? _value.lastMessageAt
            : lastMessageAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        lastMessage: freezed == lastMessage
            ? _value.lastMessage
            : lastMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        userFullName: freezed == userFullName
            ? _value.userFullName
            : userFullName // ignore: cast_nullable_to_non_nullable
                  as String?,
        userEmail: freezed == userEmail
            ? _value.userEmail
            : userEmail // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$SupportThreadImpl implements _SupportThread {
  const _$SupportThreadImpl({
    required this.id,
    required this.userId,
    required this.subject,
    required this.category,
    required this.status,
    required this.unreadForAdmin,
    required this.unreadForCustomer,
    this.lastMessageAt,
    this.createdAt,
    this.updatedAt,
    this.lastMessage,
    this.userFullName,
    this.userEmail,
  });

  factory _$SupportThreadImpl.fromJson(Map<String, dynamic> json) =>
      _$$SupportThreadImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String subject;
  @override
  final String category;
  @override
  final String status;
  @override
  final int unreadForAdmin;
  @override
  final int unreadForCustomer;
  @override
  final DateTime? lastMessageAt;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final String? lastMessage;
  @override
  final String? userFullName;
  @override
  final String? userEmail;

  @override
  String toString() {
    return 'SupportThread(id: $id, userId: $userId, subject: $subject, category: $category, status: $status, unreadForAdmin: $unreadForAdmin, unreadForCustomer: $unreadForCustomer, lastMessageAt: $lastMessageAt, createdAt: $createdAt, updatedAt: $updatedAt, lastMessage: $lastMessage, userFullName: $userFullName, userEmail: $userEmail)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SupportThreadImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.unreadForAdmin, unreadForAdmin) ||
                other.unreadForAdmin == unreadForAdmin) &&
            (identical(other.unreadForCustomer, unreadForCustomer) ||
                other.unreadForCustomer == unreadForCustomer) &&
            (identical(other.lastMessageAt, lastMessageAt) ||
                other.lastMessageAt == lastMessageAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage) &&
            (identical(other.userFullName, userFullName) ||
                other.userFullName == userFullName) &&
            (identical(other.userEmail, userEmail) ||
                other.userEmail == userEmail));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    subject,
    category,
    status,
    unreadForAdmin,
    unreadForCustomer,
    lastMessageAt,
    createdAt,
    updatedAt,
    lastMessage,
    userFullName,
    userEmail,
  );

  /// Create a copy of SupportThread
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SupportThreadImplCopyWith<_$SupportThreadImpl> get copyWith =>
      __$$SupportThreadImplCopyWithImpl<_$SupportThreadImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SupportThreadImplToJson(this);
  }
}

abstract class _SupportThread implements SupportThread {
  const factory _SupportThread({
    required final String id,
    required final String userId,
    required final String subject,
    required final String category,
    required final String status,
    required final int unreadForAdmin,
    required final int unreadForCustomer,
    final DateTime? lastMessageAt,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    final String? lastMessage,
    final String? userFullName,
    final String? userEmail,
  }) = _$SupportThreadImpl;

  factory _SupportThread.fromJson(Map<String, dynamic> json) =
      _$SupportThreadImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get subject;
  @override
  String get category;
  @override
  String get status;
  @override
  int get unreadForAdmin;
  @override
  int get unreadForCustomer;
  @override
  DateTime? get lastMessageAt;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  String? get lastMessage;
  @override
  String? get userFullName;
  @override
  String? get userEmail;

  /// Create a copy of SupportThread
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SupportThreadImplCopyWith<_$SupportThreadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
