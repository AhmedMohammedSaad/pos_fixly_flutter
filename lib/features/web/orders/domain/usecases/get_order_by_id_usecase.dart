import 'package:pos_fixly_admin_dashboard/core/usecases/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetOrderByIdUseCase implements UseCase<OrderEntity?, String> {
  final OrderRepository repository;

  GetOrderByIdUseCase(this.repository);

  @override
  Future<OrderEntity?> call(String orderId) async {
    return await repository.getOrderById(orderId);
  }
}