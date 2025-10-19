import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hidden_gem/components/addHiddenGem.dart';
import 'package:hidden_gem/components/gemWidget.dart';
import 'package:hidden_gem/model/hiddengem.dart';
import 'package:hidden_gem/service/hidden_gem_service.dart';
import 'package:location/location.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: MapWidget());
  }
}

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});
  @override
  State<MapWidget> createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> {
  Location locationController = Location();
  final Set<Marker> _markers = {};
  final HiddenGemService hiddenGemService = HiddenGemService();
  LatLng? currentPosition = const LatLng(56.182244, 15.59908055);
  final Completer<GoogleMapController> mapController =
      Completer<GoogleMapController>();
  bool pickingLocation = false;
  LatLng? selectedPosition;

  @override
  void initState() {
    super.initState();
    getLocation();
    _listenToMarkers();
  }

  void _listenToMarkers() {
    hiddenGemService.getUserAndFriendsGems().listen((gems) {
      setState(() {
        _markers
          ..clear()
          ..addAll(gems.map((gem) => buildMarker(gem)));
      });
    });
  }

  Marker buildMarker(HiddenGem gem) {
    return Marker(
      markerId: MarkerId(gem.id),
      position: LatLng(gem.latitude, gem.longitude),
      icon: hiddenGemService.isUsersPost(gem.ownerId)
          ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
          : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => Dialog(child: gemWidget(context, gem)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: currentPosition!,
              zoom: 16,
            ),
            onMapCreated: (controller) => mapController.complete(controller),
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            markers: _markers,
            onCameraMove: (pos) {
              if (pickingLocation) {
                setState(() => selectedPosition = pos.target);
              }
            },
          ),

          if (pickingLocation)
            const Center(
              child: Icon(Icons.location_pin, color: Colors.red, size: 50),
            ),

          if (pickingLocation)
            Positioned(
              bottom: 80,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  if (selectedPosition != null) {
                    setState(() => pickingLocation = false);
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AddHiddenGem(selectedPosition: selectedPosition);
                      },
                    );
                  }
                },
                child: const Text("Confirm location"),
              ),
            ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("Add Hidden Gem"),
        onPressed: () {
          setState(() => pickingLocation = true);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Select a location")));
        },
      ),
    );
  }

  Future<void> getLocation() async {
    bool isEnabled = await locationController.serviceEnabled();
    if (!isEnabled) {
      isEnabled = await locationController.requestService();
      if (!isEnabled) return;
    }

    PermissionStatus permissionGranted = await locationController
        .hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    LocationData locationData = await locationController.getLocation();
    if (locationData.latitude != null && locationData.longitude != null) {
      LatLng newPos = LatLng(locationData.latitude!, locationData.longitude!);
      setState(() => currentPosition = newPos);

      if (mapController.isCompleted) {
        final GoogleMapController controller = await mapController.future;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: newPos, zoom: 16),
          ),
        );
      }
    }
  }
}
