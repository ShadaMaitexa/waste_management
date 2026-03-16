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
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(140),
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.slateGradient,
              ),
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    scrolledUnderElevation: 0,
                    title: const Text(
                      'User Registry',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        color: Colors.white,
                        letterSpacing: -0.8,
                      ),
                    ),
                    foregroundColor: Colors.white,
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: FilledButton.icon(
                          onPressed: _showAddWorkerDialog,
                          icon: const Icon(Icons.add_rounded, size: 20, color: Colors.white),
                          label: const Text('NEW WORKER', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.primaryEmerald,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicatorColor: AppTheme.primaryEmerald,
                    indicatorWeight: 4,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withValues(alpha: 0.5),
                    labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.8),
                    dividerColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    tabs: const [
                      Tab(text: 'RESIDENTS'),
                      Tab(text: 'WORKERS'),
                      Tab(text: 'RECYCLERS'),
                      Tab(text: 'ADMINS'),
                    ],
                  ),
                ],
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.grey100)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search by UID, name, or metadata...',
                hintStyle: const TextStyle(color: AppTheme.grey400, fontSize: 13, fontWeight: FontWeight.w500),
                prefixIcon: const Icon(Icons.search_rounded, size: 22, color: AppTheme.grey400),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                fillColor: AppTheme.grey50,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 16),
          _buildFilterChip('Active Nodes', true),
          const SizedBox(width: 10),
          _buildFilterChip('Pending Approval', false),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryEmerald.withValues(alpha: 0.05) : AppTheme.grey50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? AppTheme.primaryEmerald.withValues(alpha: 0.2) : AppTheme.grey200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (isActive) 
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.check_circle_rounded, size: 14, color: AppTheme.primaryEmerald),
            ),
          Text(
            label, 
            style: TextStyle(
              fontWeight: FontWeight.w700, 
              fontSize: 12, 
              color: isActive ? AppTheme.primaryEmerald : AppTheme.grey600,
            ),
          ),
        ],
      ),
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.grey100),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                user.name[0].toUpperCase(), 
                style: const TextStyle(color: AppTheme.primaryEmerald, fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name, 
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.grey900, letterSpacing: -0.3),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email, 
                  style: const TextStyle(fontSize: 13, color: AppTheme.grey500, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildStatusBadge(user.isActive),
              const SizedBox(height: 8),
              Text(
                (user.wardNumber != null ? 'Ward ${user.wardNumber}' : 'UNASSIGNED').toUpperCase(),
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.grey300, letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: AppTheme.grey300),
            onPressed: () => _showUserActions(user),
            splashRadius: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.success.withValues(alpha: 0.08) : AppTheme.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive ? AppTheme.success.withValues(alpha: 0.2) : AppTheme.error.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? AppTheme.success : AppTheme.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'ACTIVE' : 'SUSPENDED',
            style: TextStyle(
              color: isActive ? AppTheme.success : AppTheme.error, 
              fontSize: 10, 
              fontWeight: FontWeight.w900, 
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showUserActions(User user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(36))),
      backgroundColor: Colors.white,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(color: AppTheme.grey200, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              user.name.toUpperCase(),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.grey400, letterSpacing: 1),
            ),
            const Text('Administrative Actions', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5)),
            const SizedBox(height: 32),
            _buildActionTile(
              context,
              icon: Icons.edit_note_rounded,
              color: AppTheme.info,
              title: 'Update Profile Data',
              subtitle: 'Modify name, contact, or ward assignments.',
              onTap: () => Navigator.pop(context),
            ),
            _buildActionTile(
              context,
              icon: Icons.lock_reset_rounded,
              color: AppTheme.warning,
              title: 'Reset Credentials',
              subtitle: 'Trigger a password reset or security audit.',
              onTap: () => Navigator.pop(context),
            ),
            _buildActionTile(
              context,
              icon: Icons.no_accounts_rounded,
              color: AppTheme.error,
              title: 'Deactivate Identity',
              subtitle: 'Revoke all system access immediately.',
              onTap: () async {
                Navigator.pop(context);
                final success = await context.read<AdminService>().deleteUser(user.id);
                if (context.mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Identity deactivated successfully'),
                      backgroundColor: AppTheme.grey900,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    )
                  );
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, {required IconData icon, required Color color, required String title, required String subtitle, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.grey50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.grey100),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.grey900, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.grey500)),
        onTap: onTap,
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(36))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 32, right: 32, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(color: AppTheme.grey200, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 32),
            const Text('Onboard New Worker', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5)),
            const Text('Provision a new field identity for Haritha Karma Sena.', style: TextStyle(color: AppTheme.grey400, fontSize: 13)),
            const SizedBox(height: 32),
            _buildDialogField('FULL LEGAL NAME', nameController, Icons.person_rounded),
            const SizedBox(height: 20),
            _buildDialogField('EMAIL ADDRESS', emailController, Icons.alternate_email_rounded),
            const SizedBox(height: 20),
            _buildDialogField('CONTACT NUMBER', phoneController, Icons.phone_rounded),
            const SizedBox(height: 20),
            _buildDialogField('WARD ASSIGNMENT', wardController, Icons.location_city_rounded),
            const SizedBox(height: 40),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Worker onboarded successfully'),
                          backgroundColor: AppTheme.primaryEmerald,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        )
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryEmerald,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('PROVISION IDENTITY', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.grey400, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: AppTheme.grey400),
            filled: true,
            fillColor: AppTheme.grey50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }
}

