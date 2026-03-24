import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/complaint.dart';
import '../utils/api_constants.dart';
import 'auth_service.dart';

class ComplaintService extends ChangeNotifier {
  final AuthService _authService;
  List<Complaint> _complaints = [];
  bool _isLoading = false;

  ComplaintService(this._authService);

  List<Complaint> get complaints => _complaints;
  bool get isLoading => _isLoading;

  Future<void> fetchComplaints() async {
    if (!_authService.isAuthenticated) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.complaints),
        headers: {
          'Authorization': 'Bearer ${_authService.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _complaints = data.map((json) => Complaint.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching complaints: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createComplaint(Complaint complaint) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.complaints),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
        body: jsonEncode(complaint.toJson()),
      );

      if (response.statusCode == 201) {
        await fetchComplaints();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<String?> uploadImage(String filePath) async {
    try {
      // 1. Get pre-signed URL
      final presignedResponse = await http.post(
        Uri.parse(ApiConstants.complaintsPresignedUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
        body: jsonEncode({
          'file_name': filePath.split('/').last,
          'content_type': 'image/jpeg',
        }),
      );

      if (presignedResponse.statusCode != 200) return null;
      
      final Map<String, dynamic> data = jsonDecode(presignedResponse.body);
      final String uploadUrl = data['url'];
      final String finalImageUrl = data['image_url'] ?? uploadUrl.split('?').first;

      // 2. Upload to S3
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      
      final uploadResponse = await http.put(
        Uri.parse(uploadUrl),
        body: bytes,
        headers: {
          'Content-Type': 'image/jpeg',
        },
      );

      if (uploadResponse.statusCode == 200) {
        return finalImageUrl;
      }
      return null;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  Future<bool> deleteComplaint(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.complaints}$id/'),
        headers: {
          'Authorization': 'Bearer ${_authService.token}',
        },
      );

      if (response.statusCode == 204) {
        _complaints.removeWhere((c) => c.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
