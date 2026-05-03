import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_le_transporteur/api/v1/notification_api.dart';
import 'package:shared_le_transporteur/screens/notifications/notification_screen.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/models/user_notification.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  final NotificationApi _api = NotificationApi();
  Timer? _timer;
  int _unreadCount = 0;
  String? _lastNotificationId;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _checkNotifications();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkNotifications();
    });
  }

  Future<void> _checkNotifications() async {
    try {
      final notifications = await _api.getNotifications();
      if (!mounted) return;

      final unread = notifications.where((n) => !n.isRead).toList();
      
      if (unread.isNotEmpty) {
        final latest = unread.first;
        if (_lastNotificationId != null && latest.id != _lastNotificationId) {
          // New notification arrived!
          _showNewNotificationAlert(latest);
        }
        _lastNotificationId = latest.id;
      }

      setState(() {
        _unreadCount = unread.length;
      });
    } catch (e) {
      debugPrint("Error polling notifications: $e");
    }
  }

  void _showNewNotificationAlert(UserNotification notification) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.white),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(notification.message, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: "Voir",
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationScreen()),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.notifications_none, color: AppColors.text, size: 24.sp),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationScreen()),
            ).then((_) => _checkNotifications());
          },
        ),
        if (_unreadCount > 0)
          Positioned(
            top: 10.h,
            right: 10.w,
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                _unreadCount > 9 ? '9+' : _unreadCount.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

