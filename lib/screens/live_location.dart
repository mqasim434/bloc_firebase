import 'dart:async';

import 'package:bloc_firebase/blocs/location_bloc/location_bloc.dart';
import 'package:bloc_firebase/blocs/location_bloc/location_event.dart';
import 'package:bloc_firebase/blocs/location_bloc/location_state.dart';
import 'package:bloc_firebase/providers/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class LiveLocation extends StatelessWidget {
  LiveLocation({super.key});
  final completer = Completer();

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Live Location Bloc'),
          centerTitle: true,
        ),
        body: const GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(
              2,
              3,
            ),
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              onPressed: () async {
                context.read<LocationBloc>().add(
                      GetCurrentLocationEvent(),
                    );
              },
              child: const Icon(
                Icons.location_history,
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            BlocBuilder<LocationBloc, LocationState>(
                bloc: LocationBloc(),
                builder: (context, state) {
                  return FloatingActionButton(
                    onPressed: () async {
                      print('HELLO');
                      print(state.cameraPosition!);
                      GoogleMapController controller =
                          await locationProvider.completer.future;
                      controller.animateCamera(
                        CameraUpdate.newCameraPosition(state.cameraPosition!),
                      );
                    },
                    child: const Icon(
                      Icons.arrow_forward,
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
