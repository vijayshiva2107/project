import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/freelancer.dart';
import '../services/firestore_service.dart';

enum SortMode { nearest, latest }

class FreelancerProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  List<Freelancer> _all = [];
  String _search = '';
  String _category = 'All';
  String _city = 'All Cities';
  int _maxRate = 2000;
  String _availability = 'All';
  SortMode _sortMode = SortMode.nearest;
  Position? _userPosition;
  bool _locationLoaded = false;

  FreelancerProvider() {
    _subscribeToFirestore();
    _requestLocation();
  }

  void _subscribeToFirestore() {
    _service.getFreelancers().listen((list) {
      _all = list;
      notifyListeners();
    });
  }

  Future<void> _requestLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) { _locationLoaded = true; notifyListeners(); return; }

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        _locationLoaded = true; notifyListeners(); return;
      }
      _userPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
    } catch (_) {}
    _locationLoaded = true;
    notifyListeners();
  }

  // ── Getters ───────────────────────────────────────────────
  String get search => _search;
  String get category => _category;
  String get city => _city;
  int get maxRate => _maxRate;
  String get availability => _availability;
  SortMode get sortMode => _sortMode;
  Position? get userPosition => _userPosition;
  bool get locationLoaded => _locationLoaded;

  double? distanceTo(Freelancer f) {
    if (_userPosition == null || (f.lat == 0 && f.lng == 0)) return null;
    final d = Geolocator.distanceBetween(
      _userPosition!.latitude, _userPosition!.longitude, f.lat, f.lng,
    );
    return d / 1000; // km
  }

  String distanceLabel(Freelancer f) {
    final d = distanceTo(f);
    if (d == null) return '';
    if (d < 1) return '${(d * 1000).round()} m away';
    return '${d.toStringAsFixed(1)} km away';
  }

  List<Freelancer> get filtered {
    var list = _all.where((f) {
      final q = _search.toLowerCase();
      final matchSearch = q.isEmpty ||
          f.name.toLowerCase().contains(q) ||
          f.category.toLowerCase().contains(q) ||
          f.skills.toLowerCase().contains(q) ||
          f.city.toLowerCase().contains(q);
      final matchCat  = _category == 'All' || f.category == _category;
      final matchCity = _city == 'All Cities' || f.city == _city;
      final matchRate = f.ratePerHour <= _maxRate;
      final matchAvail = _availability == 'All' || f.availability == _availability;
      return matchSearch && matchCat && matchCity && matchRate && matchAvail;
    }).toList();

    if (_sortMode == SortMode.nearest && _userPosition != null) {
      list.sort((a, b) {
        final da = distanceTo(a) ?? double.maxFinite;
        final db = distanceTo(b) ?? double.maxFinite;
        return da.compareTo(db);
      });
    }
    return list;
  }

  bool get hasFilters =>
      _search.isNotEmpty || _category != 'All' || _city != 'All Cities' ||
      _maxRate < 2000 || _availability != 'All';

  List<String> get availableCities {
    final cities = _all.map((f) => f.city).toSet().toList()..sort();
    return ['All Cities', ...cities];
  }

  List<String> get availableCategories {
    final cats = _all.map((f) => f.category).toSet().toList()..sort();
    return ['All', ...cats];
  }

  // ── Setters ───────────────────────────────────────────────
  void setSearch(String v)       { _search = v;       notifyListeners(); }
  void setCategory(String v)     { _category = v;     notifyListeners(); }
  void setCity(String v)         { _city = v;         notifyListeners(); }
  void setMaxRate(int v)         { _maxRate = v;       notifyListeners(); }
  void setAvailability(String v) { _availability = v; notifyListeners(); }
  void setSortMode(SortMode v)   { _sortMode = v;     notifyListeners(); }

  void resetFilters() {
    _search = ''; _category = 'All'; _city = 'All Cities';
    _maxRate = 2000; _availability = 'All';
    notifyListeners();
  }

  Future<void> register(Freelancer f) => _service.registerFreelancer(f);
}
