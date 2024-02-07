import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationProvider extends ChangeNotifier {
  CameraPosition initialPosition = const CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  final completer = Completer();

  List<Marker> markersList = [];
  List<Polyline> polylinesList = [];
  List<LatLng> latlngsList = [];

  void addMarker(Marker marker) {
    markersList.add(marker);
    latlngsList.add(marker.position);
    polylinesList.add(
      Polyline(
        polylineId: const PolylineId('myPolyline'),
        points: latlngsList,
        endCap: Cap.roundCap,
        color: Colors.blue,
        width: 5,
      ),
    );
    notifyListeners();
  }

  void removeMarker(LatLng latLng) {
    markersList.removeWhere((element) => element.position == latLng);
    notifyListeners();
  }

  void trackLiveLocation(){
    Geolocator.getPositionStream().listen((position) {
      markersList.add(
        Marker(
          markerId: MarkerId('rider'),
          position: LatLng(position.latitude, position.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ),
        ),
      );
      notifyListeners();
    });
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }
}
