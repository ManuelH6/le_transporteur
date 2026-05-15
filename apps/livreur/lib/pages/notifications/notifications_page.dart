import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/api/v1/notification_api.dart';
import 'package:shared_le_transporteur/models/user_notification.dart';
import 'package:shared_le_transporteur/core/widgets/skeleton_loader.dart';
import 'package:shared_le_transporteur/core/widgets/empty_state.dart';
import 'package:ms_undraw/ms_undraw.dart';
import 'package:flutter/services.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<UserNotification> _notifications = [];
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'Non lues'; // Default to Unread

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final notifications = await NotificationApi().getNotifications();
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<UserNotification> get _filteredNotifications {
    if (_selectedFilter == 'Toutes') return _notifications;
    if (_selectedFilter == 'Non lues') return _notifications.where((n) => !n.isRead).toList();
    if (_selectedFilter == 'Livraisons') return _notifications.where((n) => n.type.toLowerCase().contains('delivery') || n.type.toLowerCase().contains('livraison')).toList();
    return _notifications;
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> _markAsRead(UserNotification notification) async {
    if (notification.isRead) return;
    HapticFeedback.lightImpact();
    try {
      await NotificationApi().markAsRead(notification.id);
      _fetchNotifications();
    } catch (e) {
      debugPrint("Error marking as read: $e");
    }
  }

  Future<void> _markAllAsRead() async {
    HapticFeedback.mediumImpact();
    try {
      await NotificationApi().markAllAsRead();
      _fetchNotifications();
    } catch (e) {
      debugPrint("Error marking all as read: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? AppColors.darkText : AppColors.text, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Notifications",
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.text,
          ),
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
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _isLoading 
                ? _buildLoadingState()
                : _filteredNotifications.isEmpty
                    ? EmptyState(
                        illustration: UnDrawIllustration.notifications,
                        title: "Rien à signaler",
                        description: _selectedFilter == 'Non lues' 
                            ? "Vous avez lu toutes vos notifications." 
                            : "Aucune notification trouvée ici.",
                        buttonText: "Actualiser",
                        onButtonPressed: _fetchNotifications,
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchNotifications,
                        color: AppColors.primary,
                        child: ListView.separated(
                          padding: EdgeInsets.all(20.w),
                          itemCount: _filteredNotifications.length,
                          separatorBuilder: (context, index) => SizedBox(height: 12.h),
                          itemBuilder: (context, index) => _buildNotificationCard(_filteredNotifications[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: const SkeletonCard(),
      ),
    );
  }

  Widget _buildFilterChips() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filters = ['Non lues', 'Toutes', 'Livraisons'];
    return Container(
      width: double.infinity,
      color: isDark ? AppColors.darkSurface : Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: ChoiceChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedFilter = filter);
                  }
                },
                labelStyle: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : AppColors.text),
                ),
                backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
                selectedColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(UserNotification notification) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () => _markAsRead(notification),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: !notification.isRead 
                ? AppColors.primary.withOpacity(0.3) 
                : (isDark ? Colors.grey[850]! : Colors.transparent),
            width: 1.5,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: _getNotificationColor(notification.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                _getNotificationIcon(notification.type),
                color: _getNotificationColor(notification.type),
                size: 22.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                      color: isDark ? AppColors.darkText : AppColors.text,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    notification.message,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    _formatTimestamp(notification.createdAt),
                    style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                margin: EdgeInsets.only(top: 4.h),
                width: 8.w,
                height: 8.w,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('delivery') || t.contains('livraison')) return Icons.motorcycle; // Use motorcycle as requested
    if (t.contains('payment') || t.contains('paiement')) return Icons.account_balance_wallet;
    if (t.contains('info')) return Icons.info_outline;
    return Icons.notifications_none;
  }

  Color _getNotificationColor(String type) {
    final t = type.toLowerCase();
    if (t.contains('delivery') || t.contains('livraison')) return Colors.green;
    if (t.contains('payment') || t.contains('paiement')) return Colors.blue;
    if (t.contains('info')) return Colors.orange;
    return AppColors.primary;
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inMinutes < 60) return "Il y a ${diff.inMinutes} min";
    if (diff.inHours < 24) return "Il y a ${diff.inHours}h";
    return "${timestamp.day}/${timestamp.month}/${timestamp.year}";
  }
}
