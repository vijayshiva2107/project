import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/freelancer_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/freelancer_card.dart';
import 'freelancer_profile_screen.dart';
import 'contact_sheet.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final _searchCtrl = TextEditingController();
  bool _showFilters = false;

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: const Text('Browse Freelancers'),
        actions: [
          Consumer<FreelancerProvider>(
            builder: (_, p, __) => IconButton(
              icon: Stack(children: [
                const Icon(Icons.tune_rounded),
                if (p.hasFilters)
                  Positioned(
                    right: 0, top: 0,
                    child: Container(
                      width: 7, height: 7,
                      decoration: const BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle),
                    ),
                  ),
              ]),
              onPressed: () => setState(() => _showFilters = !_showFilters),
            ),
          ),
        ],
      ),
      body: Column(children: [
        _buildSearchBar(),
        _buildSortRow(),
        if (_showFilters) _buildFilterPanel(),
        _buildResultsHeader(),
        Expanded(child: _buildList()),
      ]),
    );
  }

  Widget _buildSearchBar() {
    return Consumer<FreelancerProvider>(builder: (_, p, __) {
      if (_searchCtrl.text != p.search) _searchCtrl.text = p.search;
      return Container(
        color: AppTheme.surface,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: TextField(
          controller: _searchCtrl,
          onChanged: p.setSearch,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search name, skill, city...',
            prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppTheme.textMuted),
            suffixIcon: p.search.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, size: 16, color: AppTheme.textMuted),
                    onPressed: () { _searchCtrl.clear(); p.setSearch(''); })
                : null,
          ),
        ),
      );
    });
  }

  Widget _buildSortRow() {
    return Consumer<FreelancerProvider>(builder: (_, p, __) {
      return Container(
        color: AppTheme.surface,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: Row(children: [
          const Text('Sort:', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(width: 8),
          _SortChip(
            label: '📍 Nearest',
            selected: p.sortMode == SortMode.nearest,
            onTap: () => p.setSortMode(SortMode.nearest),
          ),
          const SizedBox(width: 6),
          _SortChip(
            label: '🕐 Latest',
            selected: p.sortMode == SortMode.latest,
            onTap: () => p.setSortMode(SortMode.latest),
          ),
          const Spacer(),
          if (p.userPosition == null && p.locationLoaded)
            const Row(children: [
              Icon(Icons.location_off, size: 11, color: AppTheme.textMuted),
              SizedBox(width: 3),
              Text('No GPS', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
            ]),
        ]),
      );
    });
  }

  Widget _buildFilterPanel() {
    return Consumer<FreelancerProvider>(builder: (_, p, __) {
      return Container(
        color: AppTheme.surfaceHigh,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('Filters', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const Spacer(),
            if (p.hasFilters)
              GestureDetector(
                onTap: p.resetFilters,
                child: const Text('Reset all', style: TextStyle(fontSize: 12, color: AppTheme.accent)),
              ),
          ]),
          const SizedBox(height: 10),

          // Availability filter
          const Text('Availability', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          const SizedBox(height: 6),
          SizedBox(
            height: 30,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['All', 'available', 'busy', 'offline'].map((s) {
                final labels = {'All': 'All', 'available': 'Available Now', 'busy': 'Busy', 'offline': 'Offline'};
                final selected = p.availability == s;
                return GestureDetector(
                  onTap: () => p.setAvailability(s),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.accent.withOpacity(0.15) : AppTheme.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: selected ? AppTheme.accent : AppTheme.border),
                    ),
                    child: Text(labels[s]!, style: TextStyle(fontSize: 11, color: selected ? AppTheme.accent : AppTheme.textSecondary, fontWeight: selected ? FontWeight.w700 : FontWeight.normal)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),

          // City filter
          const Text('City', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          const SizedBox(height: 6),
          SizedBox(
            height: 30,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: p.availableCities.map((city) {
                final selected = p.city == city;
                return GestureDetector(
                  onTap: () => p.setCity(city),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.surfaceHigh : AppTheme.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: selected ? AppTheme.accent : AppTheme.border),
                    ),
                    child: Text(city, style: TextStyle(fontSize: 11, color: selected ? AppTheme.accent : AppTheme.textSecondary, fontWeight: selected ? FontWeight.w700 : FontWeight.normal)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),

          // Rate slider
          Row(children: [
            const Text('Max Rate: ', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            Text('₹${p.maxRate}/hr', style: const TextStyle(fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.w700)),
          ]),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.accent,
              inactiveTrackColor: AppTheme.border,
              thumbColor: AppTheme.accent,
              overlayColor: AppTheme.accent.withOpacity(0.15),
              trackHeight: 2,
            ),
            child: Slider(
              value: p.maxRate.toDouble(),
              min: 100, max: 2000, divisions: 38,
              onChanged: (v) => p.setMaxRate(v.round()),
            ),
          ),
        ]),
      );
    });
  }

  Widget _buildResultsHeader() {
    return Consumer<FreelancerProvider>(builder: (_, p, __) {
      final count = p.filtered.length;
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Row(children: [
          Text('$count freelancer${count != 1 ? 's' : ''}', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          if (p.sortMode == SortMode.nearest && p.userPosition != null) ...[
            const SizedBox(width: 6),
            const Icon(Icons.near_me, size: 12, color: AppTheme.accent),
            const SizedBox(width: 2),
            const Text('sorted by distance', style: TextStyle(fontSize: 11, color: AppTheme.accent)),
          ],
        ]),
      );
    });
  }

  Widget _buildList() {
    return Consumer<FreelancerProvider>(builder: (_, p, __) {
      final list = p.filtered;
      if (list.isEmpty) {
        return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.person_search, size: 56, color: AppTheme.textMuted.withOpacity(0.4)),
            const SizedBox(height: 14),
            const Text('No freelancers found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
            const SizedBox(height: 6),
            const Text('Try changing your filters', style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
            const SizedBox(height: 20),
            TextButton(onPressed: p.resetFilters, child: const Text('Reset filters', style: TextStyle(color: AppTheme.accent))),
          ]),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: list.length,
        itemBuilder: (context, i) {
          final f = list[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: FreelancerCard(
              freelancer: f,
              distanceLabel: p.distanceLabel(f),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FreelancerProfileScreen(freelancer: f, distanceLabel: p.distanceLabel(f)))),
              onContact: () => showContactSheet(context, f),
            ),
          );
        },
      );
    });
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SortChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accent.withOpacity(0.15) : AppTheme.surfaceHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? AppTheme.accent : AppTheme.border),
        ),
        child: Text(label, style: TextStyle(fontSize: 11, color: selected ? AppTheme.accent : AppTheme.textSecondary, fontWeight: selected ? FontWeight.w700 : FontWeight.normal)),
      ),
    );
  }
}
