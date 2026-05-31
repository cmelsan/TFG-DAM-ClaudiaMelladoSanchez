// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'support_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SupportMessage _$SupportMessageFromJson(Map<String, dynamic> json) {
  return _SupportMessage.fromJson(json);
}

/// @nodoc
mixin _$SupportMessage {
  String get id => throw _privateConstructorUsedError;
  String get threadId => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  String get senderRole => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this SupportMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SupportMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SupportMessageCopyWith<SupportMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SupportMessageCopyWith<$Res> {
  factory $SupportMessageCopyWith(
    SupportMessage value,
    $Res Function(SupportMessage) then,
  ) = _$SupportMessageCopyWithImpl<$Res, SupportMessage>;
  @useResult
  $Res call({
    String id,
    String threadId,
    String senderId,
    String senderRole,
    String body,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$SupportMessageCopyWithImpl<$Res, $Val extends SupportMessage>
    implements $SupportMessageCopyWith<$Res> {
  _$SupportMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SupportMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? threadId = null,
    Object? senderId = null,
    Object? senderRole = null,
    Object? body = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            threadId: null == threadId
                ? _value.threadId
                : threadId // ignore: cast_nullable_to_non_nullable
                      as String,
            senderId: null == senderId
                ? _value.senderId
                : senderId // ignore: cast_nullable_to_non_nullable
                      as String,
            senderRole: null == senderRole
                ? _value.senderRole
                : senderRole // ignore: cast_nullable_to_non_nullable
                      as String,
            body: null == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$SupportMessageImplCopyWith<$Res>
    implements $SupportMessageCopyWith<$Res> {
  factory _$$SupportMessageImplCopyWith(
    _$SupportMessageImpl value,
    $Res Function(_$SupportMessageImpl) then,
  ) = __$$SupportMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String threadId,
    String senderId,
    String senderRole,
    String body,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$SupportMessageImplCopyWithImpl<$Res>
    extends _$SupportMessageCopyWithImpl<$Res, _$SupportMessageImpl>
    implements _$$SupportMessageImplCopyWith<$Res> {
  __$$SupportMessageImplCopyWithImpl(
    _$SupportMessageImpl _value,
    $Res Function(_$SupportMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SupportMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? threadId = null,
    Object? senderId = null,
    Object? senderRole = null,
    Object? body = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$SupportMessageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        threadId: null == threadId
            ? _value.threadId
            : threadId // ignore: cast_nullable_to_non_nullable
                  as String,
        senderId: null == senderId
            ? _value.senderId
            : senderId // ignore: cast_nullable_to_non_nullable
                  as String,
        senderRole: null == senderRole
            ? _value.senderRole
            : senderRole // ignore: cast_nullable_to_non_nullable
                  as String,
        body: null == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$SupportMessageImpl implements _SupportMessage {
  const _$SupportMessageImpl({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.senderRole,
    required this.body,
    this.createdAt,
  });

  factory _$SupportMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$SupportMessageImplFromJson(json);

  @override
  final String id;
  @override
  final String threadId;
  @override
  final String senderId;
  @override
  final String senderRole;
  @override
  final String body;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'SupportMessage(id: $id, threadId: $threadId, senderId: $senderId, senderRole: $senderRole, body: $body, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SupportMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.threadId, threadId) ||
                other.threadId == threadId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.senderRole, senderRole) ||
                other.senderRole == senderRole) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    threadId,
    senderId,
    senderRole,
    body,
    createdAt,
  );

  /// Create a copy of SupportMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SupportMessageImplCopyWith<_$SupportMessageImpl> get copyWith =>
      __$$SupportMessageImplCopyWithImpl<_$SupportMessageImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SupportMessageImplToJson(this);
  }
}

abstract class _SupportMessage implements SupportMessage {
  const factory _SupportMessage({
    required final String id,
    required final String threadId,
    required final String senderId,
    required final String senderRole,
    required final String body,
    final DateTime? createdAt,
  }) = _$SupportMessageImpl;

  factory _SupportMessage.fromJson(Map<String, dynamic> json) =
      _$SupportMessageImpl.fromJson;

  @override
  String get id;
  @override
  String get threadId;
  @override
  String get senderId;
  @override
  String get senderRole;
  @override
  String get body;
  @override
  DateTime? get createdAt;

  /// Create a copy of SupportMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SupportMessageImplCopyWith<_$SupportMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
