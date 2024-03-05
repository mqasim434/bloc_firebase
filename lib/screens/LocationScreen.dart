import 'dart:async';

import 'package:bloc_firebase/providers/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class LiveLocationScreen extends StatelessWidget {
  const LiveLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    return SafeArea(
      child: Scaffold(
        body: GoogleMap(
          initialCameraPosition:
              locationProvider.defaultLocation,
          onMapCreated: (GoogleMapController controller) {
            if(!locationProvider.completer.isCompleted){
              locationProvider.completer.complete(controller);
            }
          },
          markers: Set.from(locationProvider.markersList),
        ),
      ),
    );
  }
}
