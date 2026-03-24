import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/freelancer_provider.dart';
import '../theme/app_theme.dart';
import 'browse_screen.dart';
import 'register_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<Map<String, dynamic>> _categories = [
    {'icon': Icons.code_rounded,                'label': 'Development'},
    {'icon': Icons.brush_rounded,               'label': 'Design'},
    {'icon': Icons.edit_note_rounded,           'label': 'Writing'},
    {'icon': Icons.trending_up_rounded,         'label': 'Marketing'},
    {'icon': Icons.camera_alt_rounded,          'label': 'Photography'},
    {'icon': Icons.school_rounded,              'label': 'Tutoring'},
    {'icon': Icons.home_repair_service_rounded, 'label': 'Home Repair'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: _buildSearchBar(context)),
            SliverToBoxAdapter(child: _buildCategories(context)),
            SliverToBoxAdapter(child: _buildStatsRow(context)),
            SliverToBoxAdapter(child: _buildCTACard(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 32, 22, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.bolt_rounded, size: 12, color: AppTheme.accent),
                  const SizedBox(width: 4),
                  const Text('LocalHire', style: TextStyle(color: AppTheme.accent, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                ]),
              ),
              const Spacer(),
              Consumer<FreelancerProvider>(
                builder: (_, p, __) => p.userPosition != null
                    ? const Row(children: [
                        Icon(Icons.my_location, size: 13, color: AppTheme.available),
                        SizedBox(width: 4),
                        Text('Location ON', style: TextStyle(fontSize: 11, color: AppTheme.available)),
                      ])
                    : const Row(children: [
                        Icon(Icons.location_off, size: 13, color: AppTheme.textMuted),
                        SizedBox(width: 4),
                        Text('Location OFF', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                      ]),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Find skilled\nfreelancers\nnear you.',
            style: TextStyle(
              fontSize: 38,
              height: 1.1,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -1.5,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Real people. Real skills. Right in your city.',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, _route(const BrowseScreen())),
      child: Container(
        margin: const EdgeInsets.fromLTRB(22, 24, 22, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceHigh,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(children: [
          const Icon(Icons.search_rounded, size: 18, color: AppTheme.textMuted),
          const SizedBox(width: 10),
          const Text('Search by skill, city, name...', style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('Search', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ]),
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(22, 28, 22, 14),
          child: Text('Categories', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: -0.3)),
        ),
        SizedBox(
          height: 84,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            itemCount: _categories.length,
            itemBuilder: (context, i) {
              final cat = _categories[i];
              return GestureDetector(
                onTap: () {
                  context.read<FreelancerProvider>().setCategory(cat['label'] as String);
                  Navigator.push(context, _route(const BrowseScreen()));
                },
                child: Container(
                  width: 72,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceHigh,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(cat['icon'] as IconData, size: 22, color: AppTheme.accent),
                    const SizedBox(height: 6),
                    Text(
                      (cat['label'] as String).replaceAll(' ', '\n'),
                      style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary, fontWeight: FontWeight.w600, height: 1.2),
                      textAlign: TextAlign.center,
                    ),
                  ]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Consumer<FreelancerProvider>(
      builder: (_, provider, __) {
        final total = provider.filtered.length;
        final avail = provider.filtered.where((f) => f.availability == 'available').length;
        final cities = provider.filtered.map((f) => f.city).toSet().length;
        return Container(
          margin: const EdgeInsets.fromLTRB(22, 24, 22, 0),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceHigh,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(value: '$total', label: 'Freelancers'),
              Container(width: 1, height: 32, color: AppTheme.border),
              _StatItem(value: '$avail', label: 'Available Now', valueColor: AppTheme.available),
              Container(width: 1, height: 32, color: AppTheme.border),
              _StatItem(value: '$cities', label: 'Cities'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCTACard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, _route(const RegisterScreen())),
      child: Container(
        margin: const EdgeInsets.fromLTRB(22, 16, 22, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1C1708), Color(0xFF241D0A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.accent.withOpacity(0.25)),
        ),
        child: Row(children: [
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Are you a freelancer?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, letterSpacing: -0.3)),
              SizedBox(height: 4),
              Text('List yourself & get hired locally', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(22)),
            child: const Text('Join Free', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 12)),
          ),
        ]),
      ),
    );
  }

  Route _route(Widget page) => MaterialPageRoute(builder: (_) => page);
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;
  const _StatItem({required this.value, required this.label, this.valueColor = AppTheme.accent});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: valueColor, letterSpacing: -0.5)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
    ]);
  }
}
