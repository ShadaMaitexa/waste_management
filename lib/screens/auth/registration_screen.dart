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
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                  ),
                  color: Colors.white.withOpacity(0.1),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppTheme.spacingL),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: AppTheme.spacingL),
                          _buildFormFields(),
                          const SizedBox(height: AppTheme.spacingL),
                          _buildRegisterButton(),
                          const SizedBox(height: AppTheme.spacingM),
                          _buildLoginLink(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(
          Icons.person_add_rounded,
          size: 60,
          color: Colors.white,
        ),
        const SizedBox(height: AppTheme.spacingM),
        Text(
          'Join GreenLoop',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppTheme.spacingS),
        Text(
          'Create your ${_getUserTypeTitle(_selectedUserType)} account',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
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
      ],
    );
  }

  Widget _buildUserTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM, vertical: AppTheme.spacingS),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: Colors.white30),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<UserType>(
          value: _selectedUserType,
          onChanged: (UserType? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedUserType = newValue;
              });
            }
          },
          items: UserType.values.map<DropdownMenuItem<UserType>>((UserType type) {
            return DropdownMenuItem<UserType>(
              value: type,
              child: Text(
                'Register as: ${_getUserTypeTitle(type)}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
          dropdownColor: AppTheme.primaryGreen,
          decoration: const InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(Icons.badge, color: Colors.white70),
          ),
          iconEnabledColor: Colors.white70,
          validator: (value) => value == null ? 'Please select a role' : null,
        ),
      ),
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
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          borderSide: const BorderSide(color: Colors.white),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
      validator: validator,
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _register,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryGreen,
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
              ),
            )
          : const Text(
              'Sign Up',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account? ',
          style: TextStyle(color: Colors.white70),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
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
