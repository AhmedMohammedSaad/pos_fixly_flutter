import 'package:pos_fixly_admin_dashboard/core/usecases/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetOrdersByStatusUseCase implements UseCase<List<OrderEntity>, String> {
  final OrderRepository repository;

  GetOrdersByStatusUseCase(this.repository);

  @override
  Future<List<OrderEntity>> call(String status) async {
    return await repository.getOrdersByStatus(status);
  }
}