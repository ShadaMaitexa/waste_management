import 'package:flutter/material.dart';
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
        address: _addressController.text.trim(),
        ward: _selectedUserType == UserType.resident ? _wardController.text.trim() : null, // Pass ward if resident
        userType: _selectedUserType,
      );

      if (success && mounted) {
        // Success notification
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful!'),
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
        }
        
        Navigator.pushReplacementNamed(context, route);
      } else {
        _showErrorSnackBar('Registration failed. Please try again.');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred: $e');
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
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
          ),
          Positioned(
            left: -80,
            bottom: -50,
            child: Icon(
              Icons.eco_rounded,
              size: 350,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 48),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildFormFields(),
                          const SizedBox(height: 40),
                          _buildRegisterButton(),
                          const SizedBox(height: 32),
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
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
          ),
          child: const Icon(
            Icons.person_add_alt_1_rounded,
            size: 48,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Create Account',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'JOIN THE GREEN REVOLUTION',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  String _getUserTypeTitle(UserType type) {
    switch (type) {
      case UserType.resident:
        return 'Resident';
      case UserType.worker:
        return 'Worker';
      case UserType.admin:
        return 'Admin';
      case UserType.recycler:
        return 'Recycler';
    }
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildUserTypeSelector(),
        const SizedBox(height: AppTheme.spacingM),
        _buildTextField(
          controller: _nameController,
          label: 'Full Name',
          icon: Icons.person,
          validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
        ),
        const SizedBox(height: AppTheme.spacingM),
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter your email';
            if (!value.contains('@')) return 'Please enter a valid email';
            return null;
          },
        ),
        const SizedBox(height: AppTheme.spacingM),
        _buildTextField(
          controller: _phoneController,
          label: 'Phone Number',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: (value) => value == null || value.isEmpty ? 'Please enter your phone number' : null,
        ),
        const SizedBox(height: AppTheme.spacingM),
        _buildTextField(
          controller: _passwordController,
          label: 'Password',
          icon: Icons.lock,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility : Icons.visibility_off,
              color: Colors.white70,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          validator: (value) => value != null && value.length < 6 ? 'Password must be at least 6 characters' : null,
        ),
        const SizedBox(height: AppTheme.spacingM),
        _buildTextField(
          controller: _addressController,
          label: 'Address',
          icon: Icons.location_on,
          maxLines: 2,
          validator: (value) => value == null || value.isEmpty ? 'Please enter your address' : null,
        ),
        if (_selectedUserType == UserType.resident) ...[
          const SizedBox(height: AppTheme.spacingM),
          _buildTextField(
            controller: _wardController,
            label: 'Ward Number',
            icon: Icons.map,
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
      dropdownColor: AppTheme.primaryGreen,
      borderRadius: BorderRadius.circular(24),
      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
      iconEnabledColor: Colors.white,
      decoration: InputDecoration(
        hintText: 'Select Role',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        prefixIcon: const Icon(Icons.badge_outlined, color: Colors.white, size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.15),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1), width: 1.5),
        ),
      ),
      items: UserType.values.map<DropdownMenuItem<UserType>>((UserType type) {
        return DropdownMenuItem<UserType>(
          value: type,
          child: Text(
            _getUserTypeTitle(type),
            style: const TextStyle(color: Colors.white),
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
      validator: (value) => value == null ? 'Please select a role' : null,
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
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
        prefixIcon: Icon(icon, color: Colors.white, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.15),
        contentPadding: const EdgeInsets.all(20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: AppTheme.primaryGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: AppTheme.primaryGreen)
            : const Text(
                'CREATE ACCOUNT',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'Already have an account? ',
          style: TextStyle(color: Colors.white70),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingS),
          ),
          child: const Text(
            'Sign In',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
