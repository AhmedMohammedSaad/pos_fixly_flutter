import '../../domain/entities/order_entity.dart';

/// Data model for Order - extends Entity and handles JSON serialization
/// Follows Data Transfer Object pattern
class OrderModel extends OrderEntity {
  const OrderModel({
    required super.orderId,
    required super.customerId,
    required super.orderNumber,
    required super.customerName,
    required super.customerPhone,
    required super.customerAddress,
    required super.customerEmail,
    required super.serviceType,
    required super.problemDescription,
    required super.urgencyLevel,
    required super.preferredDate,
    required super.preferredTimeSlot,
    required super.estimatedBudget,
    required super.specialRequirements,
    required super.accessInstructions,
    required super.createdAt,
    required super.updatedAt,
    required super.reviewedAt,
    required super.quotedAt,
    required super.status,
  });

  /// Factory constructor to create OrderModel from JSON
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['order_id'] as String?,
      customerId: json['customer_id'] as String?,
      orderNumber: json['order_number'] as String?,
      customerName: json['customer_name'] as String?,
      customerPhone: json['customer_phone'] as String?,
      customerAddress: json['customer_address'] as String?,
      customerEmail: json['customer_email'] as String?,
      serviceType: json['service_type'] as String?,
      problemDescription: json['problem_description'] as String?,
      urgencyLevel: json['urgency_level'] as String? ?? 'medium',
      preferredDate: json['preferred_date'] != null 
          ? DateTime.parse(json['preferred_date'] as String)
          : null,
      preferredTimeSlot: json['preferred_time_slot'] as String?,
      estimatedBudget: json['estimated_budget'] != null 
          ? (json['estimated_budget'] as num).toDouble()
          : null,
      specialRequirements: json['special_requirements'] as String?,
      accessInstructions: json['access_instructions'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      reviewedAt: json['reviewed_at'] != null 
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      quotedAt: json['quoted_at'] != null 
          ? DateTime.parse(json['quoted_at'] as String)
          : null,
      status: json['status'] as String?,
    );
  }

  /// Convert OrderModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'customer_id': customerId,
      'order_number': orderNumber,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_address': customerAddress,
      'customer_email': customerEmail,
      'service_type': serviceType,
      'problem_description': problemDescription,
      'urgency_level': urgencyLevel,
      'preferred_date': preferredDate?.toIso8601String(),
      'preferred_time_slot': preferredTimeSlot,
      'estimated_budget': estimatedBudget,
      'special_requirements': specialRequirements,
      'access_instructions': accessInstructions,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'quoted_at': quotedAt?.toIso8601String(),
      'status': status,
    };
  }

  /// Create a copy of OrderModel with updated fields
  OrderModel copyWith({
    String? orderId,
    String? customerId,
    String? orderNumber,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    String? customerEmail,
    String? serviceType,
    String? problemDescription,
    String? urgencyLevel,
    DateTime? preferredDate,
    String? preferredTimeSlot,
    double? estimatedBudget,
    String? specialRequirements,
    String? accessInstructions,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? reviewedAt,
    DateTime? quotedAt,
    String? status,
  }) {
    return OrderModel(
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      orderNumber: orderNumber ?? this.orderNumber,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
      customerEmail: customerEmail ?? this.customerEmail,
      serviceType: serviceType ?? this.serviceType,
      problemDescription: problemDescription ?? this.problemDescription,
      urgencyLevel: urgencyLevel ?? this.urgencyLevel,
      preferredDate: preferredDate ?? this.preferredDate,
      preferredTimeSlot: preferredTimeSlot ?? this.preferredTimeSlot,
      estimatedBudget: estimatedBudget ?? this.estimatedBudget,
      specialRequirements: specialRequirements ?? this.specialRequirements,
      accessInstructions: accessInstructions ?? this.accessInstructions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      quotedAt: quotedAt ?? this.quotedAt,
      status: status ?? this.status,
    );
  }
}