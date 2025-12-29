import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

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
    _users.addAll(_getMockUsers());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Residents'),
            Tab(text: 'Workers'),
            Tab(text: 'Recyclers'),
            Tab(text: 'Admins'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddUserDialog,
          ),
        ],
      ),
      body: Column(
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
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search users...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          const SizedBox(width: AppTheme.spacingS),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (_) => _filters
                .map((filter) => PopupMenuItem(
                      value: filter,
                      child: Text(filter),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
      child: Row(
        children: [
          _statCard('Total Users', '1,247', Icons.people, AppTheme.primaryGreen),
          const SizedBox(width: AppTheme.spacingS),
          _statCard('Active', '1,156', Icons.check_circle, AppTheme.success),
          const SizedBox(width: AppTheme.spacingS),
          _statCard('Pending', '23', Icons.schedule, AppTheme.warning),
          const SizedBox(width: AppTheme.spacingS),
          _statCard('Inactive', '68', Icons.cancel, AppTheme.error),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.grey600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
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
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getUserTypeColor(user['type']),
                  child: Text(
                    user['name'].split(' ').map((e) => e[0]).join(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(user['email']),
                      Text(
                        user['ward'] != null ? 'Ward ${user['ward']}' : 'Ward N/A',
                        style: TextStyle(
                          color: AppTheme.grey600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingS,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(user['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Text(
                    user['status'],
                    style: TextStyle(
                      color: _getStatusColor(user['status']),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: AppTheme.grey600),
                const SizedBox(width: AppTheme.spacingS),
                Text(user['phone']),
                const SizedBox(width: AppTheme.spacingL),
                Icon(Icons.calendar_today, size: 16, color: AppTheme.grey600),
                const SizedBox(width: AppTheme.spacingS),
                Text(user['joinedDate']),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _viewUserDetails(user),
                    child: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _editUser(user),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingS),
                PopupMenuButton<String>(
                  onSelected: (action) => _handleUserAction(action, user),
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'activate',
                      child: Text('Activate'),
                    ),
                    const PopupMenuItem(
                      value: 'deactivate',
                      child: Text('Deactivate'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
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

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New User'),
        content: const Text('User registration feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
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
      builder: (_) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _users.remove(user);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${user['name']} deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMockUsers() {
    return [
      {
        'name': 'John Doe',
        'email': 'john.doe@email.com',
        'phone': '+91 9876543210',
        'type': 'resident',
        'status': 'Active',
        'ward': 15,
        'joinedDate': 'Jan 2024',
      },
      {
        'name': 'Jane Smith',
        'email': 'jane.smith@email.com',
        'phone': '+91 9876543211',
        'type': 'resident',
        'status': 'Active',
        'ward': 12,
        'joinedDate': 'Feb 2024',
      },
      {
        'name': 'Mike Worker',
        'email': 'mike.worker@kozhikode.gov',
        'phone': '+91 9876543212',
        'type': 'worker',
        'status': 'Active',
        'ward': null,
        'joinedDate': 'Mar 2024',
      },
      {
        'name': 'Sarah Recycler',
        'email': 'sarah@ecorecycle.com',
        'phone': '+91 9876543213',
        'type': 'recycler',
        'status': 'Active',
        'ward': null,
        'joinedDate': 'Apr 2024',
      },
      {
        'name': 'Admin User',
        'email': 'admin@kozhikode.gov',
        'phone': '+91 9876543214',
        'type': 'admin',
        'status': 'Active',
        'ward': null,
        'joinedDate': 'Jan 2024',
      },
    ];
  }
}
