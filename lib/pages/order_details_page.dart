import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/order_model.dart';
import '../cubit/order_cubit.dart';
import '../cubit/order_state.dart';

class OrderDetailsPage extends StatefulWidget {
  final Order order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  // ignore: library_private_types_in_public_api
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late Order _order;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  void _updateOrderStatus(String newStatus) {
    context.read<OrderCubit>().updateOrderStatus(_order.orderId!, newStatus);
  }

  void _deleteOrder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف هذا الطلب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<OrderCubit>().deleteOrder(_order.orderId!);
              Navigator.pop(context);
            },
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderCubit, OrderState>(
      listenWhen: (previous, current) =>
          current is OrderUpdated ||
          current is OrderDeleted ||
          current is OrderError,
      buildWhen: (previous, current) =>
          current is OrdersLoaded || current is OrderUpdated,
      listener: (context, state) {
        if (state is OrderUpdated) {
          setState(() {
            _order = state.order;
          });
          // إعادة جلب البيانات لضمان التحديث
          context.read<OrderCubit>().fetchAllOrders(forceRefresh: true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم تحديث حالة الطلب بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is OrderDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم حذف الطلب بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
        // إزالة عرض رسائل الخطأ - سيتم إظهار التحميل بدلاً منها
        // else if (state is OrderError) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //       content: Text('خطأ: ${state.message}'),
        //       backgroundColor: Colors.red,
        //     ),
        //   );
        // }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text('تفاصيل الطلب ${_order.orderNumber ?? 'غير محدد'}'),
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteOrder();
                  } else {
                    _updateOrderStatus(value);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'pending',
                    child: Row(
                      children: [
                        Icon(Icons.pending, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('في الانتظار'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'reviewed',
                    child: Row(
                      children: [
                        Icon(Icons.rate_review, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('تم المراجعة'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'in_progress',
                    child: Row(
                      children: [
                        Icon(Icons.work, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('قيد التنفيذ'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'completed',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text('مكتمل'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'cancelled',
                    child: Row(
                      children: [
                        Icon(Icons.cancel, color: Colors.red),
                        SizedBox(width: 8),
                        Text('ملغي'),
                      ],
                    ),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('حذف', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSectionCard(
                  title: 'حالة الطلب والأولوية',
                  icon: Icons.info,
                  children: [
                    _buildInfoRow('الحالة', _order.status ?? 'غير محدد'),
                    _buildInfoRow('الأولوية', _order.urgencyLevel),
                    _buildInfoRow(
                        'رقم الطلب', _order.orderNumber ?? 'غير محدد'),
                  ],
                ),
                SizedBox(height: 16),
                _buildSectionCard(
                  title: 'معلومات العميل',
                  icon: Icons.person,
                  children: [
                    _buildInfoRow('الاسم', _order.customerName ?? 'غير محدد'),
                    _buildInfoRow(
                        'رقم الهاتف', _order.customerPhone ?? 'غير محدد'),
                    _buildInfoRow(
                        'العنوان', _order.customerAddress ?? 'غير محدد'),
                  ],
                ),
                SizedBox(height: 16),
                _buildSectionCard(
                  title: 'تفاصيل الخدمة',
                  icon: Icons.build,
                  children: [
                    _buildInfoRow(
                        'نوع الخدمة', _order.serviceType ?? 'غير محدد'),
                    _buildInfoRow(
                        'وصف المشكلة', _order.problemDescription ?? 'غير محدد'),
                  ],
                ),
                SizedBox(height: 16),
                _buildSectionCard(
                  title: 'معلومات الموعد',
                  icon: Icons.schedule,
                  children: [
                    _buildInfoRow(
                        'التاريخ المفضل',
                        _order.preferredDate?.toString().split(' ')[0] ??
                            'غير محدد'),
                    _buildInfoRow(
                        'الوقت المفضل', _order.preferredTimeSlot ?? 'غير محدد'),
                  ],
                ),
                SizedBox(height: 16),
                _buildSectionCard(
                  title: 'التواريخ المهمة',
                  icon: Icons.calendar_today,
                  children: [
                    _buildInfoRow(
                        'تاريخ الإنشاء',
                        _order.createdAt?.toString().split(' ')[0] ??
                            'غير محدد'),
                    _buildInfoRow(
                        'آخر تحديث',
                        _order.updatedAt?.toString().split(' ')[0] ??
                            'غير محدد'),
                    _buildInfoRow(
                        'الميزانية المقدرة',
                        _order.estimatedBudget != null
                            ? '${_order.estimatedBudget} ريال'
                            : 'غير محدد'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue[600]),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
