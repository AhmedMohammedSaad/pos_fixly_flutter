import 'package:flutter/material.dart';

import 'orders_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 1; // تغيير الافتراضي إلى الأوردرز (index 1)
  final PageController _pageController =
      PageController(initialPage: 1); // البدء من صفحة الأوردرز

  final List<Widget> _pages = [
    const OrdersPage(),
  ];

  final List<String> _pageTitles = [
    'لوحة التحكم الجديدة',
    'الطلبات',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    Navigator.of(context).pop(); // إغلاق الـ Drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _pageTitles[_selectedIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: _buildDrawer(),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _pages,
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo.shade700,
              Colors.indigo.shade500,
            ],
          ),
        ),
        child: Column(
          children: [
            // رأس الـ Drawer
            Container(
              height: 200,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.store,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'نظام إدارة فكسلي',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'لوحة التحكم الإدارية',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // قائمة العناصر
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 10,
                  ),
                  children: [
                    _buildDrawerItem(
                      icon: Icons.dashboard,
                      title: 'لوحة التحكم',
                      subtitle: 'الإحصائيات والرسوم البيانية',
                      index: 0,
                      isSelected: _selectedIndex == 0,
                    ),
                    const SizedBox(height: 8),
                    _buildDrawerItem(
                      icon: Icons.receipt_long,
                      title: 'الطلبات',
                      subtitle: 'إدارة ومتابعة الطلبات',
                      index: 1,
                      isSelected: _selectedIndex == 1,
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 10),
                    // عناصر إضافية
                    _buildDrawerActionItem(
                      icon: Icons.settings,
                      title: 'الإعدادات',
                      onTap: () {
                        Navigator.of(context).pop();
                        _showComingSoonDialog('الإعدادات');
                      },
                    ),
                    _buildDrawerActionItem(
                      icon: Icons.help_outline,
                      title: 'المساعدة',
                      onTap: () {
                        Navigator.of(context).pop();
                        _showComingSoonDialog('المساعدة');
                      },
                    ),
                    _buildDrawerActionItem(
                      icon: Icons.info_outline,
                      title: 'حول التطبيق',
                      onTap: () {
                        Navigator.of(context).pop();
                        _showAboutDialog();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required int index,
    required bool isSelected,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? Colors.indigo.shade50 : Colors.transparent,
        border: isSelected ? Border.all(color: Colors.indigo.shade200) : null,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.indigo.shade700 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey.shade600,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.indigo.shade700 : Colors.black87,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isSelected ? Colors.indigo.shade500 : Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        onTap: () => _onItemTapped(index),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildDrawerActionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.grey.shade600,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.construction,
              color: Colors.orange.shade600,
            ),
            const SizedBox(width: 8),
            const Text('قريباً'),
          ],
        ),
        content: Text(
          'ميزة "$feature" ستكون متاحة قريباً في التحديثات القادمة.',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.info,
              color: Colors.blue,
            ),
            SizedBox(width: 8),
            Text('حول التطبيق'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'نظام إدارة المطعم',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'الإصدار: 1.0.0',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              'تطبيق شامل لإدارة الطلبات ومتابعة الإحصائيات في المطاعم والمقاهي.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
