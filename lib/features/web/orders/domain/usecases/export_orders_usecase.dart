import 'package:pos_fixly_admin_dashboard/core/usecases/usecase.dart';
import '../repositories/order_repository.dart';

/// Use case for exporting orders to CSV in web feature
/// Follows Single Responsibility Principle and Use Case pattern
class ExportOrdersUseCase implements UseCase<String, NoParams> {
  final OrderRepository repository;

  ExportOrdersUseCase(this.repository);

  @override
  Future<String> call(NoParams params) async {
    return await repository.exportOrdersToCSV();
  }
}