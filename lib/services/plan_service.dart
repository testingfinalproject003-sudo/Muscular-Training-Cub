import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ai_plan_model.dart';

class PlanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  CollectionReference get _plansCollection => _firestore.collection('ai_plans');

  // Stream of pending/active plans for home screen
  Stream<List<AIPlanModel>> getPendingPlans(String userId) {
    return _plansCollection
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: ['pending', 'accepted'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => AIPlanModel.fromFirestore(doc)).toList());
  }

  // Stream of plan history
  Stream<List<AIPlanModel>> getPlanHistory(String userId) {
    return _plansCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => AIPlanModel.fromFirestore(doc)).toList());
  }

  // Save new plan from AI
  Future<String> savePlan(AIPlanModel plan) async {
    final docRef = await _plansCollection.add(plan.toFirestore());
    return docRef.id;
  }

  // Accept plan
  Future<void> acceptPlan(String planId) async {
    await _plansCollection.doc(planId).update({
      'status': 'accepted',
      'acceptedAt': Timestamp.now(),
    });
  }

  // Reject plan
  Future<void> rejectPlan(String planId) async {
    await _plansCollection.doc(planId).update({
      'status': 'rejected',
    });
  }

  // Mark as completed
  Future<void> completePlan(String planId) async {
    await _plansCollection.doc(planId).update({
      'status': 'completed',
    });
  }

  // Delete plan
  Future<void> deletePlan(String planId) async {
    await _plansCollection.doc(planId).delete();
  }
}