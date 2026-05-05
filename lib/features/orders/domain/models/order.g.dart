// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderImpl _$$OrderImplFromJson(Map<String, dynamic> json) => _$OrderImpl(
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

Map<String, dynamic> _$$OrderImplToJson(_$OrderImpl instance) =>
    <String, dynamic>{
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
