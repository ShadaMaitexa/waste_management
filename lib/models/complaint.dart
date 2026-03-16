enum ComplaintStatus { pending, inProgress, resolved, closed }

class Complaint {
  final String id;
  final String title;
  final String description;
  final ComplaintStatus status;
  final DateTime createdAt;
  final String? response;
  final String? imageUrl;
  final String category;

  final String? wardNumber;

  Complaint({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    this.response,
    this.imageUrl,
    required this.category,
    this.wardNumber,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: ComplaintStatus.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == (json['status']?.toString().toLowerCase() ?? 'pending'),
        orElse: () => ComplaintStatus.pending,
      ),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      response: json['response'],
      imageUrl: json['image'],
      category: json['category'] ?? 'General',
      wardNumber: json['ward_number']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'status': status.toString().split('.').last,
      'category': category,
    };
  }
}
