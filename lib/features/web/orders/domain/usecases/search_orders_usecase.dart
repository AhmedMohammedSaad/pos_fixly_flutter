import 'package:pos_fixly_admin_dashboard/core/usecases/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class SearchOrdersUseCase implements UseCase<List<OrderEntity>, String> {
  final OrderRepository repository;

  SearchOrdersUseCase(this.repository);

  @override
  Future<List<OrderEntity>> call(String query) async {
    return await repository.searchOrders(query);
  }
}