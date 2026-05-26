// apps/admin/lib/pages/users/user_management_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_le_transporteur/api/v1/admin_api.dart';
import 'package:shared_le_transporteur/models/user.dart';
import 'package:admin_le_transporteur/pages/users/user_detail_page.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _adminApi = AdminApi();
  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _adminApi.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<User> _filterUsers(int tabIndex) {
    switch (tabIndex) {
      case 1: return _users.where((u) => u.role == 'client').toList();
      case 2: return _users.where((u) => u.role == 'livreur').toList();
      case 3: return _users.where((u) => u.livreurRequestStatus == 'pending').toList();
      default: return _users;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Utilisateurs'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.orange,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.orange,
          tabs: const [
            Tab(text: 'Tous'),
            Tab(text: 'Clients'),
            Tab(text: 'Livreurs'),
            Tab(text: 'En attente'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildUserList(0),
                _buildUserList(1),
                _buildUserList(2),
                _buildUserList(3),
              ],
            ),
    );
  }

  Widget _buildUserList(int index) {
    final filtered = _filterUsers(index);
    if (filtered.isEmpty) {
      return const Center(child: Text('Aucun utilisateur trouvé'));
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.separated(
        itemCount: filtered.length,
        padding: EdgeInsets.all(16.w),
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, i) {
          final user = filtered[i];
          return _buildUserCard(user);
        },
      ),
    );
  }

  Widget _buildUserCard(User user) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: user.profileImageUrl != null ? NetworkImage(user.profileImageUrl!) : null,
            child: user.profileImageUrl == null ? const Icon(Icons.person) : null,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(user.email, style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
              ],
            ),
          ),
          _buildStatusBadge(user),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserDetailPage(user: user),
                ),
              ).then((_) => _loadUsers());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(User user) {
    Color color = Colors.grey;
    String text = user.role ?? 'User';

    if (user.livreurRequestStatus == 'pending') {
      color = Colors.orange;
      text = 'Attente';
    } else if (user.role == 'admin') {
      color = Colors.blue;
      text = 'Admin';
    } else if (user.role == 'livreur') {
      color = Colors.green;
      text = 'Livreur';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10.sp, fontWeight: FontWeight.bold),
      ),
    );
  }
}
