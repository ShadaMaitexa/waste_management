import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/complaint_service.dart';
import '../../services/auth_service.dart';
import '../../models/complaint.dart';
import '../../theme/app_theme.dart';

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ComplaintService>(context, listen: false).fetchComplaints();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _isLocating = false;
  bool _isUploading = false;
  Position? _currentPosition;
  String? _photoPath;
  String? _uploadedImageUrl;

  Future<void> _attachPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (image != null) {
      setState(() {
         _photoPath = image.path;
         _uploadedImageUrl = null; // Mark as needs upload
      });
    }
  }

  Future<void> _captureLocation() async {
    setState(() => _isLocating = true);
    try {
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
      setState(() => _currentPosition = pos);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to get location: $e')));
    } finally {
      setState(() => _isLocating = false);
    }
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isUploading = true);

    try {
      final complaintService = Provider.of<ComplaintService>(context, listen: false);
      
      // 1. Upload image if exists
      if (_photoPath != null && _uploadedImageUrl == null) {
        _uploadedImageUrl = await complaintService.uploadImage(_photoPath!);
        if (_uploadedImageUrl == null) throw 'Image upload failed';
      }

      // 2. Build model
      final complaint = Complaint(
        id: '',
        residentName: context.read<AuthService>().currentUserName ?? 'Resident',
        assignedWorkerName: '',
        title: _titleController.text,
        description: _descriptionController.text,
        status: ComplaintStatus.pending,
        createdAt: DateTime.now(),
        imageUrl: _uploadedImageUrl,
        wardNumber: context.read<AuthService>().currentUser?.wardNumber,
        latitude: _currentPosition?.latitude.toString(),
        longitude: _currentPosition?.longitude.toString(),
      );

      // 3. Save to backend
      final success = await complaintService.createComplaint(complaint);

      if (success && mounted) {
        _titleController.clear();
        _descriptionController.clear();
        setState(() {
          _photoPath = null;
          _uploadedImageUrl = null;
          _currentPosition = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complaint submitted successfully'), backgroundColor: AppTheme.success));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showComplaintForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) => Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('File a Complaint', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.grey900)),
                const SizedBox(height: 32),
                _buildFieldLabel('TITLE'),
                TextFormField(
                  controller: _titleController,
                  decoration: _buildInputDecoration('Missed Pickup / Service Issue'),
                  validator: (v) => v!.isEmpty ? 'Please enter a title' : null,
                ),
                const SizedBox(height: 20),
                _buildFieldLabel('DESCRIPTION'),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: _buildInputDecoration('Describe what happened...'),
                  validator: (v) => v!.isEmpty ? 'Please describe the issue' : null,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _ActionToggle(
                        isActive: _photoPath != null,
                        label: _photoPath != null ? 'Photo Attached' : 'Take Photo',
                        icon: Icons.camera_alt_rounded,
                        onTap: () async {
                          await _attachPhoto();
                          setStateModal(() {});
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionToggle(
                        isActive: _currentPosition != null,
                        label: _currentPosition != null ? 'Location Tagged' : 'Add GPS',
                        icon: Icons.gps_fixed_rounded,
                        isLoading: _isLocating,
                        onTap: () async {
                          await _captureLocation();
                          setStateModal(() {});
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _submitComplaint,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.bgDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0, padding: EdgeInsets.zero,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(gradient: AppTheme.slateGradient, borderRadius: BorderRadius.circular(20)),
                      child: Container(
                        alignment: Alignment.center,
                        child: _isUploading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text('SUBMIT REPORT', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.grey400, letterSpacing: 1.5)),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true, fillColor: AppTheme.grey50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSurface,
      appBar: AppBar(
        title: Text('GRIEVANCE CENTER', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2, color: AppTheme.grey900)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(onPressed: _showComplaintForm, icon: const Icon(Icons.add_comment_rounded, color: AppTheme.primaryEmerald)),
        ],
      ),
      body: Consumer<ComplaintService>(
        builder: (context, service, child) {
          if (service.isLoading && service.complaints.isEmpty) return const Center(child: CircularProgressIndicator());
          if (service.complaints.isEmpty) return _buildEmptyState();

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: service.complaints.length,
            itemBuilder: (context, index) {
              final complaint = service.complaints[index];
              return _buildComplaintCard(complaint);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 80, color: AppTheme.grey200),
          const SizedBox(height: 24),
          Text('NO ACTIVE ISSUES', style: GoogleFonts.plusJakartaSans(color: AppTheme.grey400, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(Complaint complaint) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: AppTheme.cardShadow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBadge(complaint.status.name.toUpperCase(), _getStatusColor(complaint.status)),
              Text(DateFormat('MMM dd').format(complaint.createdAt), style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppTheme.grey400, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          Text(complaint.title, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.grey900)),
          const SizedBox(height: 8),
          Text(complaint.description, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.grey500, height: 1.5)),
          if (complaint.imageUrl != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(complaint.imageUrl!, height: 150, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: GoogleFonts.plusJakartaSans(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
    );
  }

  Color _getStatusColor(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.pending: return AppTheme.warning;
      case ComplaintStatus.inProgress: return AppTheme.info;
      case ComplaintStatus.resolved: return AppTheme.success;
      case ComplaintStatus.closed: return AppTheme.grey400;
    }
  }
}

class _ActionToggle extends StatelessWidget {
  final bool isActive;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isLoading;

  const _ActionToggle({required this.isActive, required this.label, required this.icon, required this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onTap,
      icon: isLoading ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(icon, size: 16),
      label: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800)),
      style: OutlinedButton.styleFrom(
        foregroundColor: isActive ? AppTheme.primaryEmerald : AppTheme.grey400,
        side: BorderSide(color: isActive ? AppTheme.primaryEmerald : AppTheme.grey200),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}
