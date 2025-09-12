import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_model.dart';
import 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Cache للبيانات
  List<Order>? _cachedOrders;
  DateTime? _lastFetchTime;
  static const Duration _cacheTimeout = Duration(minutes: 5);

  // التحميل التدريجي
  static const int _pageSize = 20;
  int _currentPage = 0;
  bool _hasMoreData = true;

  OrderCubit() : super(OrderInitial());

  // دالة للتعامل مع انتهاء صلاحية JWT
  Future<T> _withRefreshRetry<T>(Future<T> Function() run) async {
    try {
      final result = await run();
      log('✅ نجح الاستعلام: $result');
      return result;
    } catch (e) {
      log('❌ خطأ في الاستعلام: $e');
      final msg = e.toString().toLowerCase();

      // التحقق من أخطاء الصلاحيات
      if (msg.contains('permission denied') || msg.contains('rls')) {
        log('🔒 خطأ في الصلاحيات (RLS): $e');
        throw Exception('خطأ في الصلاحيات: تأكد من إعدادات RLS في Supabase');
      }

      if (msg.contains('jwt expired') || msg.contains('invalid jwt')) {
        log('🔄 انتهت صلاحية JWT، محاولة التجديد...');
        // جدّد الجلسة وحاول تاني
        final session = _supabase.auth.currentSession;
        if (session?.refreshToken != null) {
          await _supabase.auth.refreshSession();
          log('✅ تم تجديد JWT بنجاح');
          return await run(); // retry
        } else {
          log('❌ لا يوجد refresh token');
        }
      }
      rethrow;
    }
  }

  // التحقق من صحة الـ Cache
  bool _isCacheValid() {
    if (_cachedOrders == null || _lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheTimeout;
  }

  // جلب جميع الطلبات وتصنيفها حسب الحالة (للوحة التحكم)
  Future<void> fetchAllOrders({bool forceRefresh = false}) async {
    try {
      // استخدام الـ Cache إذا كان صالحاً
      if (!forceRefresh && _isCacheValid()) {
        log('📦 استخدام البيانات المحفوظة في الـ Cache');
        _emitOrdersFromCache();
        return;
      }

      emit(OrderLoading());
      log('🔍 بدء جلب الطلبات من قاعدة البيانات...');

      // جلب البيانات الأساسية فقط لتحسين الأداء
      final response = await _withRefreshRetry(
        () => _supabase
            .from('customer_orders')
            .select(
                'order_id, order_number, customer_name, customer_phone, service_type, problem_description, status, created_at, updated_at')
            .order('created_at', ascending: false)
            .limit(100), // تحديد عدد الطلبات المحملة
      );

      log('📊 تم جلب ${response.length} طلب من قاعدة البيانات');

      final List<Order> allOrders = (response as List)
          .map((orderData) => Order.fromJson(orderData))
          .toList();

      // حفظ في الـ Cache
      _cachedOrders = allOrders;
      _lastFetchTime = DateTime.now();

      // تصنيف الطلبات حسب الحالة
      final List<Order> currentOrders = allOrders
          .where(
            (order) =>
                order.status == null ||
                order.status == 'pending' ||
                order.status == 'in_progress' ||
                order.status == 'confirmed' ||
                order.status == 'assigned',
          )
          .toList();

      final List<Order> completedOrders =
          allOrders.where((order) => order.status == 'completed').toList();

      final List<Order> cancelledOrders =
          allOrders.where((order) => order.status == 'cancelled').toList();

      // طباعة تفاصيل كل طلب للتصحيح
      for (var order in allOrders) {
        log(
          '📝 طلب: ${order.orderNumber ?? 'بدون رقم'} - الحالة: ${order.status ?? 'null'} - العميل: ${order.customerName ?? 'غير محدد'}',
        );
      }

      emit(
        OrdersLoaded(
          orders: allOrders,
          currentOrders: currentOrders,
          completedOrders: completedOrders,
          cancelledOrders: cancelledOrders,
        ),
      );
    } catch (e) {
      log('❌ خطأ في جلب الطلبات: $e');
      log('🔍 نوع الخطأ: ${e.runtimeType}');
      
      // إظهار التحميل بدلاً من الخطأ وإعادة المحاولة
      emit(OrderLoading());
      
      // انتظار قصير ثم إعادة المحاولة
      await Future.delayed(const Duration(seconds: 3));
      
      // إعادة المحاولة مرة واحدة
      try {
        await fetchAllOrders(forceRefresh: true);
      } catch (retryError) {
        log('❌ فشلت إعادة المحاولة: $retryError');
        // الاستمرار في إظهار التحميل
        emit(OrderLoading());
      }
    }
  }

  // إرسال البيانات من الـ Cache
  void _emitOrdersFromCache() {
    if (_cachedOrders == null) return;

    final allOrders = _cachedOrders!;
    final currentOrders = allOrders
        .where(
          (order) =>
              order.status == null ||
              order.status == 'pending' ||
              order.status == 'in_progress' ||
              order.status == 'confirmed' ||
              order.status == 'assigned',
        )
        .toList();

    final completedOrders =
        allOrders.where((order) => order.status == 'completed').toList();
    final cancelledOrders =
        allOrders.where((order) => order.status == 'cancelled').toList();

    emit(
      OrdersLoaded(
        orders: allOrders,
        currentOrders: currentOrders,
        completedOrders: completedOrders,
        cancelledOrders: cancelledOrders,
      ),
    );
  }

  // جلب الطلبات بناءً على الفلتر
  Future<void> fetchOrdersByStatus(String? status) async {
    try {
      emit(OrderLoading());
      log('📋 جلب الطلبات حسب الحالة: ${status ?? 'الكل'}');

      var query = _supabase.from('customer_orders').select();

      if (status != null && status.isNotEmpty && status != 'all') {
        if (status == 'current') {
          // الطلبات الحالية: null أو pending/in_progress/confirmed/assigned
          query = query.or(
              'status.is.null,status.in.(pending,in_progress,confirmed,assigned)');
        } else {
          query = query.eq('status', status);
        }
      }

      // إضافة ترتيب حسب تاريخ الإنشاء (الأحدث أولاً)
      final orderedQuery = query.order('created_at', ascending: false);

      final response = await _withRefreshRetry(() => orderedQuery);

      final List<Order> filteredOrders = (response as List)
          .map((orderData) => Order.fromJson(orderData))
          .toList();

      log('📊 نتائج الفلتر ${status ?? 'الكل'}: ${filteredOrders.length} عنصر');

      // تصنيف النتائج
      final List<Order> currentOrders = filteredOrders
          .where(
            (order) =>
                order.status == null ||
                order.status == 'pending' ||
                order.status == 'in_progress' ||
                order.status == 'confirmed' ||
                order.status == 'assigned',
          )
          .toList();

      final List<Order> completedOrders =
          filteredOrders.where((order) => order.status == 'completed').toList();

      final List<Order> cancelledOrders =
          filteredOrders.where((order) => order.status == 'cancelled').toList();

      emit(
        OrdersLoaded(
          orders: filteredOrders,
          currentOrders: currentOrders,
          completedOrders: completedOrders,
          cancelledOrders: cancelledOrders,
        ),
      );
    } catch (e) {
      log('❌ خطأ في جلب الطلبات حسب الحالة: $e');
      
      // إظهار التحميل بدلاً من الخطأ وإعادة المحاولة
      emit(OrderLoading());
      
      // انتظار قصير ثم إعادة المحاولة
      await Future.delayed(const Duration(seconds: 2));
      
      // إعادة المحاولة مرة واحدة
      try {
        await fetchOrdersByStatus(status);
      } catch (retryError) {
        log('❌ فشلت إعادة المحاولة: $retryError');
        // الاستمرار في إظهار التحميل
        emit(OrderLoading());
      }
    }
  }

  // إنشاء طلب جديد (للوحة التحكم)
  Future<void> createOrder(Order order) async {
    try {
      emit(OrderCreating());
      log('🔄 بدء إنشاء طلب جديد...');

      // حضّر الـ payload
      final nowIso = DateTime.now().toIso8601String();
      final payload = {
        ...order.toJson(),

        // اضمن حالة ابتدائية لو غير موجودة
        if ((order.status == null) || (order.status!.isEmpty))
          'status': 'pending',

        // timestamps
        'created_at': nowIso,
        'updated_at': nowIso,
      };

      log('📝 بيانات الطلب المرسلة: $payload');

      // INSERT بدون select لتفادي PGRST116
      log('💾 محاولة حفظ الطلب في قاعدة البيانات...');
      final insertResult = await _withRefreshRetry(
          () => _supabase.from('customer_orders').insert(payload));
      log('✅ تم حفظ الطلب بنجاح: $insertResult');

      // قراءة الصف المُنشأ
      log('🔍 محاولة قراءة الطلب المحفوظ...');
      Map<String, dynamic>? row;

      if ((order.orderNumber != null) && order.orderNumber!.trim().isNotEmpty) {
        log('🔍 البحث باستخدام order_number: ${order.orderNumber}');
        row = await _supabase
            .from('customer_orders')
            .select('*')
            .eq('order_number', order.orderNumber!)
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();
        log('📄 نتيجة البحث بـ order_number: $row');
      }

      if (row == null) {
        log('🔍 البحث باستخدام آخر طلب...');
        row = await _supabase
            .from('customer_orders')
            .select('*')
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();
        log('📄 نتيجة البحث بآخر طلب: $row');
      }

      // إرسال الحالة
      if (row != null) {
        log('✅ تم العثور على الطلب، إرسال OrderCreated');
        final newOrder = Order.fromJson(row);
        emit(OrderCreated(newOrder));
      } else {
        log('⚠️ لم يتم العثور على الطلب، استخدام fallback');
        emit(OrderCreated(order));
      }

      // تحديث القوائم والإحصائيات
      log('🔄 تحديث قائمة الطلبات والإحصائيات...');
      await fetchAllOrders();
      await fetchOrderStatistics();
      log('✅ تم تحديث قائمة الطلبات والإحصائيات بنجاح');
    } catch (e, stackTrace) {
      log('❌ خطأ في إنشاء الطلب: $e');
      log('📍 Stack trace: $stackTrace');

      // تحليل نوع الخطأ
      String errorMessage = 'فشل في إنشاء الطلب';
      if (e.toString().contains('JWT')) {
        errorMessage = 'خطأ في المصادقة - يرجى تسجيل الدخول مرة أخرى';
      } else if (e.toString().contains('permission')) {
        errorMessage = 'ليس لديك صلاحية لإنشاء طلبات';
      } else if (e.toString().contains('network')) {
        errorMessage = 'خطأ في الاتصال - تحقق من الإنترنت';
      } else {
        errorMessage = 'فشل في إنشاء الطلب: ${e.toString()}';
      }

      emit(OrderError(errorMessage));
    }
  }

  String kPkColumn = 'order_id';

  // تحديث حالة الطلب مع إعادة المحاولة التلقائية
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    emit(OrderLoading()); // إظهار التحميل بدلاً من الخطأ
    
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);
    
    while (retryCount < maxRetries) {
      try {
        final data = await _withRefreshRetry(() => _supabase.rpc(
              'update_order_status_rpc',
              params: {
                'p_order_id': orderId.trim(),
                'p_new_status': newStatus,
              },
            ));

        // لو وصلت هنا بدون استثناء من الـ RPC، يبقى اتحدّث فعلاً
        final updated = Order.fromJson(data as Map<String, dynamic>);

        emit(OrderUpdated(updated));
        await fetchOrderStatistics();
        return; // نجحت العملية، اخرج من الحلقة
        
      } on PostgrestException catch (e) {
        log('❌ محاولة ${retryCount + 1} فشلت في تحديث الطلب: ${e.message}');
        retryCount++;
        
        if (retryCount >= maxRetries) {
          // بعد استنفاد المحاولات، أظهر التحميل مرة أخرى بدلاً من الخطأ
          emit(OrderLoading());
          // محاولة جلب البيانات مرة أخرى
          await fetchAllOrders(forceRefresh: true);
          return;
        }
        
        await Future.delayed(retryDelay);
      } catch (e) {
        log('❌ محاولة ${retryCount + 1} فشلت في تحديث الطلب: $e');
        retryCount++;
        
        if (retryCount >= maxRetries) {
          // بعد استنفاد المحاولات، أظهر التحميل مرة أخرى بدلاً من الخطأ
          emit(OrderLoading());
          // محاولة جلب البيانات مرة أخرى
          await fetchAllOrders(forceRefresh: true);
          return;
        }
        
        await Future.delayed(retryDelay);
      }
    }
  }

  // حذف الطلب مع إعادة المحاولة التلقائية
  Future<void> deleteOrder(String orderId) async {
    emit(OrderLoading()); // إظهار التحميل بدلاً من الخطأ
    
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);
    
    while (retryCount < maxRetries) {
      try {
        final uid = Supabase.instance.client.auth.currentUser?.id;

        // 1) تأكد إن الصف مرئي قبل الحذف (سياسة SELECT)
        final exists = await _supabase
            .from('customer_orders')
            .select('order_id')
            .eq(kPkColumn, orderId)
            .maybeSingle();

        if (exists == null) {
          throw Exception(
              'الطلب غير مرئي/غير موجود لهذه الجلسة (RLS أو مفتاح خاطئ).');
        }

        // 2) نفّذ الحذف
        await _withRefreshRetry(() =>
            _supabase.from('customer_orders').delete().eq(kPkColumn, orderId));

        emit(OrderDeleted(orderId));

        // إعادة جلب الطلبات والإحصائيات
        await fetchAllOrders();
        await fetchOrderStatistics();
        return; // نجحت العملية، اخرج من الحلقة
        
      } catch (e) {
        log('❌ محاولة ${retryCount + 1} فشلت في حذف الطلب: $e');
        retryCount++;
        
        if (retryCount >= maxRetries) {
          // بعد استنفاد المحاولات، أظهر التحميل مرة أخرى بدلاً من الخطأ
          emit(OrderLoading());
          // محاولة جلب البيانات مرة أخرى
          await fetchAllOrders(forceRefresh: true);
          return;
        }
        
        await Future.delayed(retryDelay);
      }
    }
  }

  // مسح قاعدة البيانات بالكامل
  Future<void> clearAllOrders() async {
    try {
      emit(OrderDeleting());
      log('🗑️ مسح جميع الطلبات من قاعدة البيانات');

      // حذف جميع الطلبات
      await _withRefreshRetry(
          () => _supabase.from('customer_orders').delete().neq('order_id', ''));

      // مسح الـ Cache
      _cachedOrders = null;
      _lastFetchTime = null;

      emit(OrdersLoaded(
        orders: [],
        currentOrders: [],
        completedOrders: [],
        cancelledOrders: [],
      ));

      log('✅ تم مسح جميع الطلبات بنجاح');
    } catch (e) {
      log('❌ خطأ في مسح قاعدة البيانات: $e');
      
      // إظهار التحميل بدلاً من الخطأ
      emit(OrderLoading());
      
      // انتظار قصير ثم إعادة المحاولة
      await Future.delayed(const Duration(seconds: 3));
      
      // إعادة المحاولة مرة واحدة
      try {
        await clearAllOrders();
      } catch (retryError) {
        log('❌ فشلت إعادة المحاولة في مسح البيانات: $retryError');
        // الاستمرار في إظهار التحميل
        emit(OrderLoading());
      }
    }
  }

  // البحث في الطلبات
  Future<void> searchOrders(String query) async {
    try {
      emit(OrderLoading());
      log('🔍 البحث في الطلبات: $query');

      final response = await _withRefreshRetry(
        () => _supabase
            .from('customer_orders')
            .select()
            .or('customer_name.ilike.%$query%,order_number.ilike.%$query%,service_type.ilike.%$query%')
            .order('created_at', ascending: false),
      );

      final List<Order> searchResults = (response as List)
          .map((orderData) => Order.fromJson(orderData))
          .toList();

      log('📊 نتائج البحث: ${searchResults.length} عنصر');

      emit(OrderSearchResults(searchResults, query));
    } catch (e) {
      log('❌ خطأ في البحث: $e');
      emit(OrderError('فشل في البحث: ${e.toString()}'));
    }
  }

  // جلب إحصائيات الطلبات
  Future<void> fetchOrderStatistics() async {
    try {
      log('📊 جلب إحصائيات الطلبات...');

      // استخدام الـ Cache إذا كان متوفراً
      if (_isCacheValid() && _cachedOrders != null) {
        log('📦 حساب الإحصائيات من الـ Cache');
        _calculateAndEmitStatistics(_cachedOrders!);
        return;
      }

      // جلب الحالات فقط لتحسين الأداء
      final response = await _withRefreshRetry(
        () => _supabase.from('customer_orders').select('status'),
      );

      final List<Map<String, dynamic>> orders =
          List<Map<String, dynamic>>.from(response);
      _calculateAndEmitStatisticsFromData(orders);
    } catch (e) {
      log('❌ خطأ في جلب الإحصائيات: $e');
      emit(OrderError('فشل في جلب الإحصائيات: ${e.toString()}'));
    }
  }

  // حساب الإحصائيات من البيانات المحملة
  void _calculateAndEmitStatistics(List<Order> orders) {
    final Map<String, int> statistics = {
      'total': orders.length,
      'pending': orders
          .where((order) => order.status == null || order.status == 'pending')
          .length,
      'in_progress':
          orders.where((order) => order.status == 'in_progress').length,
      'confirmed': orders.where((order) => order.status == 'confirmed').length,
      'completed': orders.where((order) => order.status == 'completed').length,
      'cancelled': orders.where((order) => order.status == 'cancelled').length,
    };

    log('📊 الإحصائيات: $statistics');
    emit(OrderStatisticsLoaded(statistics));
  }

  // حساب الإحصائيات من البيانات الخام
  void _calculateAndEmitStatisticsFromData(List<Map<String, dynamic>> orders) {
    final Map<String, int> statistics = {
      'total': orders.length,
      'pending': orders
          .where((order) =>
              order['status'] == null || order['status'] == 'pending')
          .length,
      'in_progress':
          orders.where((order) => order['status'] == 'in_progress').length,
      'confirmed':
          orders.where((order) => order['status'] == 'confirmed').length,
      'completed':
          orders.where((order) => order['status'] == 'completed').length,
      'cancelled':
          orders.where((order) => order['status'] == 'cancelled').length,
    };

    log('📊 الإحصائيات: $statistics');
    emit(OrderStatisticsLoaded(statistics));
  }

  // إعادة تعيين الحالة
  void resetState() {
    emit(OrderInitial());
  }

  // تصفية الطلبات محلياً (للأداء السريع)
  void filterOrdersLocally(List<Order> orders, String? status) {
    List<Order> filteredOrders;

    if (status == null || status.isEmpty || status == 'all') {
      filteredOrders = orders;
    } else if (status == 'current') {
      filteredOrders = orders
          .where(
            (order) =>
                order.status == null ||
                order.status == 'pending' ||
                order.status == 'in_progress' ||
                order.status == 'confirmed' ||
                order.status == 'assigned',
          )
          .toList();
    } else {
      filteredOrders = orders.where((order) => order.status == status).toList();
    }

    // تصنيف النتائج
    final List<Order> currentOrders = filteredOrders
        .where(
          (order) =>
              order.status == null ||
              order.status == 'pending' ||
              order.status == 'in_progress' ||
              order.status == 'confirmed' ||
              order.status == 'assigned',
        )
        .toList();

    final List<Order> completedOrders =
        filteredOrders.where((order) => order.status == 'completed').toList();

    final List<Order> cancelledOrders =
        filteredOrders.where((order) => order.status == 'cancelled').toList();

    emit(
      OrdersLoaded(
        orders: filteredOrders,
        currentOrders: currentOrders,
        completedOrders: completedOrders,
        cancelledOrders: cancelledOrders,
      ),
    );
  }
}
