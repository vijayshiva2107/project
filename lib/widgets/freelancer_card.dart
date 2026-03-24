import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/freelancer.dart';
import '../providers/freelancer_provider.dart';
import '../theme/app_theme.dart';
import 'availability_badge.dart';

class FreelancerCard extends StatelessWidget {
  final Freelancer freelancer;
  final String distanceLabel;
  final VoidCallback onTap;
  final VoidCallback onContact;

  const FreelancerCard({
    super.key,
    required this.freelancer,
    required this.distanceLabel,
    required this.onTap,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 10),
            _buildMeta(),
            const SizedBox(height: 10),
            _buildSkills(),
            const SizedBox(height: 12),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _Avatar(freelancer: freelancer),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                freelancer.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              _CategoryPill(label: freelancer.category),
            ],
          ),
        ),
        AvailabilityBadge(status: freelancer.availability),
      ],
    );
  }

  Widget _buildMeta() {
    return Row(
      children: [
        _MetaItem(icon: Icons.location_on_outlined, text: freelancer.city),
        if (distanceLabel.isNotEmpty) ...[
          const SizedBox(width: 10),
          _MetaItem(
            icon: Icons.near_me_outlined,
            text: distanceLabel,
            color: AppTheme.accent,
          ),
        ],
      ],
    );
  }

  Widget _buildSkills() {
    return Wrap(
      spacing: 6,
      runSpacing: 5,
      children: freelancer.skillList.take(3).map((s) => _SkillChip(s)).toList(),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '₹${freelancer.ratePerHour}/hr',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppTheme.accent,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: onContact,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              color: AppTheme.accent,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Text(
              'Contact',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Sub-widgets ─────────────────────────────────────────────────

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.card.withOpacity(0.85),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.borderGlass, width: 1),
          ),
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final Freelancer freelancer;
  const _Avatar({required this.freelancer});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: freelancer.avatarColor.withOpacity(0.2),
        border: Border.all(color: freelancer.avatarColor.withOpacity(0.5), width: 1.5),
      ),
      child: Center(
        child: Text(
          freelancer.initials,
          style: TextStyle(
            color: freelancer.avatarColor,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String label;
  const _CategoryPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, color: AppTheme.accent, fontWeight: FontWeight.w700),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _MetaItem({required this.icon, required this.text, this.color = AppTheme.textSecondary});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(text, style: TextStyle(fontSize: 11, color: color)),
      ],
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  const _SkillChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.surfaceHigh,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.border),
      ),
      child: Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
    );
  }
}
