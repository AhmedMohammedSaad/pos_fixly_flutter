import 'package:pos_fixly_admin_dashboard/core/usecases/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

/// Use case for getting all orders in web feature
/// Follows Single Responsibility Principle and Use Case pattern
class GetAllOrdersUseCase implements UseCase<List<OrderEntity>, NoParams> {
  final OrderRepository repository;

  GetAllOrdersUseCase(this.repository);

  @override
  Future<List<OrderEntity>> call(NoParams params) async {
    return await repository.getAllOrders();
  }
}