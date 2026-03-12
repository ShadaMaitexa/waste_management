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
      backgroundColor: AppTheme.grey50,
      appBar: AppBar(
        title: const Text(
          'Help Center',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.grey900,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.grey100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: AppTheme.primaryGreen,
              unselectedLabelColor: AppTheme.grey500,
              labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'CONTACT'),
                Tab(text: 'TICKETS'),
                Tab(text: 'FAQ'),
              ],
            ),
          ),
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
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryGreen, AppTheme.secondaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.support_agent_rounded, color: Colors.white, size: 48),
          const SizedBox(height: 24),
          const Text(
            'How can we help?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Our team is ready to assist you with any questions or technical issues.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Send a Message',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppTheme.grey900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          _buildField('Full Name', _nameController, Icons.person_outline_rounded),
          const SizedBox(height: 16),
          _buildField('Email Address', _emailController, Icons.email_outlined),
          const SizedBox(height: 16),
          _buildDropdownField(),
          const SizedBox(height: 16),
          _buildField('Subject', _subjectController, Icons.subject_rounded),
          const SizedBox(height: 16),
          _buildField('Message', _messageController, Icons.chat_bubble_outline_rounded, maxLines: 4),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _submitContactForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text(
                'SEND ENQUIRY',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.grey500, fontSize: 13, fontWeight: FontWeight.w600),
        prefixIcon: Icon(icon, color: AppTheme.primaryGreen, size: 20),
        filled: true,
        fillColor: AppTheme.grey50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Category',
        labelStyle: const TextStyle(color: AppTheme.grey500, fontSize: 13, fontWeight: FontWeight.w600),
        prefixIcon: const Icon(Icons.category_outlined, color: AppTheme.primaryGreen, size: 20),
        filled: true,
        fillColor: AppTheme.grey50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
      items: const [
        DropdownMenuItem(value: 'General Inquiry', child: Text('General Inquiry')),
        DropdownMenuItem(value: 'Technical Support', child: Text('Technical Support')),
        DropdownMenuItem(value: 'Billing Issue', child: Text('Billing Issue')),
        DropdownMenuItem(value: 'Feature Request', child: Text('Feature Request')),
        DropdownMenuItem(value: 'Bug Report', child: Text('Bug Report')),
      ],
      onChanged: (value) => setState(() => _selectedCategory = value!),
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Text(
            'QUICK CONTACT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppTheme.grey500,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _contactInfoItem(Icons.phone_rounded, '+91 495 272 3456', 'Customer Care'),
        const SizedBox(height: 12),
        _contactInfoItem(Icons.email_rounded, 'care@greenloop.in', 'Email Support'),
        const SizedBox(height: 12),
        _contactInfoItem(Icons.location_on_rounded, 'Municipal Corp. HQ, Kozhikode', 'Office Address'),
      ],
    );
  }

  Widget _contactInfoItem(IconData icon, String info, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryGreen, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(color: AppTheme.grey500, fontSize: 10, fontWeight: FontWeight.w700),
                ),
                Text(
                  info,
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.grey900, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportTicketsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(colors: [AppTheme.primaryGreen, AppTheme.secondaryGreen]),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _createNewTicket,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text(
                'CREATE NEW TICKET',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
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
        statusIcon = Icons.schedule_rounded;
        break;
      case 'In Progress':
        statusColor = AppTheme.warning;
        statusIcon = Icons.autorenew_rounded;
        break;
      case 'Resolved':
        statusColor = AppTheme.success;
        statusIcon = Icons.check_circle_rounded;
        break;
      default:
        statusColor = AppTheme.grey600;
        statusIcon = Icons.help_outline_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(statusIcon, color: statusColor, size: 22),
        ),
        title: Text(
          ticket['title'],
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppTheme.grey900),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Text(
                'ID: ${ticket['id']}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.grey500),
              ),
              const SizedBox(width: 8),
              Container(width: 3, height: 3, decoration: const BoxDecoration(color: AppTheme.grey300, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(
                ticket['status'].toUpperCase(),
                style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.grey400),
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
