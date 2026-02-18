import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';

enum NotificationType {
  delivery,
  info,
  payment,
  system,
}

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? actionLabel;
  final VoidCallback? onAction;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.actionLabel,
    this.onAction,
  });
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String _selectedFilter = 'Toutes';
  
  // Mock data - À remplacer par des données réelles de l'API
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      type: NotificationType.delivery,
      title: 'Nouvelle livraison disponible',
      message: 'Une livraison à Akwa est disponible. Distance: 2.5 km',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isRead: false,
      actionLabel: 'Voir',
    ),
    NotificationItem(
      id: '2',
      type: NotificationType.delivery,
      title: 'Livraison terminée',
      message: 'Livraison #1234 complétée avec succès. Montant: 2 500 FCFA',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
      actionLabel: 'Détails',
    ),
    NotificationItem(
      id: '3',
      type: NotificationType.payment,
      title: 'Paiement reçu',
      message: 'Votre paiement hebdomadaire de 25 000 FCFA a été effectué',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: true,
      actionLabel: 'Voir',
    ),
    NotificationItem(
      id: '4',
      type: NotificationType.info,
      title: 'Évaluation client',
      message: 'Vous avez reçu une note de 5⭐ de votre dernier client',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
    ),
    NotificationItem(
      id: '5',
      type: NotificationType.system,
      title: 'Mise à jour disponible',
      message: 'Une nouvelle version de l\'application est disponible',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      actionLabel: 'Mettre à jour',
    ),
    NotificationItem(
      id: '6',
      type: NotificationType.delivery,
      title: 'Client en attente',
      message: 'Le client attend votre arrivée. Temps estimé: 5 min',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      isRead: true,
    ),
  ];

  List<NotificationItem> get _filteredNotifications {
    if (_selectedFilter == 'Toutes') {
      return _notifications;
    } else if (_selectedFilter == 'Non lues') {
      return _notifications.where((n) => !n.isRead).toList();
    } else if (_selectedFilter == 'Livraisons') {
      return _notifications.where((n) => n.type == NotificationType.delivery).toList();
    }
    return _notifications;
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

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
      body: Column(
        children: [
          // Filter Chips
          _buildFilterChips(),
          SizedBox(height: 16.h),
          
          // Notifications List
          Expanded(
            child: _filteredNotifications.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                    itemCount: _filteredNotifications.length,
                    separatorBuilder: (context, index) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(_filteredNotifications[index]);
                    },
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
                  setState(() {
                    _selectedFilter = filter;
                  });
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

  Widget _buildNotificationCard(NotificationItem notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFF5252),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Icon(Icons.delete, color: Colors.white, size: 24.sp),
      ),
      onDismissed: (direction) {
        setState(() {
          _notifications.remove(notification);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Notification supprimée",
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppColors.text,
            action: SnackBarAction(
              label: "Annuler",
              textColor: AppColors.primary,
              onPressed: () {
                setState(() {
                  _notifications.add(notification);
                });
              },
            ),
          ),
        );
      },
      child: InkWell(
        onTap: () => _markAsRead(notification),
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : Colors.white,
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
              // Icon
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
              
              // Content
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatTimestamp(notification.timestamp),
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                        if (notification.actionLabel != null)
                          TextButton(
                            onPressed: () {
                              _markAsRead(notification);
                              if (notification.onAction != null) {
                                notification.onAction!();
                              } else {
                                _showActionDialog(notification);
                              }
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              notification.actionLabel!,
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.delivery:
        return Icons.local_shipping;
      case NotificationType.payment:
        return Icons.account_balance_wallet;
      case NotificationType.info:
        return Icons.info;
      case NotificationType.system:
        return Icons.settings;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.delivery:
        return const Color(0xFF4CAF50);
      case NotificationType.payment:
        return const Color(0xFF2196F3);
      case NotificationType.info:
        return const Color(0xFFFFC107);
      case NotificationType.system:
        return const Color(0xFF9C27B0);
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return "À l'instant";
    } else if (difference.inMinutes < 60) {
      return "Il y a ${difference.inMinutes} min";
    } else if (difference.inHours < 24) {
      return "Il y a ${difference.inHours}h";
    } else if (difference.inDays < 7) {
      return "Il y a ${difference.inDays}j";
    } else {
      return "${timestamp.day}/${timestamp.month}/${timestamp.year}";
    }
  }

  void _markAsRead(NotificationItem notification) {
    setState(() {
      final index = _notifications.indexOf(notification);
      if (index != -1) {
        _notifications[index] = NotificationItem(
          id: notification.id,
          type: notification.type,
          title: notification.title,
          message: notification.message,
          timestamp: notification.timestamp,
          isRead: true,
          actionLabel: notification.actionLabel,
          onAction: notification.onAction,
        );
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (int i = 0; i < _notifications.length; i++) {
        _notifications[i] = NotificationItem(
          id: _notifications[i].id,
          type: _notifications[i].type,
          title: _notifications[i].title,
          message: _notifications[i].message,
          timestamp: _notifications[i].timestamp,
          isRead: true,
          actionLabel: _notifications[i].actionLabel,
          onAction: _notifications[i].onAction,
        );
      }
    });
  }

  void _showActionDialog(NotificationItem notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          notification.title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          notification.message,
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Fermer",
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Action - À implémenter",
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: Text(
              notification.actionLabel ?? "OK",
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
