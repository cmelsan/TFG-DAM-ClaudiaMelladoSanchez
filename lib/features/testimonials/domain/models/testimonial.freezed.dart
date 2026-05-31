// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'testimonial.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Testimonial _$TestimonialFromJson(Map<String, dynamic> json) {
  return _Testimonial.fromJson(json);
}

/// @nodoc
mixin _$Testimonial {
  String get id => throw _privateConstructorUsedError;
  String get authorName => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  int get rating => throw _privateConstructorUsedError;
  bool get isFeatured => throw _privateConstructorUsedError;
  int get position => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Testimonial to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Testimonial
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TestimonialCopyWith<Testimonial> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TestimonialCopyWith<$Res> {
  factory $TestimonialCopyWith(
    Testimonial value,
    $Res Function(Testimonial) then,
  ) = _$TestimonialCopyWithImpl<$Res, Testimonial>;
  @useResult
  $Res call({
    String id,
    String authorName,
    String body,
    int rating,
    bool isFeatured,
    int position,
    DateTime createdAt,
  });
}

/// @nodoc
class _$TestimonialCopyWithImpl<$Res, $Val extends Testimonial>
    implements $TestimonialCopyWith<$Res> {
  _$TestimonialCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Testimonial
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? authorName = null,
    Object? body = null,
    Object? rating = null,
    Object? isFeatured = null,
    Object? position = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            authorName: null == authorName
                ? _value.authorName
                : authorName // ignore: cast_nullable_to_non_nullable
                      as String,
            body: null == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String,
            rating: null == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as int,
            isFeatured: null == isFeatured
                ? _value.isFeatured
                : isFeatured // ignore: cast_nullable_to_non_nullable
                      as bool,
            position: null == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TestimonialImplCopyWith<$Res>
    implements $TestimonialCopyWith<$Res> {
  factory _$$TestimonialImplCopyWith(
    _$TestimonialImpl value,
    $Res Function(_$TestimonialImpl) then,
  ) = __$$TestimonialImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String authorName,
    String body,
    int rating,
    bool isFeatured,
    int position,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$TestimonialImplCopyWithImpl<$Res>
    extends _$TestimonialCopyWithImpl<$Res, _$TestimonialImpl>
    implements _$$TestimonialImplCopyWith<$Res> {
  __$$TestimonialImplCopyWithImpl(
    _$TestimonialImpl _value,
    $Res Function(_$TestimonialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Testimonial
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? authorName = null,
    Object? body = null,
    Object? rating = null,
    Object? isFeatured = null,
    Object? position = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$TestimonialImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        authorName: null == authorName
            ? _value.authorName
            : authorName // ignore: cast_nullable_to_non_nullable
                  as String,
        body: null == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String,
        rating: null == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as int,
        isFeatured: null == isFeatured
            ? _value.isFeatured
            : isFeatured // ignore: cast_nullable_to_non_nullable
                  as bool,
        position: null == position
            ? _value.position
            : position // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$TestimonialImpl implements _Testimonial {
  const _$TestimonialImpl({
    required this.id,
    required this.authorName,
    required this.body,
    required this.rating,
    required this.isFeatured,
    required this.position,
    required this.createdAt,
  });

  factory _$TestimonialImpl.fromJson(Map<String, dynamic> json) =>
      _$$TestimonialImplFromJson(json);

  @override
  final String id;
  @override
  final String authorName;
  @override
  final String body;
  @override
  final int rating;
  @override
  final bool isFeatured;
  @override
  final int position;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'Testimonial(id: $id, authorName: $authorName, body: $body, rating: $rating, isFeatured: $isFeatured, position: $position, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TestimonialImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.isFeatured, isFeatured) ||
                other.isFeatured == isFeatured) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    authorName,
    body,
    rating,
    isFeatured,
    position,
    createdAt,
  );

  /// Create a copy of Testimonial
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TestimonialImplCopyWith<_$TestimonialImpl> get copyWith =>
      __$$TestimonialImplCopyWithImpl<_$TestimonialImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TestimonialImplToJson(this);
  }
}

abstract class _Testimonial implements Testimonial {
  const factory _Testimonial({
    required final String id,
    required final String authorName,
    required final String body,
    required final int rating,
    required final bool isFeatured,
    required final int position,
    required final DateTime createdAt,
  }) = _$TestimonialImpl;

  factory _Testimonial.fromJson(Map<String, dynamic> json) =
      _$TestimonialImpl.fromJson;

  @override
  String get id;
  @override
  String get authorName;
  @override
  String get body;
  @override
  int get rating;
  @override
  bool get isFeatured;
  @override
  int get position;
  @override
  DateTime get createdAt;

  /// Create a copy of Testimonial
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TestimonialImplCopyWith<_$TestimonialImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
