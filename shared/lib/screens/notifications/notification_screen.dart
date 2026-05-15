import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_le_transporteur/api/v1/notification_api.dart';
import 'package:shared_le_transporteur/models/user_notification.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationApi _api = NotificationApi();
  List<UserNotification> _notifications = [];
  bool _isLoading = true;
  String _selectedFilter = 'Non lues';

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    try {
      final list = await _api.getNotifications();
      if (!mounted) return;
      setState(() {
        _notifications = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  List<UserNotification> get _filteredNotifications {
    if (_selectedFilter == 'Toutes') return _notifications;
    if (_selectedFilter == 'Non lues') return _notifications.where((n) => !n.isRead).toList();
    if (_selectedFilter == 'Livraisons') {
      return _notifications.where((n) => 
        n.type.toLowerCase().contains('delivery') || 
        n.type.toLowerCase().contains('order') ||
        n.type.toLowerCase().contains('livraison')
      ).toList();
    }
    return _notifications;
  }

  int get _unreadCount {
    return _notifications.where((n) => !n.isRead).length;
  }

  Future<void> _markAsRead(UserNotification item) async {
    if (item.isRead) return;
    try {
      await _api.markAsRead(item.id);
      _fetchNotifications();
    } catch (e) {
      debugPrint("Error markAsRead: $e");
    }
  }

  Future<void> _markAllAsRead() async {
    final unreadNotifications = _notifications.where((n) => !n.isRead).toList();
    if (unreadNotifications.isEmpty) return;

    // Optimistic update
    final originalNotifications = List<UserNotification>.from(_notifications);
    setState(() {
      _notifications = _notifications.map((n) => UserNotification(
        id: n.id,
        title: n.title,
        message: n.message,
        type: n.type,
        isRead: true,
        createdAt: n.createdAt,
      )).toList();
    });

    try {
      // Alternative approach: Mark each notification individually
      await Future.wait(unreadNotifications.map((n) => _api.markAsRead(n.id)));
      
      // Small delay to let backend settle
      await Future.delayed(const Duration(milliseconds: 500));
      _fetchNotifications();
    } catch (e) {
      debugPrint("Error markAllAsRead (loop): $e");
      // Rollback on error
      if (mounted) {
        setState(() {
          _notifications = originalNotifications;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Échec du marquage comme lu. Réessayez.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0EB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.text, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              "Notifications",
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            if (_unreadCount > 0)
              Text(
                "$_unreadCount non lue${_unreadCount > 1 ? 's' : ''}",
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
        centerTitle: true,
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                "Tout lire",
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              _buildFilterChips(),
              SizedBox(height: 16.h),
              Expanded(
                child: _filteredNotifications.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _fetchNotifications,
                        child: ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                          itemCount: _filteredNotifications.length,
                          separatorBuilder: (context, index) => SizedBox(height: 12.h),
                          itemBuilder: (context, index) {
                            return _buildNotificationCard(_filteredNotifications[index]);
                          },
                        ),
                      ),
              ),
            ],
          ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Toutes', 'Non lues', 'Livraisons'];
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: FilterChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedFilter = filter);
                },
                labelStyle: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.text,
                ),
                backgroundColor: Colors.grey[200],
                selectedColor: AppColors.primary,
                checkmarkColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(UserNotification notification) {
    return InkWell(
      onTap: () => _markAsRead(notification),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: notification.isRead 
                ? Colors.transparent 
                : AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: _getNotificationColor(notification.type).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                _getNotificationIcon(notification.type),
                color: _getNotificationColor(notification.type),
                size: 24.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    notification.message,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    _formatTimestamp(notification.createdAt),
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _fetchNotifications,
      child: ListView(
        children: [
          SizedBox(height: 100.h),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  size: 80.sp,
                  color: Colors.grey[300],
                ),
                SizedBox(height: 16.h),
                Text(
                  "Aucune notification",
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Vous n'avez pas de notifications pour le moment",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('delivery') || t.contains('livraison') || t.contains('order')) return Icons.motorcycle;
    if (t.contains('payment') || t.contains('paiement')) return Icons.account_balance_wallet;
    if (t.contains('info')) return Icons.info;
    return Icons.notifications;
  }

  Color _getNotificationColor(String type) {
    final t = type.toLowerCase();
    if (t.contains('delivery') || t.contains('livraison') || t.contains('order')) return const Color(0xFF4CAF50);
    if (t.contains('payment') || t.contains('paiement')) return const Color(0xFF2196F3);
    if (t.contains('info')) return const Color(0xFFFFC107);
    return AppColors.primary;
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inMinutes < 1) return "À l'instant";
    if (difference.inMinutes < 60) return "Il y a ${difference.inMinutes} min";
    if (difference.inHours < 24) return "Il y a ${difference.inHours}h";
    if (difference.inDays < 7) return "Il y a ${difference.inDays}j";
    return "${timestamp.day}/${timestamp.month}/${timestamp.year}";
  }
}
