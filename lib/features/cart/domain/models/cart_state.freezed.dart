// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cart_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CartState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() empty,
    required TResult Function(List<CartItem> items, double total) active,
    required TResult Function(
      List<CartItem> items,
      double total,
      String orderType,
    )
    checkout,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? empty,
    TResult? Function(List<CartItem> items, double total)? active,
    TResult? Function(List<CartItem> items, double total, String orderType)?
    checkout,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? empty,
    TResult Function(List<CartItem> items, double total)? active,
    TResult Function(List<CartItem> items, double total, String orderType)?
    checkout,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CartEmpty value) empty,
    required TResult Function(CartActive value) active,
    required TResult Function(CartCheckout value) checkout,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CartEmpty value)? empty,
    TResult? Function(CartActive value)? active,
    TResult? Function(CartCheckout value)? checkout,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CartEmpty value)? empty,
    TResult Function(CartActive value)? active,
    TResult Function(CartCheckout value)? checkout,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CartStateCopyWith<$Res> {
  factory $CartStateCopyWith(CartState value, $Res Function(CartState) then) =
      _$CartStateCopyWithImpl<$Res, CartState>;
}

/// @nodoc
class _$CartStateCopyWithImpl<$Res, $Val extends CartState>
    implements $CartStateCopyWith<$Res> {
  _$CartStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CartState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$CartEmptyImplCopyWith<$Res> {
  factory _$$CartEmptyImplCopyWith(
    _$CartEmptyImpl value,
    $Res Function(_$CartEmptyImpl) then,
  ) = __$$CartEmptyImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$CartEmptyImplCopyWithImpl<$Res>
    extends _$CartStateCopyWithImpl<$Res, _$CartEmptyImpl>
    implements _$$CartEmptyImplCopyWith<$Res> {
  __$$CartEmptyImplCopyWithImpl(
    _$CartEmptyImpl _value,
    $Res Function(_$CartEmptyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CartState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$CartEmptyImpl implements CartEmpty {
  const _$CartEmptyImpl();

  @override
  String toString() {
    return 'CartState.empty()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$CartEmptyImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() empty,
    required TResult Function(List<CartItem> items, double total) active,
    required TResult Function(
      List<CartItem> items,
      double total,
      String orderType,
    )
    checkout,
  }) {
    return empty();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? empty,
    TResult? Function(List<CartItem> items, double total)? active,
    TResult? Function(List<CartItem> items, double total, String orderType)?
    checkout,
  }) {
    return empty?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? empty,
    TResult Function(List<CartItem> items, double total)? active,
    TResult Function(List<CartItem> items, double total, String orderType)?
    checkout,
    required TResult orElse(),
  }) {
    if (empty != null) {
      return empty();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CartEmpty value) empty,
    required TResult Function(CartActive value) active,
    required TResult Function(CartCheckout value) checkout,
  }) {
    return empty(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CartEmpty value)? empty,
    TResult? Function(CartActive value)? active,
    TResult? Function(CartCheckout value)? checkout,
  }) {
    return empty?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CartEmpty value)? empty,
    TResult Function(CartActive value)? active,
    TResult Function(CartCheckout value)? checkout,
    required TResult orElse(),
  }) {
    if (empty != null) {
      return empty(this);
    }
    return orElse();
  }
}

abstract class CartEmpty implements CartState {
  const factory CartEmpty() = _$CartEmptyImpl;
}

/// @nodoc
abstract class _$$CartActiveImplCopyWith<$Res> {
  factory _$$CartActiveImplCopyWith(
    _$CartActiveImpl value,
    $Res Function(_$CartActiveImpl) then,
  ) = __$$CartActiveImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<CartItem> items, double total});
}

/// @nodoc
class __$$CartActiveImplCopyWithImpl<$Res>
    extends _$CartStateCopyWithImpl<$Res, _$CartActiveImpl>
    implements _$$CartActiveImplCopyWith<$Res> {
  __$$CartActiveImplCopyWithImpl(
    _$CartActiveImpl _value,
    $Res Function(_$CartActiveImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CartState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? items = null, Object? total = null}) {
    return _then(
      _$CartActiveImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<CartItem>,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$CartActiveImpl implements CartActive {
  const _$CartActiveImpl({
    required final List<CartItem> items,
    required this.total,
  }) : _items = items;

  final List<CartItem> _items;
  @override
  List<CartItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final double total;

  @override
  String toString() {
    return 'CartState.active(items: $items, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CartActiveImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.total, total) || other.total == total));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_items),
    total,
  );

  /// Create a copy of CartState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CartActiveImplCopyWith<_$CartActiveImpl> get copyWith =>
      __$$CartActiveImplCopyWithImpl<_$CartActiveImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() empty,
    required TResult Function(List<CartItem> items, double total) active,
    required TResult Function(
      List<CartItem> items,
      double total,
      String orderType,
    )
    checkout,
  }) {
    return active(items, total);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? empty,
    TResult? Function(List<CartItem> items, double total)? active,
    TResult? Function(List<CartItem> items, double total, String orderType)?
    checkout,
  }) {
    return active?.call(items, total);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? empty,
    TResult Function(List<CartItem> items, double total)? active,
    TResult Function(List<CartItem> items, double total, String orderType)?
    checkout,
    required TResult orElse(),
  }) {
    if (active != null) {
      return active(items, total);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CartEmpty value) empty,
    required TResult Function(CartActive value) active,
    required TResult Function(CartCheckout value) checkout,
  }) {
    return active(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CartEmpty value)? empty,
    TResult? Function(CartActive value)? active,
    TResult? Function(CartCheckout value)? checkout,
  }) {
    return active?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CartEmpty value)? empty,
    TResult Function(CartActive value)? active,
    TResult Function(CartCheckout value)? checkout,
    required TResult orElse(),
  }) {
    if (active != null) {
      return active(this);
    }
    return orElse();
  }
}

abstract class CartActive implements CartState {
  const factory CartActive({
    required final List<CartItem> items,
    required final double total,
  }) = _$CartActiveImpl;

  List<CartItem> get items;
  double get total;

  /// Create a copy of CartState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CartActiveImplCopyWith<_$CartActiveImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CartCheckoutImplCopyWith<$Res> {
  factory _$$CartCheckoutImplCopyWith(
    _$CartCheckoutImpl value,
    $Res Function(_$CartCheckoutImpl) then,
  ) = __$$CartCheckoutImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<CartItem> items, double total, String orderType});
}

/// @nodoc
class __$$CartCheckoutImplCopyWithImpl<$Res>
    extends _$CartStateCopyWithImpl<$Res, _$CartCheckoutImpl>
    implements _$$CartCheckoutImplCopyWith<$Res> {
  __$$CartCheckoutImplCopyWithImpl(
    _$CartCheckoutImpl _value,
    $Res Function(_$CartCheckoutImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CartState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? total = null,
    Object? orderType = null,
  }) {
    return _then(
      _$CartCheckoutImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<CartItem>,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as double,
        orderType: null == orderType
            ? _value.orderType
            : orderType // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$CartCheckoutImpl implements CartCheckout {
  const _$CartCheckoutImpl({
    required final List<CartItem> items,
    required this.total,
    required this.orderType,
  }) : _items = items;

  final List<CartItem> _items;
  @override
  List<CartItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final double total;
  @override
  final String orderType;

  @override
  String toString() {
    return 'CartState.checkout(items: $items, total: $total, orderType: $orderType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CartCheckoutImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.orderType, orderType) ||
                other.orderType == orderType));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_items),
    total,
    orderType,
  );

  /// Create a copy of CartState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CartCheckoutImplCopyWith<_$CartCheckoutImpl> get copyWith =>
      __$$CartCheckoutImplCopyWithImpl<_$CartCheckoutImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() empty,
    required TResult Function(List<CartItem> items, double total) active,
    required TResult Function(
      List<CartItem> items,
      double total,
      String orderType,
    )
    checkout,
  }) {
    return checkout(items, total, orderType);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? empty,
    TResult? Function(List<CartItem> items, double total)? active,
    TResult? Function(List<CartItem> items, double total, String orderType)?
    checkout,
  }) {
    return checkout?.call(items, total, orderType);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? empty,
    TResult Function(List<CartItem> items, double total)? active,
    TResult Function(List<CartItem> items, double total, String orderType)?
    checkout,
    required TResult orElse(),
  }) {
    if (checkout != null) {
      return checkout(items, total, orderType);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CartEmpty value) empty,
    required TResult Function(CartActive value) active,
    required TResult Function(CartCheckout value) checkout,
  }) {
    return checkout(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CartEmpty value)? empty,
    TResult? Function(CartActive value)? active,
    TResult? Function(CartCheckout value)? checkout,
  }) {
    return checkout?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CartEmpty value)? empty,
    TResult Function(CartActive value)? active,
    TResult Function(CartCheckout value)? checkout,
    required TResult orElse(),
  }) {
    if (checkout != null) {
      return checkout(this);
    }
    return orElse();
  }
}

abstract class CartCheckout implements CartState {
  const factory CartCheckout({
    required final List<CartItem> items,
    required final double total,
    required final String orderType,
  }) = _$CartCheckoutImpl;

  List<CartItem> get items;
  double get total;
  String get orderType;

  /// Create a copy of CartState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CartCheckoutImplCopyWith<_$CartCheckoutImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
