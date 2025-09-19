import '../repositories/order_repository.dart';
import 'package:pos_fixly_admin_dashboard/core/usecases/usecase.dart';

/// Use case for updating order status
class UpdateOrderStatusUseCase implements UseCase<void, UpdateStatusParams> {
  final OrderRepository repository;

  UpdateOrderStatusUseCase(this.repository);

  @override
  Future<void> call(UpdateStatusParams params) async {
    return await repository.updateOrderStatus(params.id, params.status);
  }
}