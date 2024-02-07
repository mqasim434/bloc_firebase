import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationEvent extends Equatable{
  @override
  List<Object?> get props => [];

}

class CurrentLocationEvent extends LocationEvent{
  List<Object?> get props => [];
}

class ResetLocationEvent extends LocationEvent{
  List<Object?> get props => [];
}