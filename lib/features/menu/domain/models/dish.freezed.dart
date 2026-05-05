// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dish.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Dish _$DishFromJson(Map<String, dynamic> json) {
  return _Dish.fromJson(json);
}

/// @nodoc
mixin _$Dish {
  String get id => throw _privateConstructorUsedError;
  String get categoryId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  List<String> get allergens => throw _privateConstructorUsedError;
  int get prepTimeMin => throw _privateConstructorUsedError;
  bool get isAvailable => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  bool get isOffer => throw _privateConstructorUsedError;
  bool get isSeasonal => throw _privateConstructorUsedError;
  double? get offerPrice => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Dish to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Dish
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DishCopyWith<Dish> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DishCopyWith<$Res> {
  factory $DishCopyWith(Dish value, $Res Function(Dish) then) =
      _$DishCopyWithImpl<$Res, Dish>;
  @useResult
  $Res call({
    String id,
    String categoryId,
    String name,
    double price,
    String description,
    String? imageUrl,
    List<String> allergens,
    int prepTimeMin,
    bool isAvailable,
    bool isActive,
    bool isOffer,
    bool isSeasonal,
    double? offerPrice,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$DishCopyWithImpl<$Res, $Val extends Dish>
    implements $DishCopyWith<$Res> {
  _$DishCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Dish
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? categoryId = null,
    Object? name = null,
    Object? price = null,
    Object? description = null,
    Object? imageUrl = freezed,
    Object? allergens = null,
    Object? prepTimeMin = null,
    Object? isAvailable = null,
    Object? isActive = null,
    Object? isOffer = null,
    Object? isSeasonal = null,
    Object? offerPrice = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            categoryId: null == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            allergens: null == allergens
                ? _value.allergens
                : allergens // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            prepTimeMin: null == prepTimeMin
                ? _value.prepTimeMin
                : prepTimeMin // ignore: cast_nullable_to_non_nullable
                      as int,
            isAvailable: null == isAvailable
                ? _value.isAvailable
                : isAvailable // ignore: cast_nullable_to_non_nullable
                      as bool,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            isOffer: null == isOffer
                ? _value.isOffer
                : isOffer // ignore: cast_nullable_to_non_nullable
                      as bool,
            isSeasonal: null == isSeasonal
                ? _value.isSeasonal
                : isSeasonal // ignore: cast_nullable_to_non_nullable
                      as bool,
            offerPrice: freezed == offerPrice
                ? _value.offerPrice
                : offerPrice // ignore: cast_nullable_to_non_nullable
                      as double?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
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
abstract class _$$DishImplCopyWith<$Res> implements $DishCopyWith<$Res> {
  factory _$$DishImplCopyWith(
    _$DishImpl value,
    $Res Function(_$DishImpl) then,
  ) = __$$DishImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String categoryId,
    String name,
    double price,
    String description,
    String? imageUrl,
    List<String> allergens,
    int prepTimeMin,
    bool isAvailable,
    bool isActive,
    bool isOffer,
    bool isSeasonal,
    double? offerPrice,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$DishImplCopyWithImpl<$Res>
    extends _$DishCopyWithImpl<$Res, _$DishImpl>
    implements _$$DishImplCopyWith<$Res> {
  __$$DishImplCopyWithImpl(_$DishImpl _value, $Res Function(_$DishImpl) _then)
    : super(_value, _then);

  /// Create a copy of Dish
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? categoryId = null,
    Object? name = null,
    Object? price = null,
    Object? description = null,
    Object? imageUrl = freezed,
    Object? allergens = null,
    Object? prepTimeMin = null,
    Object? isAvailable = null,
    Object? isActive = null,
    Object? isOffer = null,
    Object? isSeasonal = null,
    Object? offerPrice = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$DishImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        categoryId: null == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        allergens: null == allergens
            ? _value._allergens
            : allergens // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        prepTimeMin: null == prepTimeMin
            ? _value.prepTimeMin
            : prepTimeMin // ignore: cast_nullable_to_non_nullable
                  as int,
        isAvailable: null == isAvailable
            ? _value.isAvailable
            : isAvailable // ignore: cast_nullable_to_non_nullable
                  as bool,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        isOffer: null == isOffer
            ? _value.isOffer
            : isOffer // ignore: cast_nullable_to_non_nullable
                  as bool,
        isSeasonal: null == isSeasonal
            ? _value.isSeasonal
            : isSeasonal // ignore: cast_nullable_to_non_nullable
                  as bool,
        offerPrice: freezed == offerPrice
            ? _value.offerPrice
            : offerPrice // ignore: cast_nullable_to_non_nullable
                  as double?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
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
class _$DishImpl implements _Dish {
  const _$DishImpl({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    this.description = '',
    this.imageUrl,
    final List<String> allergens = const [],
    this.prepTimeMin = 15,
    this.isAvailable = true,
    this.isActive = true,
    this.isOffer = false,
    this.isSeasonal = false,
    this.offerPrice,
    this.createdAt,
    this.updatedAt,
  }) : _allergens = allergens;

  factory _$DishImpl.fromJson(Map<String, dynamic> json) =>
      _$$DishImplFromJson(json);

  @override
  final String id;
  @override
  final String categoryId;
  @override
  final String name;
  @override
  final double price;
  @override
  @JsonKey()
  final String description;
  @override
  final String? imageUrl;
  final List<String> _allergens;
  @override
  @JsonKey()
  List<String> get allergens {
    if (_allergens is EqualUnmodifiableListView) return _allergens;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allergens);
  }

  @override
  @JsonKey()
  final int prepTimeMin;
  @override
  @JsonKey()
  final bool isAvailable;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final bool isOffer;
  @override
  @JsonKey()
  final bool isSeasonal;
  @override
  final double? offerPrice;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Dish(id: $id, categoryId: $categoryId, name: $name, price: $price, description: $description, imageUrl: $imageUrl, allergens: $allergens, prepTimeMin: $prepTimeMin, isAvailable: $isAvailable, isActive: $isActive, isOffer: $isOffer, isSeasonal: $isSeasonal, offerPrice: $offerPrice, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DishImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality().equals(
              other._allergens,
              _allergens,
            ) &&
            (identical(other.prepTimeMin, prepTimeMin) ||
                other.prepTimeMin == prepTimeMin) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isOffer, isOffer) || other.isOffer == isOffer) &&
            (identical(other.isSeasonal, isSeasonal) ||
                other.isSeasonal == isSeasonal) &&
            (identical(other.offerPrice, offerPrice) ||
                other.offerPrice == offerPrice) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    categoryId,
    name,
    price,
    description,
    imageUrl,
    const DeepCollectionEquality().hash(_allergens),
    prepTimeMin,
    isAvailable,
    isActive,
    isOffer,
    isSeasonal,
    offerPrice,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Dish
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DishImplCopyWith<_$DishImpl> get copyWith =>
      __$$DishImplCopyWithImpl<_$DishImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DishImplToJson(this);
  }
}

abstract class _Dish implements Dish {
  const factory _Dish({
    required final String id,
    required final String categoryId,
    required final String name,
    required final double price,
    final String description,
    final String? imageUrl,
    final List<String> allergens,
    final int prepTimeMin,
    final bool isAvailable,
    final bool isActive,
    final bool isOffer,
    final bool isSeasonal,
    final double? offerPrice,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$DishImpl;

  factory _Dish.fromJson(Map<String, dynamic> json) = _$DishImpl.fromJson;

  @override
  String get id;
  @override
  String get categoryId;
  @override
  String get name;
  @override
  double get price;
  @override
  String get description;
  @override
  String? get imageUrl;
  @override
  List<String> get allergens;
  @override
  int get prepTimeMin;
  @override
  bool get isAvailable;
  @override
  bool get isActive;
  @override
  bool get isOffer;
  @override
  bool get isSeasonal;
  @override
  double? get offerPrice;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Dish
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DishImplCopyWith<_$DishImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
