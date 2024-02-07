import 'package:bloc/bloc.dart';
import 'package:bloc_firebase/blocs/location_bloc/location_event.dart';
import 'package:bloc_firebase/blocs/location_bloc/location_state.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationBloc extends Bloc<LocationEvent,LocationState> {
  LocationBloc()
      : super(
          LocationState(
            cameraPosition: const CameraPosition(
              target: LatLng(37.42796133580664, -122.085749655962),
            ),
          ),
        ) {
    on<CurrentLocationEvent>(
      (event, emit) async{
        Position position = await _determinePosition();
        emit(
          LocationState(
            cameraPosition: CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 14,
            ),
          ),
        );
      },
    );
    on<ResetLocationEvent>(
      (event, emit) => emit(
        LocationState(
          cameraPosition: const CameraPosition(
            target: LatLng(37.42796133580664, -122.085749655962),
            zoom: 14,
          ),
        ),
      ),
    );
  }

  Future<Position> _determinePosition() async {
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
