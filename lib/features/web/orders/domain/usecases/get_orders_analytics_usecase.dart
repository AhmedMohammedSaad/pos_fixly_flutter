import 'package:pos_fixly_admin_dashboard/core/usecases/usecase.dart';
import '../repositories/order_repository.dart';

/// Use case for getting orders analytics in web feature
/// Follows Single Responsibility Principle and Use Case pattern
class GetOrdersAnalyticsUseCase implements UseCase<Map<String, dynamic>, NoParams> {
  final OrderRepository repository;

  GetOrdersAnalyticsUseCase(this.repository);

  @override
  Future<Map<String, dynamic>> call(NoParams params) async {
    return await repository.getOrdersAnalytics();
  }
}