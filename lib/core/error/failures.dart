import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

// Auth specific failures
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure() : super('بيانات تسجيل الدخول غير صحيحة');
}

class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure() : super('المستخدم غير موجود');
}

class EmailNotVerifiedFailure extends AuthFailure {
  const EmailNotVerifiedFailure() : super('يرجى تأكيد البريد الإلكتروني أولاً');
}

class TooManyRequestsFailure extends AuthFailure {
  const TooManyRequestsFailure() : super('تم إرسال طلبات كثيرة. يرجى المحاولة لاحقاً');
}

class SessionExpiredFailure extends AuthFailure {
  const SessionExpiredFailure() : super('انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى');
}