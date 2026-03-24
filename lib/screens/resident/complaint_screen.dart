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
  String? _locationString;
  String? _photoPath;

  Future<void> _attachPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (image != null) {
      setState(() => _photoPath = image.path);
    }
  }

  Future<void> _captureLocation() async {
    setState(() => _isLocating = true);
    try {
      final locPrefs = await Geolocator.checkPermission();
      if (locPrefs == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
      setState(() => _locationString = '${pos.latitude}, ${pos.longitude}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to get location: $e'), backgroundColor: AppTheme.error));
    } finally {
      setState(() => _isLocating = false);
    }
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    final complaint = Complaint(
      id: '',
      residentName: context.read<AuthService>().currentUserName ?? 'Resident',
      assignedWorkerName: '',
      title: _titleController.text,
      description: _descriptionController.text + (_locationString != null ? '\n[Location: $_locationString]' : '') + (_photoPath != null ? '\n[Photo Attached]' : ''),
      status: ComplaintStatus.pending,
      createdAt: DateTime.now(),
      wardNumber: context.read<AuthService>().currentUser?.wardNumber,
    );

    final success = await Provider.of<ComplaintService>(context, listen: false).createComplaint(complaint);

    if (success && mounted) {
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _photoPath = null;
        _locationString = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complaint submitted successfully')),
      );
      Navigator.pop(context); // Close the form modal or screen
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
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'File a Complaint',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).textTheme.headlineLarge?.color ?? AppTheme.grey900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Our team will review your report within 24 hours.',
                  style: GoogleFonts.plusJakartaSans(color: AppTheme.grey500, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 32),
                _buildFieldLabel('TITLE'),
                TextFormField(
                  controller: _titleController,
                  decoration: _buildInputDecoration('Subject of issue...'),
                  validator: (v) => v!.isEmpty ? 'Please enter a title' : null,
                ),
                const SizedBox(height: 20),
                _buildFieldLabel('DESCRIPTION'),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: _buildInputDecoration('Detailed description...'),
                  validator: (v) => v!.isEmpty ? 'Please describe the issue' : null,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await _attachPhoto();
                          setStateModal(() {});
                        },
                        icon: Icon(_photoPath != null ? Icons.check_circle_rounded : Icons.camera_alt_rounded, size: 18),
                        label: Text(_photoPath != null ? 'Photo Added' : 'Add Photo'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _photoPath != null ? AppTheme.success : AppTheme.primaryEmerald,
                          side: BorderSide(color: _photoPath != null ? AppTheme.success : AppTheme.primaryEmerald),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          if (_locationString == null) {
                            await _captureLocation();
                            setStateModal(() {});
                          }
                        },
                        icon: _isLocating 
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : Icon(_locationString != null ? Icons.location_on_rounded : Icons.add_location_alt_rounded, size: 18),
                        label: Text(_locationString != null ? 'Location Added' : 'Add Location'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _locationString != null ? AppTheme.info : AppTheme.primaryEmerald,
                          side: BorderSide(color: _locationString != null ? AppTheme.info : AppTheme.primaryEmerald),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submitComplaint,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryEmerald,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      'TRANSMIT REPORT',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white, letterSpacing: 1),
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
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.grey400, letterSpacing: 1.5),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.plusJakartaSans(color: AppTheme.grey300, fontSize: 13, fontWeight: FontWeight.w600),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Theme.of(context).dividerColor)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Theme.of(context).dividerColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primaryEmerald, width: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Grievance Center',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<ComplaintService>(
        builder: (context, service, child) {
          if (service.isLoading && service.complaints.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryEmerald));
          }

          if (service.complaints.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                      boxShadow: AppTheme.smoothShadow,
                    ),
                    child: Icon(Icons.verified_user_rounded, size: 64, color: AppTheme.grey200),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'ALL CLEAR',
                    style: GoogleFonts.plusJakartaSans(color: AppTheme.grey400, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2),
                  ),
                  const SizedBox(height: 8),
                  Text('You have no active complaints.', style: GoogleFonts.inter(color: AppTheme.grey300, fontWeight: FontWeight.w500, fontSize: 14)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: service.complaints.length,
            itemBuilder: (context, index) {
              final complaint = service.complaints[index];
              return _buildComplaintCard(complaint);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showComplaintForm,
        backgroundColor: AppTheme.primaryEmerald,
        icon: const Icon(Icons.add_comment_rounded, color: Colors.white),
        label: Text('FILE GRIEVANCE', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: Colors.white)),
      ),
    );
  }

  Widget _buildComplaintCard(Complaint complaint) {
    final statusColor = _getStatusColor(complaint.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  complaint.status.name.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(color: statusColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
              ),
              Text(
                DateFormat('MMM dd, yyyy').format(complaint.createdAt),
                style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppTheme.grey400, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            complaint.title,
            style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w900, color: Theme.of(context).textTheme.headlineSmall?.color ?? AppTheme.grey900),
          ),
          const SizedBox(height: 8),
          Text(
            complaint.description,
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.grey500, fontWeight: FontWeight.w500, height: 1.5),
          ),
          if (complaint.response != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryEmerald.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OFFICIAL RESPONSE',
                    style: GoogleFonts.plusJakartaSans(fontSize: 8, fontWeight: FontWeight.w900, color: AppTheme.primaryEmerald, letterSpacing: 1),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    complaint.response!,
                    style: GoogleFonts.inter(fontSize: 13, color: AppTheme.grey700, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
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
