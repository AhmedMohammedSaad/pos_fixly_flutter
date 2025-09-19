import 'package:pos_fixly_admin_dashboard/core/usecases/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

/// Use case for getting sorted orders
/// Follows Single Responsibility Principle and Use Case pattern
class GetSortedOrdersUseCase implements UseCase<List<OrderEntity>, SortOrdersParams> {
  final OrderRepository repository;

  GetSortedOrdersUseCase(this.repository);

  @override
  Future<List<OrderEntity>> call(SortOrdersParams params) async {
    return await repository.getSortedOrders(params.sortBy, params.ascending);
  }
}

/// Parameters for sort orders use case
class SortOrdersParams {
  final String sortBy;
  final bool ascending;

  SortOrdersParams({
    required this.sortBy,
    required this.ascending,
  });
}