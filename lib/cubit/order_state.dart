import 'package:equatable/equatable.dart';
import '../models/order_model.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrdersLoaded extends OrderState {
  final List<Order> orders;
  final List<Order> currentOrders;
  final List<Order> completedOrders;
  final List<Order> cancelledOrders;

  const OrdersLoaded({
    required this.orders,
    required this.currentOrders,
    required this.completedOrders,
    required this.cancelledOrders,
  });

  @override
  List<Object?> get props => [orders, currentOrders, completedOrders, cancelledOrders];

  OrdersLoaded copyWith({
    List<Order>? orders,
    List<Order>? currentOrders,
    List<Order>? completedOrders,
    List<Order>? cancelledOrders,
  }) {
    return OrdersLoaded(
      currentOrders: currentOrders ?? this.currentOrders,
      completedOrders: completedOrders ?? this.completedOrders,
      cancelledOrders: cancelledOrders ?? this.cancelledOrders,
      orders: orders ?? this.orders,
    );
  }
}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderCreating extends OrderState {}

class OrderCreated extends OrderState {
  final Order order;

  const OrderCreated(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderUpdating extends OrderState {}

class OrderUpdated extends OrderState {
  final Order order;

  const OrderUpdated(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderDeleting extends OrderState {}

class OrderDeleted extends OrderState {
  final String orderId;

  const OrderDeleted(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

// حالات إضافية خاصة بلوحة التحكم
class OrderStatisticsLoaded extends OrderState {
  final Map<String, int> statistics;

  const OrderStatisticsLoaded(this.statistics);

  @override
  List<Object?> get props => [statistics];
}

class OrderSearchResults extends OrderState {
  final List<Order> searchResults;
  final String query;

  const OrderSearchResults(this.searchResults, this.query);

  @override
  List<Object?> get props => [searchResults, query];
}