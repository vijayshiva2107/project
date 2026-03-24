import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../models/freelancer.dart';
import '../providers/freelancer_provider.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _phoneCtrl  = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _cityCtrl   = TextEditingController();
  final _skillsCtrl = TextEditingController();
  final _rateCtrl   = TextEditingController();
  final _bioCtrl    = TextEditingController();

  String _category = 'Development';
  String _availability = 'available';
  bool _isLoading = false;

  final List<String> _categories = [
    'Development', 'Design', 'Writing', 'Marketing', 'Photography', 'Tutoring', 'Home Repair'
  ];

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose(); _emailCtrl.dispose();
    _cityCtrl.dispose(); _skillsCtrl.dispose(); _rateCtrl.dispose(); _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('List Your Services')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _SectionTitle('Personal Details'),
            _Field(ctrl: _nameCtrl, label: 'Full Name', icon: Icons.person_outline),
            _Field(ctrl: _phoneCtrl, label: 'Phone Number', icon: Icons.phone_outlined, type: TextInputType.phone),
            _Field(ctrl: _emailCtrl, label: 'Email Address', icon: Icons.email_outlined, type: TextInputType.emailAddress),
            _Field(ctrl: _cityCtrl, label: 'City', icon: Icons.location_city_outlined),
            const SizedBox(height: 32),

            _SectionTitle('Professional Profile'),
            _Dropdown(
              value: _category,
              items: _categories,
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),
            _Field(ctrl: _skillsCtrl, label: 'Skills (comma separated)', icon: Icons.stars_outlined, hint: 'e.g. Flutter, Firebase, UI/UX'),
            _Field(ctrl: _rateCtrl, label: 'Hourly Rate (₹)', icon: Icons.currency_rupee, type: TextInputType.number),
            TextFormField(
              controller: _bioCtrl,
              maxLines: 4,
              validator: (v) => v!.length < 20 ? 'Bio must be at least 20 chars' : null,
              decoration: const InputDecoration(hintText: 'Write a short bio about your experience (min 20 chars)...'),
            ),
            const SizedBox(height: 32),

            _SectionTitle('Current Status'),
            Row(children: [
              _StatusRadio('available', 'Available Now', AppTheme.available),
              _StatusRadio('busy', 'Busy', AppTheme.busy),
            ]),
            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : const Text('Publish Profile'),
              ),
            ),
            const SizedBox(height: 40),
          ]),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.15), shape: BoxShape.circle),
          child: const Icon(Icons.rocket_launch, color: AppTheme.accent),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Join the network', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            SizedBox(height: 4),
            Text('Clients nearby will be able to see your GPS distance and hire you.', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4)),
          ]),
        ),
      ]),
    );
  }

  Widget _StatusRadio(String val, String label, Color color) {
    return Expanded(
      child: RadioListTile<String>(
        value: val,
        groupValue: _availability,
        onChanged: (v) => setState(() => _availability = v!),
        title: Text(label, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600)),
        activeColor: color,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // 1. Capture Location
      double lat = 0, lng = 0;
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.whileInUse || perm == LocationPermission.always) {
          final pos = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.low));
          lat = pos.latitude;
          lng = pos.longitude;
        }
      }

      // 2. Build model
      final freelancer = Freelancer(
        id: '', // Firestore generates this
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        category: _category,
        skills: _skillsCtrl.text.trim(),
        ratePerHour: int.tryParse(_rateCtrl.text.trim()) ?? 0,
        bio: _bioCtrl.text.trim(),
        availability: _availability,
        lat: lat,
        lng: lng,
        registeredAt: DateTime.now(),
      );

      // 3. Save to Firestore
      if (!mounted) return;
      await context.read<FreelancerProvider>().register(freelancer);

      // 4. Success Dialog
      if (!mounted) return;
      _showSuccess();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.available.withOpacity(0.15), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_outline, color: AppTheme.available, size: 40),
            ),
            const SizedBox(height: 20),
            const Text('Profile Live!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            const Text('You are now visible to clients nearby in real-time.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // back to home
              },
              child: const Text('Go to Browse'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: -0.2)),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final TextInputType? type;
  final String? hint;

  const _Field({required this.ctrl, required this.label, required this.icon, this.type, this.hint});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: type,
        validator: (v) => v!.trim().isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 18, color: AppTheme.textMuted),
        ),
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _Dropdown({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppTheme.surfaceHigh,
          icon: const Icon(Icons.expand_more, color: AppTheme.textMuted),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
