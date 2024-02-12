import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class LocationEvent extends Equatable {

  @override
  List<Object?> get props => [];
}

class GetCurrentLocationEvent extends LocationEvent {
  CameraPosition? cameraPosition;
  GetCurrentLocationEvent({this.cameraPosition});
  @override
  // TODO: implement props
  List<Object?> get props => [cameraPosition];
}

class ResetLocationEvent extends LocationEvent {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}