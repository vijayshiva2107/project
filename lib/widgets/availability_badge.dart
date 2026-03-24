import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AvailabilityBadge extends StatefulWidget {
  final String status;
  final bool large;
  const AvailabilityBadge({super.key, required this.status, this.large = false});

  @override
  State<AvailabilityBadge> createState() => _AvailabilityBadgeState();
}

class _AvailabilityBadgeState extends State<AvailabilityBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get color {
    switch (widget.status) {
      case 'available': return AppTheme.available;
      case 'busy':      return AppTheme.busy;
      default:          return AppTheme.offline;
    }
  }

  String get label {
    switch (widget.status) {
      case 'available': return 'Available Now';
      case 'busy':      return 'Busy';
      default:          return 'Offline';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dotSize = widget.large ? 8.0 : 6.0;
    final fontSize = widget.large ? 12.0 : 10.0;
    final hPad    = widget.large ? 10.0 : 7.0;
    final vPad    = widget.large ? 4.0  : 3.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.status == 'available')
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) => Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(_pulse.value),
                  boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 4, spreadRadius: 1)],
                ),
              ),
            )
          else
            Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: fontSize, color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
