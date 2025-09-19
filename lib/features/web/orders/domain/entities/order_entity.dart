import 'package:equatable/equatable.dart';

/// Order entity for web feature
/// Follows Entity pattern from Clean Architecture
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

  /// Business logic methods

  /// Check if order is pending
  bool get isPending => status == 'pending';

  /// Check if order is reviewed
  bool get isReviewed => status == 'reviewed';

  /// Check if order is in progress
  bool get isInProgress => status == 'in_progress';

  /// Check if order is completed
  bool get isCompleted => status == 'completed';

  /// Check if order is cancelled
  bool get isCancelled => status == 'cancelled';

  /// Check if order is urgent
  bool get isUrgent => urgencyLevel == 'high';

  /// Check if order is overdue
  bool get isOverdue {
    if (preferredDate == null) return false;
    return DateTime.now().isAfter(preferredDate!) && !isCompleted;
  }

  /// Get status color for UI
  String get statusColor {
    switch (status) {
      case 'pending':
        return '#FFA500'; // Orange
      case 'reviewed':
        return '#2196F3'; // Blue
      case 'in_progress':
        return '#FF9800'; // Amber
      case 'completed':
        return '#4CAF50'; // Green
      case 'cancelled':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  /// Get priority color for UI
  String get priorityColor {
    switch (urgencyLevel) {
      case 'high':
        return '#F44336'; // Red
      case 'medium':
        return '#FF9800'; // Orange
      case 'low':
        return '#4CAF50'; // Green
      default:
        return '#9E9E9E'; // Grey
    }
  }

  /// Get days since creation
  int get daysSinceCreation {
    if (createdAt == null) return 0;
    return DateTime.now().difference(createdAt!).inDays;
  }

  /// Get formatted status text
  String get statusText {
    switch (status) {
      case 'pending':
        return 'في الانتظار';
      case 'reviewed':
        return 'تم المراجعة';
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

  /// Get formatted priority text
  String get priorityText {
    switch (urgencyLevel) {
      case 'high':
        return 'عالي';
      case 'medium':
        return 'متوسط';
      case 'low':
        return 'منخفض';
      default:
        return 'غير محدد';
    }
  }
}