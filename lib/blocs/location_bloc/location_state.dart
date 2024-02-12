import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationState {
  CameraPosition? cameraPosition;
  LocationState({required this.cameraPosition});

  LocationState copyWith({CameraPosition? cameraPosition}){
    return LocationState(
      cameraPosition: cameraPosition?? this.cameraPosition,
    );
  }

  @override
  List<Object?> get props => [cameraPosition];
}