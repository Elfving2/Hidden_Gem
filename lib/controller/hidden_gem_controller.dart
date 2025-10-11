import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hidden_gem/model/hiddengem.dart';

class MarkerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 Listen for live marker updates
  Stream<List<HiddenGem>> getUserGemStream(String userId) {
    return _firestore
        .collection('Gems')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return HiddenGem(
              id: doc.id,
              name: data['name'],
              description: data['description'],
              latitude: data['latitude'],
              longitude: data['longitude'],
              imageUrls: List<String>.from(data['images'] ?? []),
            );
          }).toList();
        });
  }
}
