import 'package:equatable/equatable.dart';

/// Domain entity for Order - represents the core business object
/// Follows Entity pattern from Clean Architecture
/// Uses Equatable for value comparison
class OrderEntity extends Equatable {
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

  const OrderEntity({
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

  /// Business logic methods

  /// Check if order is urgent
  bool get isUrgent => urgencyLevel == 'urgent';

  /// Check if order is high priority
  bool get isHighPriority => urgencyLevel == 'high' || urgencyLevel == 'urgent';

  /// Check if order is pending
  bool get isPending => status == 'pending';

  /// Check if order is completed
  bool get isCompleted => status == 'completed';

  /// Check if order is in progress
  bool get isInProgress => status == 'in_progress';

  /// Get formatted urgency level in Arabic
  String get urgencyLevelArabic {
    switch (urgencyLevel) {
      case 'urgent':
        return 'عاجل';
      case 'high':
        return 'عالي';
      case 'medium':
        return 'متوسط';
      case 'low':
        return 'منخفض';
      default:
        return 'متوسط';
    }
  }

  /// Get formatted status in Arabic
  String get statusArabic {
    switch (status) {
      case 'pending':
        return 'في الانتظار';
      case 'reviewed':
        return 'تم المراجعة';
      case 'quoted':
        return 'تم التسعير';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return 'غير محدد';
    }
  }

  /// Get urgency color
  String get urgencyColor {
    switch (urgencyLevel) {
      case 'urgent':
        return '#FF4444';
      case 'high':
        return '#FF8800';
      case 'medium':
        return '#4CAF50';
      case 'low':
        return '#2196F3';
      default:
        return '#4CAF50';
    }
  }

  /// Get status color
  String get statusColor {
    switch (status) {
      case 'pending':
        return '#FF9800';
      case 'reviewed':
        return '#2196F3';
      case 'quoted':
        return '#9C27B0';
      case 'in_progress':
        return '#FF5722';
      case 'completed':
        return '#4CAF50';
      case 'cancelled':
        return '#F44336';
      default:
        return '#757575';
    }
  }

  /// Check if order has valid customer information
  bool get hasValidCustomerInfo {
    return customerName != null && 
           customerName!.isNotEmpty &&
           customerPhone != null && 
           customerPhone!.isNotEmpty;
  }

  /// Check if order is overdue (preferred date has passed)
  bool get isOverdue {
    if (preferredDate == null) return false;
    return DateTime.now().isAfter(preferredDate!) && !isCompleted;
  }

  @override
  List<Object?> get props => [
        orderId,
        customerId,
        orderNumber,
        customerName,
        customerPhone,
        customerAddress,
        customerEmail,
        serviceType,
        problemDescription,
        urgencyLevel,
        preferredDate,
        preferredTimeSlot,
        estimatedBudget,
        specialRequirements,
        accessInstructions,
        createdAt,
        updatedAt,
        reviewedAt,
        quotedAt,
        status,
      ];
}