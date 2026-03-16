import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/admin_service.dart';
import '../../models/user.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminService>(context, listen: false).fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminService>(
      builder: (context, adminService, child) {
        final rawUsers = adminService.allUsers;

        return Scaffold(
          backgroundColor: AppTheme.grey50,
          appBar: AppBar(
            title: const Text('User Registry'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: FilledButton.icon(
                  onPressed: _showAddWorkerDialog,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('New Worker'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryEmerald,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: AppTheme.primaryEmerald,
              indicatorWeight: 3,
              labelColor: AppTheme.grey900,
              unselectedLabelColor: AppTheme.grey400,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              tabs: const [
                Tab(text: 'RESIDENTS'),
                Tab(text: 'COLLECTION WORKERS'),
                Tab(text: 'RECYCLERS'),
                Tab(text: 'ADMINISTRATORS'),
              ],
            ),
          ),
          body: Column(
            children: [
              _buildControlBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUserTable(rawUsers, UserType.resident),
                    _buildUserTable(rawUsers, UserType.worker),
                    _buildUserTable(rawUsers, UserType.recycler),
                    _buildUserTable(rawUsers, UserType.admin),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.grey100)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search by UID, name, or metadata...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                fillColor: AppTheme.grey50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 16),
          _buildFilterChip('Active Nodes'),
          const SizedBox(width: 8),
          _buildFilterChip('Pending Approval'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.grey50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.grey200),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.grey700)),
    );
  }

  Widget _buildUserTable(List<User> users, UserType type) {
    final filteredUsers = users.where((u) {
      final matchesType = u.userType == type;
      final matchesSearch = _searchQuery.isEmpty || 
          u.name.toLowerCase().contains(_searchQuery) || 
          u.email.toLowerCase().contains(_searchQuery);
      return matchesType && matchesSearch;
    }).toList();

    if (filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_off_rounded, size: 64, color: AppTheme.grey200),
            const SizedBox(height: 16),
            const Text('No records match your criteria', style: TextStyle(color: AppTheme.grey500, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) => _buildUserRow(filteredUsers[index]),
    );
  }

  Widget _buildUserRow(User user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.grey100),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.grey100,
            child: Text(user.name[0].toUpperCase(), style: const TextStyle(color: AppTheme.grey700, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.grey900)),
                Text(user.email, style: const TextStyle(fontSize: 12, color: AppTheme.grey500)),
              ],
            ),
          ),
          SizedBox(
            width: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('WARD / AREA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.grey400)),
                Text(user.wardNumber ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.grey700)),
              ],
            ),
          ),
          _buildStatusBadge(user.isActive),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded, color: AppTheme.grey400),
            onPressed: () => _showUserActions(user),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.success.withValues(alpha: 0.1) : AppTheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isActive ? 'ACTIVE' : 'SUSPENDED',
        style: TextStyle(color: isActive ? AppTheme.success : AppTheme.error, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }

  void _showUserActions(User user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_note_rounded, color: AppTheme.info),
              title: const Text('Update Profile Data', style: TextStyle(fontWeight: FontWeight.w700)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.lock_reset_rounded, color: AppTheme.warning),
              title: const Text('Reset Access Credentials', style: TextStyle(fontWeight: FontWeight.w700)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.no_accounts_rounded, color: AppTheme.error),
              title: const Text('Deactivate Identity', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.error)),
              onTap: () async {
                Navigator.pop(context);
                final success = await context.read<AdminService>().deleteUser(user.id);
                if (context.mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Identity deactivated successfully')));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWorkerDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final wardController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 32, right: 32, top: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Onboard New Worker', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
            const Text('Add a new Haritha Karma Sena (HKS) member to the field force.', style: TextStyle(color: AppTheme.grey400, fontSize: 13)),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name', hintText: 'Enter worker name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email Address', hintText: 'worker@example.com'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number', hintText: '+91 XXXXX XXXXX'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: wardController,
              decoration: const InputDecoration(labelText: 'Assigned Ward', hintText: 'e.g. 15'),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final success = await context.read<AdminService>().createHksWorker({
                    'name': nameController.text,
                    'email': emailController.text,
                    'phone': phoneController.text,
                    'ward': wardController.text,
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Worker onboarded successfully')));
                    }
                  }
                },
                child: const Text('Provision Identity'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
