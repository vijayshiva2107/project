import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class Freelancer {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String city;
  final String category;
  final String skills;       // comma-separated raw string
  final int ratePerHour;
  final String bio;
  final String availability; // "available" | "busy" | "offline"
  final double lat;
  final double lng;
  final DateTime registeredAt;

  const Freelancer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.city,
    required this.category,
    required this.skills,
    required this.ratePerHour,
    required this.bio,
    required this.availability,
    required this.lat,
    required this.lng,
    required this.registeredAt,
  });

  List<String> get skillList =>
      skills.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (name.length >= 2) return name.substring(0, 2).toUpperCase();
    return name.toUpperCase();
  }

  Color get avatarColor {
    final idx = name.codeUnits.fold(0, (a, b) => a + b) % AppTheme.avatarPalette.length;
    return AppTheme.avatarPalette[idx];
  }

  Color get availabilityColor {
    switch (availability) {
      case 'available': return AppTheme.available;
      case 'busy':      return AppTheme.busy;
      default:          return AppTheme.offline;
    }
  }

  String get availabilityLabel {
    switch (availability) {
      case 'available': return 'Available Now';
      case 'busy':      return 'Busy';
      default:          return 'Offline';
    }
  }

  factory Freelancer.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Freelancer(
      id:           doc.id,
      name:         d['name'] as String? ?? '',
      phone:        d['phone'] as String? ?? '',
      email:        d['email'] as String? ?? '',
      city:         d['city'] as String? ?? '',
      category:     d['category'] as String? ?? '',
      skills:       d['skills'] as String? ?? '',
      ratePerHour:  (d['ratePerHour'] as num?)?.toInt() ?? 0,
      bio:          d['bio'] as String? ?? '',
      availability: d['availability'] as String? ?? 'offline',
      lat:          (d['lat'] as num?)?.toDouble() ?? 0.0,
      lng:          (d['lng'] as num?)?.toDouble() ?? 0.0,
      registeredAt: (d['registeredAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name':         name,
    'phone':        phone,
    'email':        email,
    'city':         city,
    'category':     category,
    'skills':       skills,
    'ratePerHour':  ratePerHour,
    'bio':          bio,
    'availability': availability,
    'lat':          lat,
    'lng':          lng,
    'registeredAt': FieldValue.serverTimestamp(),
  };
}
