import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/admin_service.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Active', 'Inactive', 'Pending'];
  final List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminService>(context, listen: false).fetchUsers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminService>(
      builder: (context, adminService, child) {
        final rawUsers = adminService.allUsers;
        _users.clear();
        for (final u in rawUsers) {
          _users.add({
            'id': u.id,
            'name': u.name,
            'email': u.email,
            'phone': u.phoneNumber,
            'type': u.userType.toString().split('.').last, // resident, worker, admin
            'status': u.isActive ? 'Active' : 'Inactive',
            'ward': u.wardNumber,
            'joinedDate': "${u.createdAt.month}/${u.createdAt.year}",
          });
        }

        return Scaffold(
          backgroundColor: AppTheme.grey50,
          appBar: AppBar(
            title: const Text(
              'Command Center: Users',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
            ),
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add_alt_1_rounded),
                onPressed: _showAddWorkerDialog,
              ),
              const SizedBox(width: 8),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 4,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(text: 'RESIDENTS'),
                Tab(text: 'WORKERS'),
                Tab(text: 'RECYCLERS'),
                Tab(text: 'ADMINS'),
              ],
            ),
          ),
          body: adminService.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => adminService.fetchUsers(),
                  child: Column(
                    children: [
                      _buildSearchAndFilter(),
                      _buildStatistics(),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildUserList('resident'),
                            _buildUserList('worker'),
                            _buildUserList('recycler'),
                            _buildUserList('admin'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search by name or email...',
                  hintStyle: TextStyle(color: AppTheme.grey400, fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryGreen),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.tune_rounded, color: AppTheme.primaryGreen),
              onSelected: (value) => setState(() => _selectedFilter = value),
              itemBuilder: (_) => _filters
                  .map((filter) => PopupMenuItem(
                        value: filter,
                        child: Text(filter, style: const TextStyle(fontWeight: FontWeight.w500)),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          _statCard('TOTAL', '1.2k', Icons.people_alt_rounded, AppTheme.primaryGreen),
          const SizedBox(width: 10),
          _statCard('ACTIVE', '1.1k', Icons.check_circle_rounded, AppTheme.success),
          const SizedBox(width: 10),
          _statCard('PENDING', '23', Icons.pending_rounded, AppTheme.warning),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.1), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppTheme.grey500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(String userType) {
    final filteredUsers = _users.where((user) {
      final matchesType = user['type'] == userType;
      final matchesSearch = _searchQuery.isEmpty ||
          user['name'].toLowerCase().contains(_searchQuery) ||
          user['email'].toLowerCase().contains(_searchQuery);
      final matchesFilter = _selectedFilter == 'All' ||
          (_selectedFilter == 'Active' && user['status'] == 'Active') ||
          (_selectedFilter == 'Inactive' && user['status'] == 'Inactive') ||
          (_selectedFilter == 'Pending' && user['status'] == 'Pending');
      
      return matchesType && matchesSearch && matchesFilter;
    }).toList();

    if (filteredUsers.isEmpty) {
      return const Center(
        child: Text('No users found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      itemCount: filteredUsers.length,
      itemBuilder: (_, index) => _buildUserCard(filteredUsers[index]),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getUserTypeColor(user['type']).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    user['name'].split(' ').map((e) => e[0]).join(),
                    style: TextStyle(
                      color: _getUserTypeColor(user['type']),
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppTheme.grey900,
                        ),
                      ),
                      Text(
                        user['email'],
                        style: TextStyle(color: AppTheme.grey500, fontSize: 13),
                      ),
                      if (user['ward'] != null)
                        Text(
                          'Ward ${user['ward']}',
                          style: const TextStyle(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                _statusChip(user['status']),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                _iconDetail(Icons.local_phone_rounded, user['phone']),
                const SizedBox(width: 16),
                _iconDetail(Icons.history_rounded, user['joinedDate']),
                const Spacer(),
                PopupMenuButton<String>(
                  onSelected: (action) => _handleUserAction(action, user),
                  icon: const Icon(Icons.more_vert_rounded, color: AppTheme.grey400),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'view', child: Text('View Details')),
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuDivider(),
                    const PopupMenuItem(value: 'activate', child: Text('Activate')),
                    const PopupMenuItem(value: 'deactivate', child: Text('Deactivate')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppTheme.error))),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _iconDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.grey400),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(color: AppTheme.grey600, fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Color _getUserTypeColor(String type) {
    switch (type) {
      case 'resident':
        return AppTheme.info;
      case 'worker':
        return AppTheme.warning;
      case 'recycler':
        return AppTheme.success;
      case 'admin':
        return AppTheme.error;
      default:
        return AppTheme.grey600;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return AppTheme.success;
      case 'Inactive':
        return AppTheme.error;
      case 'Pending':
        return AppTheme.warning;
      default:
        return AppTheme.grey600;
    }
  }

  void _showAddWorkerDialog() {
    final formKey = GlobalKey<FormState>();
    String username = '';
    String email = '';
    String password = '';
    String phone = '';
    String ward = '15';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add HKS Worker'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                  onSaved: (v) => username = v!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                  onSaved: (v) => email = v!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                  onSaved: (v) => password = v!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Phone'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                  onSaved: (v) => phone = v!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Ward'),
                  initialValue: '15',
                  onSaved: (v) => ward = v ?? '15',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                Navigator.pop(ctx);
                final success = await context.read<AdminService>().createHksWorker({
                  'username': username,
                  'email': email,
                  'password': password,
                  'phone': phone,
                  'ward': ward,
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Worker created successfully' : 'Failed to create worker'),
                      backgroundColor: success ? AppTheme.success : AppTheme.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _viewUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${user['name']} Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Email', user['email']),
              _detailRow('Phone', user['phone']),
              _detailRow('Type', user['type']),
              _detailRow('Status', user['status']),
              if (user['ward'] != null) _detailRow('Ward', '${user['ward']}'),
              _detailRow('Joined', user['joinedDate']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _editUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit User'),
        content: const Text('User editing feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleUserAction(String action, Map<String, dynamic> user) {
    switch (action) {
      case 'view':
        _viewUserDetails(user);
        break;
      case 'edit':
        _editUser(user);
        break;
      case 'activate':
        setState(() {
          user['status'] = 'Active';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user['name']} activated')),
        );
        break;
      case 'deactivate':
        setState(() {
          user['status'] = 'Inactive';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user['name']} deactivated')),
        );
        break;
      case 'delete':
        _confirmDeleteUser(user);
        break;
    }
  }

  void _confirmDeleteUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<AdminService>().deleteUser(user['id']);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? '${user['name']} deleted' : 'Failed to delete user'),
                    backgroundColor: success ? AppTheme.success : AppTheme.error,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }

}
