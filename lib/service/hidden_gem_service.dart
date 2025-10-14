import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HiddenGemService {
  Future<bool> uploadHiddenGem(
    String name,
    String description,
    List<String> images,
    LatLng selectedPosition,
    bool isPublic,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final gemRef = await FirebaseFirestore.instance.collection("Gems").add({
        "name": name,
        "description": description,
        "images": images,
        "latitude": selectedPosition.latitude,
        "longitude": selectedPosition.longitude,
        "ownerId": user!.uid,
        "isPublic": isPublic,
      });

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {
          'gems': FieldValue.arrayUnion([gemRef.id]),
        },
      );

      return true;
    } catch (e) {
      print("Error uploading gem: $e");
      return false;
    }
  }
}
