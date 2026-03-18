import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/admin_service.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminService>(context, listen: false).fetchUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.bgSurface,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(170),
          child: Container(
            padding: const EdgeInsets.only(top: 20),
            decoration: const BoxDecoration(
              color: AppTheme.bgSurface,
            ),
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  centerTitle: false,
                  title: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'User Registry',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
                        color: AppTheme.grey900,
                        letterSpacing: -1.5,
                      ),
                    ),
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.grey900),
                    onPressed: () => Navigator.pushReplacementNamed(context, '/splash'),
                  ),
                  foregroundColor: AppTheme.grey900,
                  actions: [
                    Container(
                      margin: const EdgeInsets.only(right: 20, top: 12),
                      child: ElevatedButton.icon(
                        onPressed: _showAddWorkerDialog,
                        icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                        label: Text(
                          'NEW WORKER',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.5,
                            fontSize: 11,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryEmerald,
                          elevation: 8,
                          shadowColor: AppTheme.primaryEmerald.withOpacity(0.3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: AppTheme.primaryEmerald,
                  indicatorWeight: 4,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: AppTheme.grey900,
                  unselectedLabelColor: AppTheme.grey400,
                  labelStyle: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                  dividerColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  tabs: const [
                    Tab(text: 'RESIDENTS'),
                    Tab(text: 'WORKERS'),
                    Tab(text: 'RECYCLERS'),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        body: Consumer2<AdminService, AuthService>(
          builder: (context, adminService, authService, child) {
            final currentUser = authService.currentUser;
            final rawUsers = adminService.allUsers.where((u) => u.id != currentUser?.id).toList();

            return Column(
              children: [
                _buildControlBar(),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildUserTable(rawUsers, UserType.resident),
                      _buildUserTable(rawUsers, UserType.worker),
                      _buildUserTable(rawUsers, UserType.recycler),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.grey100, width: 1)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search by UID, name, or metadata...',
              hintStyle: GoogleFonts.inter(color: AppTheme.grey400, fontSize: 13, fontWeight: FontWeight.w500),
              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppTheme.grey400),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              fillColor: AppTheme.grey50,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18), 
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18), 
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18), 
                borderSide: const BorderSide(color: AppTheme.primaryEmerald, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildFilterChip('Active', true),
                const SizedBox(width: 12),
                _buildFilterChip('Pending', false),
                const SizedBox(width: 12),
                _buildFilterChip('Verified', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryEmerald : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? AppTheme.primaryEmerald : AppTheme.grey200,
          width: 1.5,
        ),
        boxShadow: isActive ? [
          BoxShadow(
            color: AppTheme.primaryEmerald.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ] : null,
      ),
      child: Center(
        child: Text(
          label, 
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900, 
            fontSize: 10, 
            color: isActive ? Colors.white : AppTheme.grey500,
            letterSpacing: 0.5,
          ),
        ),
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
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.grey100.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.group_off_rounded, size: 64, color: AppTheme.grey300),
            ),
            const SizedBox(height: 24),
            Text(
              'No records match', 
              style: GoogleFonts.plusJakartaSans(
                color: AppTheme.grey900, 
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Reset search filters to expand criteria.', 
              style: GoogleFonts.inter(
                color: AppTheme.grey400, 
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
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
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppTheme.grey100, width: 1.5),
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
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.primaryEmerald, 
                  fontWeight: FontWeight.w900, 
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name, 
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900, 
                    fontSize: 16, 
                    color: AppTheme.grey900, 
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email, 
                  style: GoogleFonts.inter(
                    fontSize: 12, 
                    color: AppTheme.grey400, 
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildStatusBadge(user.isActive),
              const SizedBox(height: 6),
              Text(
                (user.wardNumber != null ? 'WARD ${user.wardNumber}' : 'UNASSIGNED'),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 8, 
                  fontWeight: FontWeight.w900, 
                  color: AppTheme.grey300, 
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: AppTheme.grey300, size: 20),
            onPressed: () => _showUserActions(user),
            splashRadius: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    final color = isActive ? AppTheme.primaryEmerald : AppTheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isActive ? 'ACTIVE' : 'SUSPENDED',
            style: GoogleFonts.plusJakartaSans(
              color: color, 
              fontSize: 8, 
              fontWeight: FontWeight.w900, 
              letterSpacing: 1,
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
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9, 
                fontWeight: FontWeight.w900, 
                color: AppTheme.grey400, 
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Administrative Actions', 
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900, 
                fontSize: 24, 
                letterSpacing: -1,
                color: AppTheme.grey900,
              ),
            ),
            const SizedBox(height: 32),
            _buildActionTile(
              context,
              icon: Icons.edit_note_rounded,
              color: AppTheme.info,
              title: 'Update Profile',
              subtitle: 'Modify name, contact, or ward.',
              onTap: () => Navigator.pop(context),
            ),
            _buildActionTile(
              context,
              icon: Icons.lock_reset_rounded,
              color: AppTheme.warning,
              title: 'Reset Password',
              subtitle: 'Send a password reset link.',
              onTap: () => Navigator.pop(context),
            ),
            _buildActionTile(
              context,
              icon: Icons.no_accounts_rounded,
              color: AppTheme.error,
              title: 'Deactivate User',
              subtitle: 'Remove user access immediately.',
              onTap: () async {
                Navigator.pop(context);
                final success = await context.read<AdminService>().deleteUser(user.id);
                if (context.mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('User deactivated successfully'),
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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.grey100),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1), 
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title, 
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900, 
            color: AppTheme.grey900, 
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle, 
            style: GoogleFonts.inter(
              fontSize: 12, 
              fontWeight: FontWeight.w500, 
              color: AppTheme.grey500,
            ),
          ),
        ),
        onTap: onTap,
        trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.grey300, size: 20),
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
        child: SingleChildScrollView(
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
                'Add Worker', 
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w900, 
                  fontSize: 26, 
                  letterSpacing: -1.5,
                  color: AppTheme.grey900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Add a new worker to the system.', 
                style: GoogleFonts.inter(
                  color: AppTheme.grey500, 
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 36),
              _buildDialogField('NAME', nameController, Icons.person_rounded),
              const SizedBox(height: 20),
              _buildDialogField('EMAIL', emailController, Icons.alternate_email_rounded),
              const SizedBox(height: 20),
              _buildDialogField('PHONE', phoneController, Icons.phone_rounded),
              const SizedBox(height: 20),
              _buildDialogField('WARD', wardController, Icons.location_city_rounded),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final success = await context.read<AdminService>().createHksWorker({
                      'name': nameController.text,
                      'email': emailController.text,
                      'phone_number': phoneController.text,
                      'ward_number': wardController.text,
                      'role': 'worker',
                    });
                    if (context.mounted) {
                      Navigator.pop(context);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Worker onboarded successfully',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                            ),
                            backgroundColor: AppTheme.bgDark,
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.all(24),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          )
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryEmerald,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    elevation: 8,
                    shadowColor: AppTheme.primaryEmerald.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: Text(
                    'ADD WORKER', 
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900, 
                    letterSpacing: 2,
                    fontSize: 13,
                  ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9, 
            fontWeight: FontWeight.w900, 
            color: AppTheme.grey400, 
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.grey900),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: AppTheme.grey400),
            filled: true,
            fillColor: AppTheme.grey50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18), 
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18), 
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18), 
              borderSide: const BorderSide(color: AppTheme.primaryEmerald, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          ),
        ),
      ],
    );
  }
}

