import 'package:bloc_firebase/providers/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class LiveLocationScreen extends StatefulWidget {
  const LiveLocationScreen({super.key});

  @override
  State<LiveLocationScreen> createState() => _LiveLocationScreenState();
}

class _LiveLocationScreenState extends State<LiveLocationScreen> {
  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Live Location'),
          centerTitle: true,
        ),
        body: GoogleMap(
          initialCameraPosition: locationProvider.initialPosition,
          markers: Set.of(locationProvider.markersList),
          polylines: Set.of(locationProvider.polylinesList),
          onMapCreated: (GoogleMapController controller) {
            locationProvider.completer.complete(controller);
          },
          onTap: (value) {
            locationProvider.addMarker(
              Marker(
                  markerId: const MarkerId('1'), position: value, onTap: () {}),
            );
          },
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              onPressed: () {
                locationProvider.trackLiveLocation();
              },
              child: const Icon(Icons.arrow_forward),
            ),
            const SizedBox(
              width: 20,
            ),
            FloatingActionButton(
              onPressed: () async {
                locationProvider.determinePosition().then((value) async {
                  CameraPosition newCameraPosition = CameraPosition(
                    target: LatLng(value.latitude, value.longitude),
                    zoom: 16,
                  );
                  locationProvider.addMarker(
                    Marker(
                      markerId: const MarkerId(
                        'Current Location',
                      ),
                      position: LatLng(value.latitude, value.longitude),
                    ),
                  );
                  GoogleMapController controller =
                      await locationProvider.completer.future;
                  controller.animateCamera(
                    CameraUpdate.newCameraPosition(newCameraPosition),
                  );
                });
              },
              child: const Icon(Icons.location_history),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
