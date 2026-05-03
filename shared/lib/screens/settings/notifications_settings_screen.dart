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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _settings == null
              ? Center(child: Text("Impossible de charger les paramètres", style: GoogleFonts.poppins()))
              : Column(
                  children: [
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(20.w),
                      child: Text(
                        "Gérez la manière dont vous souhaitez être informé des activités de votre compte.",
                        style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[600]),
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
                      ),
                      _buildSwitchTile(
                        Icons.email_outlined,
                        "Emails",
                        "Résumé et confirmations par mail",
                        _settings!.emailEnabled,
                        (val) => _toggleSetting('email', val),
                      ),
                      _buildSwitchTile(
                        Icons.sms_outlined,
                        "SMS",
                        "Notifications par message texte",
                        _settings!.smsEnabled,
                        (val) => _toggleSetting('sms', val),
                      ),
                    ]),
                  ],
                ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      color: Colors.white,
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, String subtitle, bool value, Function(bool) onChanged) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15.sp)),
      subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey)),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }
}
