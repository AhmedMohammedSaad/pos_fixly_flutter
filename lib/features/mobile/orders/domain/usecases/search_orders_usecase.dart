import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';
import 'package:pos_fixly_admin_dashboard/core/usecases/usecase.dart';

/// Use case for searching orders
class SearchOrdersUseCase implements UseCase<List<OrderEntity>, StringParams> {
  final OrderRepository repository;

  SearchOrdersUseCase(this.repository);

  @override
  Future<List<OrderEntity>> call(StringParams params) async {
    return await repository.searchOrders(params.value);
  }
}