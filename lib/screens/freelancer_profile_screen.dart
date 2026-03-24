import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/freelancer.dart';
import '../theme/app_theme.dart';
import '../widgets/availability_badge.dart';
import 'contact_sheet.dart';

class FreelancerProfileScreen extends StatelessWidget {
  final Freelancer freelancer;
  final String distanceLabel;

  const FreelancerProfileScreen({super.key, required this.freelancer, required this.distanceLabel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildStats(),
                _buildBio(),
                _buildSkills(),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildContactBar(context),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppTheme.background,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Abstract blurred background based on avatar color
            Positioned(
              top: -50, right: -50,
              child: Container(
                width: 200, height: 200,
                decoration: BoxDecoration(shape: BoxShape.circle, color: freelancer.avatarColor.withOpacity(0.3)),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(color: AppTheme.background.withOpacity(0.5)),
            ),
            // Avatar
            Center(
              child: Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: freelancer.avatarColor.withOpacity(0.2),
                  border: Border.all(color: freelancer.avatarColor, width: 3),
                  boxShadow: [BoxShadow(color: freelancer.avatarColor.withOpacity(0.4), blurRadius: 20)],
                ),
                child: Center(child: Text(freelancer.initials, style: TextStyle(color: freelancer.avatarColor, fontSize: 32, fontWeight: FontWeight.w900))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(freelancer.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, letterSpacing: -0.5))),
              AvailabilityBadge(status: freelancer.availability, large: true),
            ],
          ),
          const SizedBox(height: 8),
          Text(freelancer.category, style: const TextStyle(fontSize: 15, color: AppTheme.accent, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text(freelancer.city, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              if (distanceLabel.isNotEmpty) ...[
                const SizedBox(width: 14),
                const Icon(Icons.near_me_outlined, size: 16, color: AppTheme.accent),
                const SizedBox(width: 4),
                Text(distanceLabel, style: const TextStyle(fontSize: 13, color: AppTheme.accent)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.fromLTRB(22, 24, 22, 0),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Stat(value: '₹${freelancer.ratePerHour}', label: 'Per Hour'),
          Container(width: 1, height: 40, color: AppTheme.border),
          const _Stat(value: '100%', label: 'Response Rate'),
        ],
      ),
    );
  }

  Widget _buildBio() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('About', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 10),
          Text(
            freelancer.bio,
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildSkills() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Skills & Expertise', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: freelancer.skillList.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceHigh,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text(skill, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildContactBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(22, 16, 22, MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: ElevatedButton(
        onPressed: () => showContactSheet(context, freelancer),
        child: const Text('Contact Professional', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.accent, letterSpacing: -0.5)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }
}
