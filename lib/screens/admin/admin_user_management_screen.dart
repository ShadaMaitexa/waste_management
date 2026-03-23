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
      length: 4, // Added Drivers tab
      child: Scaffold(
        backgroundColor: AppTheme.bgSurface,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(170),
          child: Container(
            padding: const EdgeInsets.only(top: 20),
            decoration: const BoxDecoration(color: AppTheme.bgSurface),
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
                      'User Management',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 28, color: AppTheme.grey900, letterSpacing: -1.5),
                    ),
                  ),
                  automaticallyImplyLeading: false,
                  actions: [
                    Container(
                      margin: const EdgeInsets.only(right: 20, top: 12),
                      child: ElevatedButton.icon(
                        onPressed: _showAddUserDialog,
                        icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                        label: Text('ADD WORKER', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5, fontSize: 11)),
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryEmerald, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
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
                  labelColor: AppTheme.grey900,
                  unselectedLabelColor: AppTheme.grey400,
                  labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5),
                  dividerColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  tabs: const [
                    Tab(text: 'RESIDENTS'),
                    Tab(text: 'WORKERS'),
                    Tab(text: 'DRIVERS'),
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
            final rawUsers = adminService.allUsers.where((u) => u.id != authService.currentUser?.id).toList();
            return Column(
              children: [
                _buildSearchField(),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildUserTable(rawUsers, UserType.resident),
                      _buildUserTable(rawUsers, UserType.worker), // Collection Workers
                      _buildUserTable(rawUsers, UserType.worker, roleLabel: 'driver'), // Treated as worker for now
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

  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: AppTheme.grey100, width: 1))),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search for users...',
          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppTheme.grey400),
          fillColor: AppTheme.grey50, filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildUserTable(List<User> users, UserType type, {String? roleLabel}) {
    final filteredUsers = users.where((u) {
      final matchesType = u.userType == type;
      // If roleLabel is provided, further filter if needed. For now role is 'worker' for both.
      final matchesSearch = _searchQuery.isEmpty || u.name.toLowerCase().contains(_searchQuery) || u.email.toLowerCase().contains(_searchQuery);
      return matchesType && matchesSearch;
    }).toList();

    if (filteredUsers.isEmpty) return const Center(child: Text('No records found.'));

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) => _buildUserRow(filteredUsers[index]),
    );
  }

  Widget _buildUserRow(User user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppTheme.grey100, width: 1.5), boxShadow: AppTheme.cardShadow),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: AppTheme.primaryEmerald.withOpacity(0.1), child: Text(user.name[0].toUpperCase(), style: GoogleFonts.plusJakartaSans(color: AppTheme.primaryEmerald, fontWeight: FontWeight.w900))),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(user.name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 16)), Text(user.email, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.grey400))])),
          IconButton(icon: const Icon(Icons.more_horiz_rounded, color: AppTheme.grey300), onPressed: () => _showUserActions(user)),
        ],
      ),
    );
  }

  void _showUserActions(User user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(36))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.edit_note_rounded, color: AppTheme.info), title: const Text('Update Profile'), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(Icons.no_accounts_rounded, color: AppTheme.error), title: const Text('Deactivate User'), onTap: () async {
              final success = await context.read<AdminService>().deleteUser(user.id);
              if (mounted && success) Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }

  void _showAddUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final phoneController = TextEditingController();
    final wardController = TextEditingController();
    String selectedRole = 'worker';

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
            children: [
              Text('Add New Worker', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 24)),
              const SizedBox(height: 24),
              _buildDialogField('USERNAME', nameController, Icons.person_rounded),
              _buildDialogField('EMAIL', emailController, Icons.alternate_email_rounded),
              _buildDialogField('PASSWORD', passwordController, Icons.lock_rounded, obscureText: true),
              _buildDialogField('PHONE', phoneController, Icons.phone_rounded),
              _buildDialogField('WARD', wardController, Icons.location_city_rounded),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: InputDecoration(labelText: 'ASSIGNED ROLE', labelStyle: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.grey400)),
                items: const [
                  DropdownMenuItem(value: 'worker', child: Text('Collection Worker')),
                  DropdownMenuItem(value: 'driver', child: Text('Fleet Driver')),
                ],
                onChanged: (v) => selectedRole = v!,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final success = await context.read<AdminService>().createHksWorker({
                      'username': nameController.text, 'email': emailController.text, 'password': passwordController.text, 'phone': phoneController.text, 'ward': wardController.text, 'role': selectedRole,
                    });
                    if (mounted && success) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryEmerald, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: Text('CREATE ACCOUNT', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogField(String label, TextEditingController controller, IconData icon, {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.grey400, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        TextField(controller: controller, obscureText: obscureText, decoration: InputDecoration(prefixIcon: Icon(icon, size: 20), filled: true, fillColor: AppTheme.grey50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none))),
        const SizedBox(height: 16),
      ],
    );
  }
}
