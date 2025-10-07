import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hidden_gem/components/hiddengem.dart';

class MarkerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 Listen for live marker updates
  Stream<List<HiddenGem>> getGemStream() {
    return _firestore.collection('Gems').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return HiddenGem(
          id: doc.id,
          name: data['name'],
          description: data['description'],
          latitude: data['lattitude'],
          longitude: data['longitude'],
          imageUrls: List<String>.from(data['images'] ?? []),
        );
      }).toList();
    });
  }

  // /// 🔹 Add a new marker to Firestore
  // Future<void> addMarker(String name, double lat, double lng) async {
  //   await _firestore.collection('markers').add({
  //     'name': name,
  //     'lat': lat,
  //     'lng': lng,
  //   });
  // }

  // /// 🔹 Delete a marker by document ID
  // Future<void> deleteMarker(String markerId) async {
  //   await _firestore.collection('markers').doc(markerId).delete();
  // }

  // /// 🔹 Update an existing marker
  // Future<void> updateMarker(
  //   String markerId,
  //   String name,
  //   double lat,
  //   double lng,
  // ) async {
  //   await _firestore.collection('markers').doc(markerId).update({
  //     'name': name,
  //     'lat': lat,
  //     'lng': lng,
  //   });
  // }
}
