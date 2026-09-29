import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/medicine.dart';

class MedicineService {
  static final MedicineService _instance = MedicineService._internal();

  factory MedicineService() {
    return _instance;
  }

  MedicineService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the currently logged-in user's medicine collection
  CollectionReference<Map<String, dynamic>> get _medicineCollection {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('medicines');
  }

  // Add medicine
  Future<void> addMedicine(Medicine medicine) async {
    await _medicineCollection.doc(medicine.id).set(
      medicine.toJson(),
    );
  }

  // Update medicine
  Future<void> updateMedicine(Medicine medicine) async {
    await _medicineCollection.doc(medicine.id).update(
      medicine.toJson(),
    );
  }

  // Delete medicine
  Future<void> deleteMedicine(String id) async {
    await _medicineCollection.doc(id).delete();
  }

  // Get one medicine
  Future<Medicine?> getMedicineById(String id) async {
    final doc = await _medicineCollection.doc(id).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return Medicine.fromJson(doc.data()!);
  }

  // Get all medicines
  Future<List<Medicine>> getMedicines() async {
    final snapshot = await _medicineCollection.get();

    return snapshot.docs.map((doc) {
      return Medicine.fromJson(doc.data());
    }).toList();
  }

  // Listen to medicines in real time
  Stream<List<Medicine>> medicinesStream() {
    return _medicineCollection
        .orderBy('expiryDate')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Medicine.fromJson(doc.data());
      }).toList();
    });
  }
}