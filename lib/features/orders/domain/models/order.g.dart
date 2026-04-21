// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  id: json['id'] as String,
  orderType: json['order_type'] as String,
  status: json['status'] as String,
  paymentStatus: json['payment_status'] as String,
  subtotal: (json['subtotal'] as num).toDouble(),
  deliveryFee: (json['delivery_fee'] as num).toDouble(),
  total: (json['total'] as num).toDouble(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  userId: json['user_id'] as String?,
  paymentMethod: json['payment_method'] as String?,
  addressId: json['address_id'] as String?,
  scheduledAt: json['scheduled_at'] == null
      ? null
      : DateTime.parse(json['scheduled_at'] as String),
  notes: json['notes'] as String?,
  assignedDriverId: json['assigned_driver_id'] as String?,
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'id': instance.id,
  'order_type': instance.orderType,
  'status': instance.status,
  'payment_status': instance.paymentStatus,
  'subtotal': instance.subtotal,
  'delivery_fee': instance.deliveryFee,
  'total': instance.total,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'user_id': instance.userId,
  'payment_method': instance.paymentMethod,
  'address_id': instance.addressId,
  'scheduled_at': instance.scheduledAt?.toIso8601String(),
  'notes': instance.notes,
  'assigned_driver_id': instance.assignedDriverId,
};

_$OrderImpl _$$OrderImplFromJson(Map<String, dynamic> json) => _$OrderImpl(
  id: json['id'] as String,
  orderType: json['orderType'] as String,
  status: json['status'] as String,
  paymentStatus: json['paymentStatus'] as String,
  subtotal: (json['subtotal'] as num).toDouble(),
  deliveryFee: (json['deliveryFee'] as num).toDouble(),
  total: (json['total'] as num).toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  userId: json['userId'] as String?,
  paymentMethod: json['paymentMethod'] as String?,
  addressId: json['addressId'] as String?,
  scheduledAt: json['scheduledAt'] == null
      ? null
      : DateTime.parse(json['scheduledAt'] as String),
  notes: json['notes'] as String?,
  assignedDriverId: json['assignedDriverId'] as String?,
);

Map<String, dynamic> _$$OrderImplToJson(_$OrderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderType': instance.orderType,
      'status': instance.status,
      'paymentStatus': instance.paymentStatus,
      'subtotal': instance.subtotal,
      'deliveryFee': instance.deliveryFee,
      'total': instance.total,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'userId': instance.userId,
      'paymentMethod': instance.paymentMethod,
      'addressId': instance.addressId,
      'scheduledAt': instance.scheduledAt?.toIso8601String(),
      'notes': instance.notes,
      'assignedDriverId': instance.assignedDriverId,
    };
