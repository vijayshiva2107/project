import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/freelancer.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  final String _col = 'freelancers';

  /// Real-time stream of all freelancers
  Stream<List<Freelancer>> getFreelancers() {
    return _db
        .collection(_col)
        .orderBy('registeredAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Freelancer.fromFirestore).toList());
  }

  /// Register a new freelancer
  Future<void> registerFreelancer(Freelancer freelancer) {
    return _db.collection(_col).add(freelancer.toJson());
  }

  /// Update availability status only
  Future<void> updateAvailability(String id, String status) {
    return _db.collection(_col).doc(id).update({'availability': status});
  }
}
