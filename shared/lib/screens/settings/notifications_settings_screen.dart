import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_le_transporteur/models/user_notification.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  late Box _settingsBox;
  NotificationSettings? _settings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      _settingsBox = await Hive.openBox('settings');
      final push = _settingsBox.get('pushEnabled', defaultValue: true);
      final email = _settingsBox.get('emailEnabled', defaultValue: true);
      final sms = _settingsBox.get('smsEnabled', defaultValue: true);
      
      setState(() {
        _settings = NotificationSettings(
          pushEnabled: push,
          emailEnabled: email,
          smsEnabled: sms,
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleSetting(String type, bool value) async {
    if (_settings == null) return;

    final newSettings = _settings!.copyWith(
      pushEnabled: type == 'push' ? value : _settings!.pushEnabled,
      emailEnabled: type == 'email' ? value : _settings!.emailEnabled,
      smsEnabled: type == 'sms' ? value : _settings!.smsEnabled,
    );

    setState(() => _settings = newSettings);

    try {
      await _settingsBox.put('${type}Enabled', value);
    } catch (e) {
      _loadSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.text,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : AppColors.text, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _settings == null
              ? Center(child: Text("Impossible de charger les paramètres", style: GoogleFonts.poppins(color: isDark ? AppColors.darkText : AppColors.text)))
              : Column(
                  children: [
                    Container(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      padding: EdgeInsets.all(20.w),
                      child: Text(
                        "Gérez la manière dont vous souhaitez être informé des activités de votre compte.",
                        style: GoogleFonts.poppins(fontSize: 14.sp, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildSettingsGroup([
                      _buildSwitchTile(
                        Icons.notifications_active_outlined,
                        "Notifications Push",
                        "Alertes instantanées sur votre téléphone",
                        _settings!.pushEnabled,
                        (val) => _toggleSetting('push', val),
                        isDark,
                      ),
                      _buildSwitchTile(
                        Icons.email_outlined,
                        "Emails",
                        "Résumé et confirmations par mail",
                        _settings!.emailEnabled,
                        (val) => _toggleSetting('email', val),
                        isDark,
                      ),
                      _buildSwitchTile(
                        Icons.sms_outlined,
                        "SMS",
                        "Notifications par message texte",
                        _settings!.smsEnabled,
                        (val) => _toggleSetting('sms', val),
                        isDark,
                      ),
                    ], isDark),
                  ],
                ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children, bool isDark) {
    return Container(
      color: isDark ? AppColors.darkSurface : Colors.white,
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, String subtitle, bool value, Function(bool) onChanged, bool isDark) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title, 
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600, 
          fontSize: 15.sp,
          color: isDark ? AppColors.darkText : AppColors.text,
        )
      ),
      subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 12.sp, color: isDark ? Colors.grey[500] : Colors.grey)),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }
}
