import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorHandlerService {
  static String getErrorMessage(dynamic error, BuildContext context) {
    if (error is String) {
      switch (error) {
        case 'no_internet':
          return 'لا يوجد اتصال بالإنترنت. يرجى التحقق من الاتصال والمحاولة مرة أخرى.';
        default:
          return error;
      }
    }

    if (error is AuthException) {
      switch (error.message.toLowerCase()) {
        case 'invalid login credentials':
          return 'بيانات تسجيل الدخول غير صحيحة. يرجى التحقق من البريد الإلكتروني وكلمة المرور.';
        case 'email not confirmed':
          return 'يرجى تأكيد البريد الإلكتروني أولاً.';
        case 'user not found':
          return 'المستخدم غير موجود.';
        case 'too many requests':
          return 'تم إرسال طلبات كثيرة. يرجى المحاولة لاحقاً.';
        case 'weak password':
          return 'كلمة المرور ضعيفة. يرجى اختيار كلمة مرور أقوى.';
        case 'email already registered':
        case 'user already registered':
          return 'البريد الإلكتروني مسجل مسبقاً.';
        case 'invalid email':
          return 'البريد الإلكتروني غير صحيح.';
        case 'signup disabled':
          return 'التسجيل معطل حالياً.';
        default:
          return 'حدث خطأ في المصادقة: ${error.message}';
      }
    }

    if (error is PostgrestException) {
      switch (error.code) {
        case '23505': // unique_violation
          return 'البيانات موجودة مسبقاً.';
        case '23503': // foreign_key_violation
          return 'خطأ في ربط البيانات.';
        case '42501': // insufficient_privilege
          return 'ليس لديك صلاحية للقيام بهذا الإجراء.';
        default:
          return 'خطأ في قاعدة البيانات: ${error.message}';
      }
    }

    // Handle network errors
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('network') || 
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('socket')) {
      return 'خطأ في الاتصال. يرجى التحقق من الإنترنت والمحاولة مرة أخرى.';
    }

    if (errorString.contains('jwt expired') || errorString.contains('invalid jwt')) {
      return 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.';
    }

    // Default error message
    return 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
  }

  /// Get user-friendly error message for specific error types
  static String getLocalizedErrorMessage(String errorKey, BuildContext context) {
    switch (errorKey) {
      case 'network_error':
        return 'خطأ في الشبكة';
      case 'server_error':
        return 'خطأ في الخادم';
      case 'validation_error':
        return 'خطأ في التحقق من البيانات';
      case 'authentication_error':
        return 'خطأ في المصادقة';
      case 'permission_error':
        return 'ليس لديك صلاحية';
      case 'not_found_error':
        return 'العنصر غير موجود';
      case 'timeout_error':
        return 'انتهت مهلة الاتصال';
      default:
        return 'حدث خطأ غير متوقع';
    }
  }
}