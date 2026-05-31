// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'newsletter_subscriber.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NewsletterSubscriber _$NewsletterSubscriberFromJson(Map<String, dynamic> json) {
  return _NewsletterSubscriber.fromJson(json);
}

/// @nodoc
mixin _$NewsletterSubscriber {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // active | unsubscribed | bounced
  String get source =>
      throw _privateConstructorUsedError; // web | admin | api | …
  String get locale => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get fullName => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  DateTime? get unsubscribedAt => throw _privateConstructorUsedError;

  /// Serializes this NewsletterSubscriber to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NewsletterSubscriber
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NewsletterSubscriberCopyWith<NewsletterSubscriber> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NewsletterSubscriberCopyWith<$Res> {
  factory $NewsletterSubscriberCopyWith(
    NewsletterSubscriber value,
    $Res Function(NewsletterSubscriber) then,
  ) = _$NewsletterSubscriberCopyWithImpl<$Res, NewsletterSubscriber>;
  @useResult
  $Res call({
    String id,
    String email,
    String status,
    String source,
    String locale,
    DateTime createdAt,
    String? fullName,
    String? userId,
    DateTime? unsubscribedAt,
  });
}

/// @nodoc
class _$NewsletterSubscriberCopyWithImpl<
  $Res,
  $Val extends NewsletterSubscriber
>
    implements $NewsletterSubscriberCopyWith<$Res> {
  _$NewsletterSubscriberCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NewsletterSubscriber
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? status = null,
    Object? source = null,
    Object? locale = null,
    Object? createdAt = null,
    Object? fullName = freezed,
    Object? userId = freezed,
    Object? unsubscribedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String,
            locale: null == locale
                ? _value.locale
                : locale // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            fullName: freezed == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String?,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String?,
            unsubscribedAt: freezed == unsubscribedAt
                ? _value.unsubscribedAt
                : unsubscribedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NewsletterSubscriberImplCopyWith<$Res>
    implements $NewsletterSubscriberCopyWith<$Res> {
  factory _$$NewsletterSubscriberImplCopyWith(
    _$NewsletterSubscriberImpl value,
    $Res Function(_$NewsletterSubscriberImpl) then,
  ) = __$$NewsletterSubscriberImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String email,
    String status,
    String source,
    String locale,
    DateTime createdAt,
    String? fullName,
    String? userId,
    DateTime? unsubscribedAt,
  });
}

/// @nodoc
class __$$NewsletterSubscriberImplCopyWithImpl<$Res>
    extends _$NewsletterSubscriberCopyWithImpl<$Res, _$NewsletterSubscriberImpl>
    implements _$$NewsletterSubscriberImplCopyWith<$Res> {
  __$$NewsletterSubscriberImplCopyWithImpl(
    _$NewsletterSubscriberImpl _value,
    $Res Function(_$NewsletterSubscriberImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NewsletterSubscriber
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? status = null,
    Object? source = null,
    Object? locale = null,
    Object? createdAt = null,
    Object? fullName = freezed,
    Object? userId = freezed,
    Object? unsubscribedAt = freezed,
  }) {
    return _then(
      _$NewsletterSubscriberImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String,
        locale: null == locale
            ? _value.locale
            : locale // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        fullName: freezed == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String?,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
        unsubscribedAt: freezed == unsubscribedAt
            ? _value.unsubscribedAt
            : unsubscribedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$NewsletterSubscriberImpl implements _NewsletterSubscriber {
  const _$NewsletterSubscriberImpl({
    required this.id,
    required this.email,
    required this.status,
    required this.source,
    required this.locale,
    required this.createdAt,
    this.fullName,
    this.userId,
    this.unsubscribedAt,
  });

  factory _$NewsletterSubscriberImpl.fromJson(Map<String, dynamic> json) =>
      _$$NewsletterSubscriberImplFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  final String status;
  // active | unsubscribed | bounced
  @override
  final String source;
  // web | admin | api | …
  @override
  final String locale;
  @override
  final DateTime createdAt;
  @override
  final String? fullName;
  @override
  final String? userId;
  @override
  final DateTime? unsubscribedAt;

  @override
  String toString() {
    return 'NewsletterSubscriber(id: $id, email: $email, status: $status, source: $source, locale: $locale, createdAt: $createdAt, fullName: $fullName, userId: $userId, unsubscribedAt: $unsubscribedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NewsletterSubscriberImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.locale, locale) || other.locale == locale) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.unsubscribedAt, unsubscribedAt) ||
                other.unsubscribedAt == unsubscribedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    email,
    status,
    source,
    locale,
    createdAt,
    fullName,
    userId,
    unsubscribedAt,
  );

  /// Create a copy of NewsletterSubscriber
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NewsletterSubscriberImplCopyWith<_$NewsletterSubscriberImpl>
  get copyWith =>
      __$$NewsletterSubscriberImplCopyWithImpl<_$NewsletterSubscriberImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$NewsletterSubscriberImplToJson(this);
  }
}

abstract class _NewsletterSubscriber implements NewsletterSubscriber {
  const factory _NewsletterSubscriber({
    required final String id,
    required final String email,
    required final String status,
    required final String source,
    required final String locale,
    required final DateTime createdAt,
    final String? fullName,
    final String? userId,
    final DateTime? unsubscribedAt,
  }) = _$NewsletterSubscriberImpl;

  factory _NewsletterSubscriber.fromJson(Map<String, dynamic> json) =
      _$NewsletterSubscriberImpl.fromJson;

  @override
  String get id;
  @override
  String get email;
  @override
  String get status; // active | unsubscribed | bounced
  @override
  String get source; // web | admin | api | …
  @override
  String get locale;
  @override
  DateTime get createdAt;
  @override
  String? get fullName;
  @override
  String? get userId;
  @override
  DateTime? get unsubscribedAt;

  /// Create a copy of NewsletterSubscriber
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NewsletterSubscriberImplCopyWith<_$NewsletterSubscriberImpl>
  get copyWith => throw _privateConstructorUsedError;
}
