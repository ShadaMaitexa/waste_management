import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waste_management/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _wardController = TextEditingController(); // Added ward controller
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  UserType _selectedUserType = UserType.resident;


  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _wardController.dispose(); // Dispose ward controller
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
            final success = await authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phoneNumber: _phoneController.text.trim(),
        ward: _selectedUserType == UserType.resident ? _wardController.text.trim() : null,
        address: _addressController.text.trim(),
        userType: _selectedUserType,
      );

      if (success && mounted) {
        // Success notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.regSuccess),
            backgroundColor: AppTheme.success,
          ),
        );
        
        // Navigate based on user type
        String route;
        switch (_selectedUserType) {
          case UserType.resident:
            route = '/resident';
            break;
          case UserType.worker:
            route = '/worker';
            break;
          case UserType.admin:
            route = '/admin';
            break;
          case UserType.recycler:
            route = '/recycler';
            break;
          case UserType.driver:
            route = '/worker'; // For now, directing drivers to worker dashboard or you can add /driver route
            break;
        }
        
        Navigator.pushReplacementNamed(context, route);
      } else {
        _showErrorSnackBar(AppLocalizations.of(context)!.regFailed);
      }
    } catch (e) {
      _showErrorSnackBar('${AppLocalizations.of(context)!.errorOccurred} $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSurface,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppTheme.bgSurface,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.bgSurface, Color(0xFFF1F8E9)],
              ),
            ),
          ),
          Positioned(
            right: -100,
            top: -50,
            child: Icon(
              Icons.spa_rounded,
              size: 300,
              color: AppTheme.primaryEmerald.withOpacity(0.05),
            ),
          ),
          Positioned(
            left: -150,
            bottom: -100,
            child: Icon(
              Icons.blur_on_rounded,
              size: 400,
              color: AppTheme.primaryEmerald.withOpacity(0.03),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32), // Reduced from 56
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildFormFields(),
                          const SizedBox(height: 32), // Reduced from 48
                          _buildRegisterButton(),
                          const SizedBox(height: 24), // Reduced from 32
                          _buildLoginLink(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: AppTheme.cardShadow,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.grey900, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80, // Reduced from 100
          height: 80, // Reduced from 100
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: AppTheme.cardShadow,
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.emeraldGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryEmerald.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_add_alt_1_rounded,
              size: 24, // Reduced from 28
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24), // Reduced from 32
        Text(
          AppLocalizations.of(context)!.onboard4Title, // Join the Movement
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28, // Reduced from 36
            fontWeight: FontWeight.w900,
            color: AppTheme.grey900,
            letterSpacing: -1.2,
            height: 1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          AppLocalizations.of(context)!.fillDetails,
          style: GoogleFonts.plusJakartaSans(
            color: AppTheme.primaryEmerald,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  String _getUserTypeTitle(UserType type) {
    switch (type) {
      case UserType.resident:
        return AppLocalizations.of(context)!.roleResident;
      case UserType.worker:
        return AppLocalizations.of(context)!.roleWorker;
      case UserType.admin:
        return AppLocalizations.of(context)!.roleAdmin;
      case UserType.recycler:
        return AppLocalizations.of(context)!.roleRecycler;
      case UserType.driver:
        return AppLocalizations.of(context)!.roleDriver;
    }
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildUserTypeSelector(),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _nameController,
          label: AppLocalizations.of(context)!.fullName,
          icon: Icons.person_outline_rounded,
          validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _emailController,
          label: AppLocalizations.of(context)!.emailHint,
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) return AppLocalizations.of(context)!.emailRequired;
            if (!value.contains('@')) return 'Please enter a valid email';
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _phoneController,
          label: AppLocalizations.of(context)!.phoneNumber,
          icon: Icons.phone_android_rounded,
          keyboardType: TextInputType.phone,
          validator: (value) => value == null || value.isEmpty ? 'Please enter your phone number' : null,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _passwordController,
          label: 'Password',
          icon: Icons.lock_outline_rounded,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility : Icons.visibility_off,
              color: AppTheme.grey400,
              size: 20,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          validator: (value) => value != null && value.length < 6 ? 'Password must be at least 6 characters' : null,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _addressController,
          label: AppLocalizations.of(context)!.address,
          icon: Icons.location_on_outlined,
          maxLines: 2,
          validator: (value) => value == null || value.isEmpty ? 'Please enter your address' : null,
        ),
        if (_selectedUserType == UserType.resident) ...[
          const SizedBox(height: 20),
          _buildTextField(
            controller: _wardController,
            label: AppLocalizations.of(context)!.wardNumber,
            icon: Icons.map_outlined,
            keyboardType: TextInputType.number,
            validator: (value) => value == null || value.isEmpty ? 'Please enter your ward number' : null,
          ),
        ],
      ],
    );
  }

  Widget _buildUserTypeSelector() {
    return DropdownButtonFormField<UserType>(
      value: _selectedUserType,
      dropdownColor: AppTheme.bgCanvas,
      borderRadius: BorderRadius.circular(20),
      style: GoogleFonts.plusJakartaSans(color: AppTheme.grey900, fontSize: 15, fontWeight: FontWeight.w700),
      iconEnabledColor: AppTheme.grey400,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.selectRole,
        prefixIcon: const Icon(Icons.badge_outlined, size: 20, color: AppTheme.primaryEmerald),
      ),
      items: UserType.values.map<DropdownMenuItem<UserType>>((UserType type) {
        return DropdownMenuItem<UserType>(
          value: type,
          child: Text(
            _getUserTypeTitle(type).toUpperCase(),
            style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5),
          ),
        );
      }).toList(),
      onChanged: (UserType? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedUserType = newValue;
          });
        }
      },
      validator: (value) => value == null ? 'Role is required' : null,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppTheme.grey900, fontSize: 15),
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Icon(icon, size: 20, color: AppTheme.primaryEmerald),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 56, // Reduced from 64
      child: ElevatedButton(
        onPressed: _isLoading ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.bgDark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppTheme.slateGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.bgDark.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.signUpButton,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.shield_moon_rounded, size: 20, color: AppTheme.primaryEmerald),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context)!.alreadyHaveAccount,
          style: GoogleFonts.inter(color: AppTheme.grey400, fontWeight: FontWeight.w600, fontSize: 13),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            foregroundColor: AppTheme.primaryEmerald,
          ),
          child: Text(
            AppLocalizations.of(context)!.loginLink,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }
}
