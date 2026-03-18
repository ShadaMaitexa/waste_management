/// Matches the backend API for /api/complaints/
/// Fields: id, resident, resident_name, assigned_worker, assigned_worker_name,
///         title, description, status, created_at

enum ComplaintStatus { pending, inProgress, resolved, closed }

class Complaint {
  final String id;
  final int? resident;
  final String residentName;
  final int? assignedWorker;
  final String assignedWorkerName;
  final String title;
  final String description;
  final ComplaintStatus status;
  final DateTime createdAt;
  final String? imageUrl;
  final String? wardNumber;
  final String? response;

  Complaint({
    required this.id,
    this.resident,
    required this.residentName,
    this.assignedWorker,
    required this.assignedWorkerName,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    this.imageUrl,
    this.wardNumber,
    this.response,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['status'] ?? 'pending').toString().toLowerCase();
    ComplaintStatus parsedStatus;
    switch (rawStatus) {
      case 'in_progress':
        parsedStatus = ComplaintStatus.inProgress;
        break;
      case 'resolved':
        parsedStatus = ComplaintStatus.resolved;
        break;
      case 'closed':
        parsedStatus = ComplaintStatus.closed;
        break;
      default:
        parsedStatus = ComplaintStatus.pending;
    }

    return Complaint(
      id: (json['id'] ?? '').toString(),
      resident: json['resident'] is int ? json['resident'] : int.tryParse(json['resident']?.toString() ?? ''),
      residentName: json['resident_name'] ?? '',
      assignedWorker: json['assigned_worker'] is int
          ? json['assigned_worker']
          : int.tryParse(json['assigned_worker']?.toString() ?? ''),
      assignedWorkerName: json['assigned_worker_name'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: parsedStatus,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? json['image'],
      wardNumber: json['ward_number']?.toString() ?? json['ward']?.toString(),
      response: json['response_text'] ?? json['response'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'status': status == ComplaintStatus.inProgress
          ? 'in_progress'
          : status.name,
      if (assignedWorker != null) 'assigned_worker': assignedWorker,
      if (imageUrl != null) 'image_url': imageUrl,
      if (wardNumber != null) 'ward_number': wardNumber,
      if (response != null) 'response': response,
    };
  }
}
