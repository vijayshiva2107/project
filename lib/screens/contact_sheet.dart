import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/freelancer.dart';
import '../theme/app_theme.dart';
import '../widgets/availability_badge.dart';

void showContactSheet(BuildContext context, Freelancer freelancer) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => ContactSheet(freelancer: freelancer),
  );
}

class ContactSheet extends StatelessWidget {
  final Freelancer freelancer;
  const ContactSheet({super.key, required this.freelancer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          /// HEADER
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: freelancer.avatarColor.withOpacity(0.2),
                  border: Border.all(
                    color: freelancer.avatarColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    freelancer.initials,
                    style: TextStyle(
                      color: freelancer.avatarColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      freelancer.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AvailabilityBadge(status: freelancer.availability),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          /// CALL
          _ContactBtn(
            icon: Icons.call_rounded,
            label: 'Call ${freelancer.name.split(' ').first}',
            sub: freelancer.phone,
            color: AppTheme.available,
            onTap: () => _launchUrl(
              'tel:${freelancer.phone.replaceAll(RegExp(r"\s+"), "")}',
            ),
          ),

          const SizedBox(height: 12),

          /// WHATSAPP
          _ContactBtn(
            icon: Icons.message_rounded,
            label: 'Message on WhatsApp',
            sub: 'Fastest response time',
            color: const Color(0xFF25D366),
            onTap: () => _openWhatsApp(freelancer.phone),
          ),

          const SizedBox(height: 12),

          /// EMAIL
          _ContactBtn(
            icon: Icons.email_rounded,
            label: 'Send an Email',
            sub: freelancer.email,
            color: AppTheme.accent,
            onTap: () => _launchUrl('mailto:${freelancer.email}'),
          ),
        ],
      ),
    );
  }

  /// 🔥 GENERIC LAUNCH FUNCTION (FOR CALL + EMAIL)
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);

    try {
      if (!await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // 🔥 FORCE APP
      )) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint("Launch error: $e");
    }
  }

  /// 🔥 WHATSAPP FUNCTION (APP FIRST, WEB FALLBACK)
  Future<void> _openWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r"[^\d]"), "");

    final whatsappAppUrl = Uri.parse("whatsapp://send?phone=$cleanPhone");
    final whatsappWebUrl = Uri.parse("https://wa.me/$cleanPhone");

    try {
      if (await canLaunchUrl(whatsappAppUrl)) {
        await launchUrl(
          whatsappAppUrl,
          mode: LaunchMode.externalApplication,
        );
      } else {
        await launchUrl(
          whatsappWebUrl,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      debugPrint("WhatsApp error: $e");
    }
  }
}

/// BUTTON WIDGET
class _ContactBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final Color color;
  final VoidCallback onTap;

  const _ContactBtn({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}