import 'package:pos_fixly_admin_dashboard/core/usecases/usecase.dart';
import '../repositories/order_repository.dart';

/// Use case for bulk deleting orders
/// Follows Single Responsibility Principle and Use Case pattern
class BulkDeleteOrdersUseCase implements UseCase<bool, BulkDeleteOrdersParams> {
  final OrderRepository repository;

  BulkDeleteOrdersUseCase(this.repository);

  @override
  Future<bool> call(BulkDeleteOrdersParams params) async {
    return await repository.bulkDeleteOrders(params.orderIds);
  }
}

/// Parameters for bulk delete orders use case
class BulkDeleteOrdersParams {
  final List<String> orderIds;

  BulkDeleteOrdersParams({
    required this.orderIds,
  });
}