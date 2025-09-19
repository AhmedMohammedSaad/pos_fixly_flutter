import 'package:equatable/equatable.dart';

/// Base use case interface
/// Follows Interface Segregation Principle
abstract class UseCase<T, Params> {
  Future<T> call(Params params);
}

/// Use case with no parameters
class NoParams extends Equatable {
  const NoParams();
  
  @override
  List<Object> get props => [];
}

/// Use case parameters with single string parameter
class StringParams extends Equatable {
  final String value;

  const StringParams(this.value);

  @override
  List<Object> get props => [value];
}

/// Use case parameters with ID and status
class UpdateStatusParams extends Equatable {
  final String id;
  final String status;

  const UpdateStatusParams({required this.id, required this.status});

  @override
  List<Object> get props => [id, status];
}

/// Use case parameters with date range
class DateRangeParams extends Equatable {
  final DateTime startDate;
  final DateTime endDate;

  const DateRangeParams({required this.startDate, required this.endDate});

  @override
  List<Object> get props => [startDate, endDate];
}