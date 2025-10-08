import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HiddenGemService {
  Future<bool> uploadHiddenGem(
    String name,
    String description,
    List<String> images,
    LatLng selectedPosition,
  ) async {
    try {
      FirebaseFirestore.instance.collection("Gems").add({
        "name": name,
        "description": description,
        "images": images,
        "lattitude": selectedPosition.latitude,
        "longitude": selectedPosition.longitude,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<Set<Marker>> getMarkerStream() {
    return FirebaseFirestore.instance.collection('gems').snapshots().map((
      snapshot,
    ) {
      final markers = snapshot.docs.map((doc) {
        final data = doc.data();
        return Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(data['lat'], data['lng']),
          infoWindow: InfoWindow(title: data['name']),
        );
      }).toSet();

      return markers;
    });
  }
}
