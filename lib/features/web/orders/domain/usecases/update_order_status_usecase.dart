import 'package:pos_fixly_admin_dashboard/core/usecases/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class UpdateOrderStatusParams {
  final String orderId;
  final String status;

  UpdateOrderStatusParams({
    required this.orderId,
    required this.status,
  });
}

class UpdateOrderStatusUseCase
    implements UseCase<OrderEntity, UpdateOrderStatusParams> {
  final OrderRepository repository;

  UpdateOrderStatusUseCase(this.repository);

  @override
  Future<OrderEntity> call(UpdateOrderStatusParams params) async {
    return await repository.updateOrderStatus(params.orderId, params.status);
  }
}
