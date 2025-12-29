import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _ticketController = TextEditingController();

  String _selectedCategory = 'General Inquiry';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    _ticketController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact & Support'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Contact Us'),
            Tab(text: 'Support Tickets'),
            Tab(text: 'FAQ'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildContactUsTab(),
          _buildSupportTicketsTab(),
          _buildFAQTab(),
        ],
      ),
    );
  }

  Widget _buildContactUsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(),
          const SizedBox(height: AppTheme.spacingL),
          _buildContactForm(),
          const SizedBox(height: AppTheme.spacingL),
          _buildContactInfo(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Get in Touch',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'We\'re here to help you with any questions or concerns about GreenLoop',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send us a Message',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppTheme.spacingM),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: const [
                DropdownMenuItem(value: 'General Inquiry', child: Text('General Inquiry')),
                DropdownMenuItem(value: 'Technical Support', child: Text('Technical Support')),
                DropdownMenuItem(value: 'Billing Issue', child: Text('Billing Issue')),
                DropdownMenuItem(value: 'Feature Request', child: Text('Feature Request')),
                DropdownMenuItem(value: 'Bug Report', child: Text('Bug Report')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: AppTheme.spacingM),
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.subject),
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.message),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: AppTheme.spacingL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitContactForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                ),
                child: const Text(
                  'Send Message',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Other Ways to Reach Us',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            _contactInfoItem(Icons.phone, '+91 495 272 3456', 'Call us during business hours'),
            const SizedBox(height: AppTheme.spacingS),
            _contactInfoItem(Icons.email, 'support@greenloop.in', 'Email us anytime'),
            const SizedBox(height: AppTheme.spacingS),
            _contactInfoItem(Icons.location_on, 'Kozhikode Municipal Corporation, Kerala', 'Visit our office'),
            const SizedBox(height: AppTheme.spacingS),
            _contactInfoItem(Icons.schedule, 'Mon - Fri: 9:00 AM - 6:00 PM', 'Business hours'),
          ],
        ),
      ),
    );
  }

  Widget _contactInfoItem(IconData icon, String info, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryGreen, size: 24),
        const SizedBox(width: AppTheme.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                info,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                description,
                style: TextStyle(
                  color: AppTheme.grey600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupportTicketsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _createNewTicket,
                  icon: const Icon(Icons.add),
                  label: const Text('New Ticket'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildTicketsList(),
        ),
      ],
    );
  }

  Widget _buildTicketsList() {
    final tickets = _getMockTickets();
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
      itemCount: tickets.length,
      itemBuilder: (_, index) => _buildTicketCard(tickets[index]),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    Color statusColor;
    IconData statusIcon;

    switch (ticket['status']) {
      case 'Open':
        statusColor = AppTheme.info;
        statusIcon = Icons.schedule;
        break;
      case 'In Progress':
        statusColor = AppTheme.warning;
        statusIcon = Icons.autorenew;
        break;
      case 'Resolved':
        statusColor = AppTheme.success;
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = AppTheme.grey600;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          ticket['title'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ticket #${ticket['id']} • ${ticket['date']}'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingS, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
              ),
              child: Text(
                ticket['status'],
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _viewTicketDetails(ticket),
      ),
    );
  }

  Widget _buildFAQTab() {
    final faqs = _getMockFAQs();
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      itemCount: faqs.length,
      itemBuilder: (_, index) => _buildFAQItem(faqs[index]),
    );
  }

  Widget _buildFAQItem(Map<String, dynamic> faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: ExpansionTile(
        title: Text(
          faq['question'],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Text(
              faq['answer'],
              style: TextStyle(color: AppTheme.grey700),
            ),
          ),
        ],
      ),
    );
  }

  void _submitContactForm() {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || 
        _subjectController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    // Simulate form submission
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message sent successfully! We\'ll get back to you soon.'),
        backgroundColor: AppTheme.success,
      ),
    );

    // Clear form
    _nameController.clear();
    _emailController.clear();
    _subjectController.clear();
    _messageController.clear();
    _selectedCategory = 'General Inquiry';
  }

  void _createNewTicket() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Create Support Ticket'),
        content: const Text('Support ticket creation feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _viewTicketDetails(Map<String, dynamic> ticket) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Ticket #${ticket['id']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Title: ${ticket['title']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Status: ${ticket['status']}'),
              const SizedBox(height: 8),
              Text('Date: ${ticket['date']}'),
              const SizedBox(height: 8),
              Text('Description: ${ticket['description']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMockTickets() {
    return [
      {
        'id': 'TK2025001',
        'title': 'App not loading properly',
        'status': 'Open',
        'date': 'Dec 28, 2025',
        'description': 'The app crashes when trying to book a pickup',
      },
      {
        'id': 'TK2025002',
        'title': 'Payment issue',
        'status': 'In Progress',
        'date': 'Dec 27, 2025',
        'description': 'Payment was deducted but pickup was not scheduled',
      },
      {
        'id': 'TK2025003',
        'title': 'Feature request: Weekly pickup schedule',
        'status': 'Resolved',
        'date': 'Dec 25, 2025',
        'description': 'Request to add recurring pickup scheduling',
      },
    ];
  }

  List<Map<String, dynamic>> _getMockFAQs() {
    return [
      {
        'question': 'How do I book a waste pickup?',
        'answer': 'You can book a waste pickup by navigating to the "Book Pickup" section in the app. Select your waste type, preferred date and time, and confirm your address.',
      },
      {
        'question': 'What types of waste can I dispose of?',
        'answer': 'GreenLoop accepts dry waste, wet waste, recyclable materials, electronic waste, and hazardous materials. Each type has specific collection schedules.',
      },
      {
        'question': 'How do I earn rewards points?',
        'answer': 'You earn points by booking pickups, proper waste segregation, and participating in community events. Points can be redeemed for discounts and perks.',
      },
      {
        'question': 'What if my pickup is missed?',
        'answer': 'If your scheduled pickup is missed, please contact our support team immediately. We\'ll reschedule your pickup and may offer compensation points.',
      },
      {
        'question': 'How do I update my address?',
        'answer': 'You can update your address in the Profile section. Make sure to update it before booking a pickup to ensure accurate service.',
      },
    ];
  }
}
