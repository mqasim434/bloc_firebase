import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationProvider extends ChangeNotifier {

  LocationProvider(){
    getLiveLocation();
  }

  final Completer<GoogleMapController> completer =
  Completer<GoogleMapController>();

  CameraPosition defaultLocation = const CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 16,
  );

  CameraPosition liveLocation =
  const CameraPosition(target: LatLng(32.6434984, 74.1933507), zoom: 16);

  List<Marker> markersList = [];

  void getLiveLocation(){
    Geolocator.getPositionStream().listen((location)async{
      defaultLocation = CameraPosition(target: LatLng(location.latitude, location.longitude), zoom: 16);
      GoogleMapController controller = await completer.future;
      markersList.add(Marker(markerId: const MarkerId("Current Position"),position: liveLocation.target));
      controller.animateCamera(CameraUpdate.newCameraPosition(liveLocation));
      notifyListeners();
    });
  }
}
