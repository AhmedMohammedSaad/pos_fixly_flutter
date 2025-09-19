import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/order_model.dart';
import '../cubit/order_cubit.dart';
import '../cubit/order_state.dart';

class OrderCard extends StatefulWidget {
  final Order order;
  final VoidCallback onTap;
  final Function(String) onStatusChanged;
  final VoidCallback onDelete;
  final bool isGridView;

  const OrderCard({
    Key? key,
    required this.order,
    required this.onTap,
    required this.onStatusChanged,
    required this.onDelete,
    this.isGridView = true,
  }) : super(key: key);

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  bool _isUpdating = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'reviewed':
        return const Color(0xFF3B82F6);
      case 'quoted':
        return const Color(0xFF8B5CF6);
      case 'in_progress':
        return const Color(0xFF6366F1);
      case 'completed':
        return const Color(0xFF10B981);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency) {
      case 'low':
        return const Color(0xFF10B981);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'high':
        return const Color(0xFFEF4444);
      case 'urgent':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  IconData _getServiceIcon(String? serviceType) {
    switch (serviceType?.toLowerCase()) {
      case 'كهرباء':
        return Icons.electrical_services;
      case 'سباكة':
        return Icons.plumbing;
      case 'تكييف':
        return Icons.ac_unit;
      case 'دهان':
        return Icons.format_paint;
      case 'نجارة':
        return Icons.carpenter;
      default:
        return Icons.build;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderCubit, OrderState>(
      listener: (context, state) {
        if (state is OrderUpdating) {
          setState(() {
            _isUpdating = true;
          });
        } else if (state is OrderDeleting) {
          setState(() {
            _isDeleting = true;
          });
        } else if (state is OrderUpdated ||
            state is OrderDeleted ||
            state is OrderError) {
          setState(() {
            _isUpdating = false;
            _isDeleting = false;
          });
        }
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTapDown: (_) {
                setState(() {
                  _isPressed = true;
                });
                _animationController.forward();
              },
              onTapUp: (_) {
                setState(() {
                  _isPressed = false;
                });
                _animationController.reverse();
                widget.onTap();
              },
              onTapCancel: () {
                setState(() {
                  _isPressed = false;
                });
                _animationController.reverse();
              },
              child: Container(
                margin: widget.isGridView
                    ? const EdgeInsets.all(6)
                    : const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      _getStatusColor(widget.order.status).withOpacity(0.03),
                      Colors.white,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _getStatusColor(widget.order.status)
                          .withOpacity(0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                  border: Border.all(
                    color:
                        _getStatusColor(widget.order.status).withOpacity(0.15),
                    width: 1.5,
                  ),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // رأس البطاقة
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      _getStatusColor(widget.order.status)
                                          .withOpacity(0.12),
                                      _getStatusColor(widget.order.status)
                                          .withOpacity(0.06),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          _getStatusColor(widget.order.status)
                                              .withOpacity(0.15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                      spreadRadius: 0,
                                    ),
                                  ],
                                  border: Border.all(
                                    color: _getStatusColor(widget.order.status)
                                        .withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  _getServiceIcon(widget.order.serviceType),
                                  color: _getStatusColor(widget.order.status),
                                  size: widget.isGridView ? 24 : 28,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.order.orderNumber ?? 'غير محدد',
                                      style: TextStyle(
                                        fontSize: widget.isGridView ? 17 : 19,
                                        fontWeight: FontWeight.w700,
                                        color: _getStatusColor(
                                            widget.order.status),
                                        letterSpacing: 0.3,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (widget.order.serviceType != null)
                                      Text(
                                        widget.order.serviceType!,
                                        style: TextStyle(
                                          fontSize: widget.isGridView ? 13 : 15,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // معلومات العميل
                          if (widget.order.customerName != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.person_outline_rounded,
                                      size: widget.isGridView ? 16 : 18,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      widget.order.customerName!,
                                      style: TextStyle(
                                        fontSize: widget.isGridView ? 14 : 16,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (widget.order.customerName != null)
                            const SizedBox(height: 10),
                          // الوصف
                          if (widget.order.problemDescription != null)
                            Text(
                              widget.order.problemDescription!,
                              style: TextStyle(
                                fontSize: widget.isGridView ? 13 : 15,
                                color: Colors.grey.shade600,
                                height: 1.4,
                              ),
                              maxLines: widget.isGridView ? 2 : 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          if (widget.order.problemDescription != null)
                            const SizedBox(height: 16),
                          // الحالة والأولوية
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // حالة الطلب
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      _getStatusColor(widget.order.status),
                                      _getStatusColor(widget.order.status)
                                          .withOpacity(0.85),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          _getStatusColor(widget.order.status)
                                              .withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  _getStatusText(widget.order.status),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: widget.isGridView ? 12 : 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              // مؤشر الأولوية
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      _getUrgencyColor(widget.order.urgencyLevel)
                                          .withOpacity(0.15),
                                      _getUrgencyColor(widget.order.urgencyLevel)
                                          .withOpacity(0.08),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _getUrgencyColor(
                                        widget.order.urgencyLevel)
                                        .withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getUrgencyColor(
                                          widget.order.urgencyLevel)
                                          .withOpacity(0.2),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  _getUrgencyText(widget.order.urgencyLevel),
                                  style: TextStyle(
                                    color: _getUrgencyColor(
                                        widget.order.urgencyLevel),
                                    fontSize: widget.isGridView ? 10 : 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // أزرار تغيير الحالة
                          Column(
                            children: [
                              // الصف الأول: pending, reviewed, quoted
                              Row(
                                children: [
                                  _buildStatusButton(
                                    '1. في الانتظار',
                                    'pending',
                                    Colors.orange,
                                    Icons.schedule,
                                  ),
                                  const SizedBox(width: 4),
                                  _buildStatusButton(
                                    '2. تم المراجعة',
                                    'reviewed',
                                    Colors.blue,
                                    Icons.visibility,
                                  ),
                                  const SizedBox(width: 4),
                                  _buildStatusButton(
                                    '3. تم التسعير',
                                    'quoted',
                                    Colors.purple,
                                    Icons.attach_money,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              // الصف الثاني: in_progress, completed, cancelled
                              Row(
                                children: [
                                  _buildStatusButton(
                                    '4. قيد التنفيذ',
                                    'in_progress',
                                    Colors.indigo,
                                    Icons.work,
                                  ),
                                  const SizedBox(width: 4),
                                  _buildStatusButton(
                                    '5. مكتمل',
                                    'completed',
                                    Colors.green,
                                    Icons.check_circle,
                                  ),
                                  const SizedBox(width: 4),
                                  _buildStatusButton(
                                    '6. ملغي',
                                    'cancelled',
                                    Colors.red,
                                    Icons.cancel,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // زر الحذف في الأعلى على اليمين
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFFE53E3E),
                              const Color(0xFFE53E3E).withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE53E3E).withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _isUpdating || _isDeleting
                                ? null
                                : () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('تأكيد الحذف'),
                                          content: const Text(
                                            'هل أنت متأكد من حذف هذا الطلب نهائياً؟\nلا يمكن التراجع عن هذا الإجراء.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('إلغاء'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                widget.onDelete();
                                              },
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.red,
                                              ),
                                              child: const Text('حذف'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                            child: _isDeleting
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusButton(
      String text, String status, Color color, IconData icon) {
    final isCurrentStatus = widget.order.status == status;
    final isDisabled = _isUpdating || _isDeleting;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          gradient: isCurrentStatus
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color,
                    color.withOpacity(0.85),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isDisabled ? Colors.grey.shade100 : color.withOpacity(0.08),
                    isDisabled ? Colors.grey.shade50 : color.withOpacity(0.04),
                  ],
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrentStatus
                ? color
                : (isDisabled ? Colors.grey.shade300 : color.withOpacity(0.25)),
            width: isCurrentStatus ? 2 : 1.5,
          ),
          boxShadow: isCurrentStatus
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                    spreadRadius: 0,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isDisabled || isCurrentStatus
                ? null
                : () {
                    widget.onStatusChanged(status);
                  },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isCurrentStatus
                        ? Colors.white
                        : (isDisabled ? Colors.grey.shade500 : color),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 11,
                      color: isCurrentStatus
                          ? Colors.white
                          : (isDisabled ? Colors.grey.shade500 : color),
                      fontWeight:
                          isCurrentStatus ? FontWeight.w700 : FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'pending':
        return 'في الانتظار';
      case 'reviewed':
        return 'تم المراجعة';
      case 'quoted':
        return 'تم التسعير';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return 'غير محدد';
    }
  }

  String _getUrgencyText(String urgency) {
    switch (urgency) {
      case 'low':
        return 'منخفضة';
      case 'medium':
        return 'متوسطة';
      case 'high':
        return 'عالية';
      case 'urgent':
        return 'عاجل';
      default:
        return 'متوسطة';
    }
  }
}
