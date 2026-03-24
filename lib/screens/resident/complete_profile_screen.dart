import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/ward_service.dart';
import '../../theme/app_theme.dart';
import '../../models/ward.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameEnController = TextEditingController();
  final _nameMlController = TextEditingController();
  final _addressController = TextEditingController();
  
  Ward? _selectedWard;
  LatLng? _selectedLocation;
  bool _isLoading = false;
  bool _isLocating = false;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WardService>().fetchWards();
      _determinePosition();
    });
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameMlController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied.';
      }

      final position = await Geolocator.getCurrentPosition();
      final newPos = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _selectedLocation = newPos;
        _isLocating = false;
      });

      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(newPos, 16));
    } catch (e) {
      debugPrint('Error locating: $e');
      setState(() => _isLocating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWard == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a ward')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      
      // Combine names as per current User model limitations (username field)
      final fullName = '${_nameEnController.text} (${_nameMlController.text})';
      
      final success = await authService.updateProfile(
        name: fullName,
        ward: _selectedWard!.wardNumber,
        address: _addressController.text.trim(),
        latitude: _selectedLocation?.latitude.toString(),
        longitude: _selectedLocation?.longitude.toString(),
      );

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/resident');
      } else {
        throw 'Failed to update profile';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSurface,
      appBar: AppBar(
        title: Text('PROFILE SETUP', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 13, color: AppTheme.grey900)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryEmerald)) : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('IDENTITY'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameEnController,
                label: 'Name (English)',
                icon: Icons.person_outline_rounded,
                validator: (v) => v == null || v.isEmpty ? 'English name required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameMlController,
                label: 'പേര് (Malayalam)',
                icon: Icons.translate_rounded,
                validator: (v) => v == null || v.isEmpty ? 'Malayalam name required' : null,
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('ASSIGNMENT'),
              const SizedBox(height: 16),
              _buildWardDropdown(),
              const SizedBox(height: 32),
              _buildSectionHeader('LOCATION'),
              const SizedBox(height: 16),
              _buildMapSection(),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _addressController,
                label: 'Confirm Address',
                icon: Icons.location_on_outlined,
                maxLines: 2,
                validator: (v) => v == null || v.isEmpty ? 'Address required' : null,
              ),
              const SizedBox(height: 48),
              _buildSaveButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.grey400, letterSpacing: 2));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15),
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryEmerald, size: 20),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: validator,
    );
  }

  Widget _buildWardDropdown() {
    return Consumer<WardService>(
      builder: (context, wardService, child) {
        if (wardService.isLoading) return const LinearProgressIndicator();

        return DropdownButtonFormField<Ward>(
          value: _selectedWard,
          dropdownColor: Colors.white,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.map_outlined, color: AppTheme.primaryEmerald, size: 20),
            hintText: 'Select Your Ward',
          ),
          items: wardService.wards.map((ward) {
            return DropdownMenuItem<Ward>(
              value: ward,
              child: Row(
                children: [
                  Text(ward.nameEn, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Text('(${ward.nameMl})', style: GoogleFonts.plusJakartaSans(color: AppTheme.grey500, fontSize: 12)),
                ],
              ),
            );
          }).toList(),
          onChanged: (v) => setState(() => _selectedWard = v),
          validator: (v) => v == null ? 'Ward is required' : null,
        );
      },
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 250,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.grey100, width: 2),
      ),
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _selectedLocation ?? const LatLng(11.2588, 75.7804), zoom: 12),
            onMapCreated: (c) => _mapController = c,
            onTap: (latLng) => setState(() => _selectedLocation = latLng),
            markers: _selectedLocation != null 
              ? {Marker(markerId: const MarkerId('selected'), position: _selectedLocation!, draggable: true, onDragEnd: (p) => setState(() => _selectedLocation = p))} 
              : {},
          ),
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'locate_btn',
              onPressed: _isLocating ? null : _determinePosition,
              backgroundColor: Colors.white,
              child: _isLocating ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.my_location_rounded, color: AppTheme.primaryEmerald),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.bgDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: EdgeInsets.zero,
        ),
        child: Ink(
          decoration: BoxDecoration(gradient: AppTheme.slateGradient, borderRadius: BorderRadius.circular(20)),
          child: Container(
            alignment: Alignment.center,
            child: Text('SAVE & FINISH', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
