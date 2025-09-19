import '../features/web/orders/domain/entities/order_entity.dart';

class Order {
  final String? orderId;
  final String? customerId;
  final String? orderNumber;
  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;
  final String? customerEmail;
  final String? serviceType;
  final String? problemDescription;
  final String urgencyLevel;
  final DateTime? preferredDate;
  final String? preferredTimeSlot;
  final double? estimatedBudget;
  final String? specialRequirements;
  final String? accessInstructions;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? reviewedAt;
  final DateTime? quotedAt;
  final String? status;

  Order({
    this.orderId,
    this.customerId,
    this.orderNumber,
    this.customerName,
    this.customerPhone,
    this.customerAddress,
    this.customerEmail,
    this.serviceType,
    this.problemDescription,
    this.urgencyLevel = 'medium',
    this.preferredDate,
    this.preferredTimeSlot,
    this.estimatedBudget,
    this.specialRequirements,
    this.accessInstructions,
    this.createdAt,
    this.updatedAt,
    this.reviewedAt,
    this.quotedAt,
    this.status,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['order_id'],
      customerId: json['customer_id'],
      orderNumber: json['order_number'],
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      customerAddress: json['customer_address'],
      customerEmail: json['customer_email'],
      serviceType: json['service_type'],
      problemDescription: json['problem_description'],
      urgencyLevel: json['urgency_level'] ?? 'medium',
      preferredDate: json['preferred_date'] != null ? DateTime.parse(json['preferred_date']) : null,
      preferredTimeSlot: json['preferred_time_slot'],
      estimatedBudget: json['estimated_budget']?.toDouble(),
      specialRequirements: json['special_requirements'],
      accessInstructions: json['access_instructions'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      reviewedAt: json['reviewed_at'] != null ? DateTime.parse(json['reviewed_at']) : null,
      quotedAt: json['quoted_at'] != null ? DateTime.parse(json['quoted_at']) : null,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (orderId != null) 'order_id': orderId,
      'customer_id': customerId,
      'order_number': orderNumber,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_address': customerAddress,
      'customer_email': customerEmail,
      'service_type': serviceType,
      'problem_description': problemDescription,
      'urgency_level': urgencyLevel,
      'preferred_date': preferredDate?.toIso8601String().split('T')[0],
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

  Order copyWith({
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
    return Order(
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

  // Helper methods for status checking
  bool get isPending => status == 'pending' || status == null;
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isInProgress => status == 'in_progress';
  bool get isReviewed => status == 'reviewed';
  bool get isQuoted => status == 'quoted';

  // Status display text in Arabic
  String get statusDisplayText {
    switch (status) {
      case 'pending':
        return 'في الانتظار';
      case 'reviewed':
        return 'تم المراجعة';
      case 'quoted':
        return 'تم التسعير';
      case 'in_progress':
        return 'جاري التنفيذ';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return 'غير محدد';
    }
  }

  // Urgency level display text in Arabic
  String get urgencyDisplayText {
    switch (urgencyLevel) {
      case 'low':
        return 'منخفض';
      case 'medium':
        return 'متوسط';
      case 'high':
        return 'عالي';
      case 'urgent':
        return 'عاجل';
      default:
        return 'متوسط';
    }
  }

  // Factory method to create Order from OrderEntity
  factory Order.fromEntity(OrderEntity entity) {
    return Order(
      orderId: entity.orderId,
      customerId: entity.customerId,
      orderNumber: entity.orderNumber,
      customerName: entity.customerName,
      customerPhone: entity.customerPhone,
      customerEmail: entity.customerEmail,
      customerAddress: entity.customerAddress,
      serviceType: entity.serviceType,
      problemDescription: entity.problemDescription,
      urgencyLevel: entity.urgencyLevel ?? 'medium',
      preferredDate: entity.preferredDate,
      preferredTimeSlot: entity.preferredTimeSlot,
      estimatedBudget: entity.estimatedBudget,
      specialRequirements: entity.specialRequirements,
      accessInstructions: entity.accessInstructions,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      reviewedAt: entity.reviewedAt,
      quotedAt: entity.quotedAt,
      status: entity.status,
    );
  }
}