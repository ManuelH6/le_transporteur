// apps/admin/lib/pages/users/user_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_le_transporteur/api/v1/admin_api.dart';
import 'package:shared_le_transporteur/models/user.dart';

class UserDetailPage extends StatefulWidget {
  final User user;
  const UserDetailPage({super.key, required this.user});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  final _adminApi = AdminApi();
  late User _user;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  Future<void> _reviewRequest(String status, {String? reason}) async {
    setState(() => _isLoading = true);
    try {
      final updatedUser = await _adminApi.reviewLivreurRequest(_user.id!, status: status, reason: reason);
      setState(() {
        _user = updatedUser;
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Statut mis à jour : $status')));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_user.name)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50.r,
                backgroundImage: _user.profileImageUrl != null ? NetworkImage(_user.profileImageUrl!) : null,
                child: _user.profileImageUrl == null ? Icon(Icons.person, size: 50.r) : null,
              ),
            ),
            SizedBox(height: 20.h),
            _buildInfoTile('Nom', _user.name),
            _buildInfoTile('Email', _user.email),
            _buildInfoTile('Rôle', _user.role ?? 'Non défini'),
            _buildInfoTile('Statut Requête', _user.livreurRequestStatus ?? 'N/A'),
            if (_user.livreurRequestStatus == 'pending') ...[
              SizedBox(height: 30.h),
              const Text('Actions requises', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _reviewRequest('approved'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      child: const Text('Approuver'),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _reviewRequest('rejected', reason: 'Documentation incomplète'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                      child: const Text('Rejeter'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
          Text(value, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500)),
          const Divider(),
        ],
      ),
    );
  }
}
