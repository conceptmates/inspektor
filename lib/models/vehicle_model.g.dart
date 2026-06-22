// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VehicleBrand _$VehicleBrandFromJson(Map<String, dynamic> json) =>
    _VehicleBrand(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$VehicleBrandToJson(_VehicleBrand instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_VehicleCategory _$VehicleCategoryFromJson(Map<String, dynamic> json) =>
    _VehicleCategory(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      basePrice: json['base_price'] as String? ?? '0.00',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$VehicleCategoryToJson(_VehicleCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'base_price': instance.basePrice,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_VehicleModel _$VehicleModelFromJson(Map<String, dynamic> json) =>
    _VehicleModel(
      id: (json['id'] as num).toInt(),
      brandId: (json['brand_id'] as num?)?.toInt(),
      categoryId: (json['category_id'] as num?)?.toInt(),
      name: json['name'] as String,
      brand: json['brand'] == null
          ? null
          : VehicleBrand.fromJson(json['brand'] as Map<String, dynamic>),
      category: json['category'] == null
          ? null
          : VehicleCategory.fromJson(json['category'] as Map<String, dynamic>),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$VehicleModelToJson(_VehicleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'brand_id': instance.brandId,
      'category_id': instance.categoryId,
      'name': instance.name,
      'brand': instance.brand?.toJson(),
      'category': instance.category?.toJson(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
