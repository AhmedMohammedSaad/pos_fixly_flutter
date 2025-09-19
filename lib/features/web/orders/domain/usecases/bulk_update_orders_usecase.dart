import 'package:pos_fixly_admin_dashboard/core/usecases/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

/// Use case for bulk updating order status
/// Follows Single Responsibility Principle and Use Case pattern
class BulkUpdateOrdersUseCase implements UseCase<List<OrderEntity>, BulkUpdateOrdersParams> {
  final OrderRepository repository;

  BulkUpdateOrdersUseCase(this.repository);

  @override
  Future<List<OrderEntity>> call(BulkUpdateOrdersParams params) async {
    return await repository.bulkUpdateOrderStatus(
      params.orderIds,
      params.status,
    );
  }
}

/// Parameters for bulk update orders use case
class BulkUpdateOrdersParams {
  final List<String> orderIds;
  final String status;

  BulkUpdateOrdersParams({
    required this.orderIds,
    required this.status,
  });
}