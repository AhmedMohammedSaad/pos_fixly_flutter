import 'package:pos_fixly_admin_dashboard/core/usecases/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

/// Use case for getting filtered orders
/// Follows Single Responsibility Principle and Use Case pattern
class GetFilteredOrdersUseCase implements UseCase<List<OrderEntity>, FilterOrdersParams> {
  final OrderRepository repository;

  GetFilteredOrdersUseCase(this.repository);

  @override
  Future<List<OrderEntity>> call(FilterOrdersParams params) async {
    final filters = <String, dynamic>{};
    
    if (params.status != null) filters['status'] = params.status;
    if (params.urgencyLevel != null) filters['urgencyLevel'] = params.urgencyLevel;
    if (params.serviceType != null) filters['serviceType'] = params.serviceType;
    if (params.startDate != null) filters['startDate'] = params.startDate;
    if (params.endDate != null) filters['endDate'] = params.endDate;
    if (params.technicianId != null) filters['technicianId'] = params.technicianId;
    
    return await repository.getFilteredOrders(filters);
  }
}

/// Parameters for filter orders use case
class FilterOrdersParams {
  final String? status;
  final String? urgencyLevel;
  final String? serviceType;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? technicianId;

  FilterOrdersParams({
    this.status,
    this.urgencyLevel,
    this.serviceType,
    this.startDate,
    this.endDate,
    this.technicianId,
  });
}