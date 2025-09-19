import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';
import 'package:pos_fixly_admin_dashboard/core/usecases/usecase.dart';

/// Use case for getting orders by status
class GetOrdersByStatusUseCase implements UseCase<List<OrderEntity>, StringParams> {
  final OrderRepository repository;

  GetOrdersByStatusUseCase(this.repository);

  @override
  Future<List<OrderEntity>> call(StringParams params) async {
    return await repository.getOrdersByStatus(params.value.isEmpty ? null : params.value);
  }
}