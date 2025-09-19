import 'package:pos_fixly_admin_dashboard/core/usecases/usecase.dart';
import '../repositories/order_repository.dart';

class DeleteOrderUseCase implements UseCase<bool, String> {
  final OrderRepository repository;

  DeleteOrderUseCase(this.repository);

  @override
  Future<bool> call(String orderId) async {
    return await repository.deleteOrder(orderId);
  }
}