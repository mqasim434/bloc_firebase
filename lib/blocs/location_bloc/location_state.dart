import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationState extends Equatable {
  CameraPosition? cameraPosition;

  LocationState({
    this.cameraPosition = const CameraPosition(
      target: LatLng(37.42796133580664, -122.085749655962),
      zoom: 14.4746,
    ),
  });

  LocationState copyWith(CameraPosition? cameraPosition) {
    return LocationState(cameraPosition: cameraPosition ?? this.cameraPosition);
  }

  @override
  List<CameraPosition?> get props => [cameraPosition];
}
