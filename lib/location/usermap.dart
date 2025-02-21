import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserMapPage extends StatefulWidget {
  const UserMapPage({super.key});

  @override
  _UserMapPageState createState() => _UserMapPageState();
}

class _UserMapPageState extends State<UserMapPage> {
  final Completer<GoogleMapController> _googleMapController = Completer();
  CameraPosition? _cameraPosition;
  final databaseReference = FirebaseDatabase.instance.ref();

  LatLng? _driverLocation;

  @override
  void initState() {
    super.initState();
    _cameraPosition = const CameraPosition(
      target: LatLng(0, 0),
      zoom: 15,
    );
    _initUserLocation();
  }

  _initUserLocation() {
    // Listen for updates to the driver's location in Firebase
    databaseReference.child('locations').onValue.listen((event) {
      if (event.snapshot.value != null) {
        final driverLocation = event.snapshot.value as Map<dynamic, dynamic>?;

        if (driverLocation != null) {
          // Update the driver's location on the map
          setState(() {
            _driverLocation = LatLng(
              driverLocation['latitude'] as double,
              driverLocation['longitude'] as double,
            );
            _moveToDriverLocation(_driverLocation!);
          });
        }
      }
    });
  }

  _moveToDriverLocation(LatLng driverLocation) async {
    // Animate the map camera to the new driver's location
    final GoogleMapController mapController = await _googleMapController.future;
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: driverLocation,
          zoom: 15,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User View'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return _getMap();
  }

  Widget _getMap() {
    return GoogleMap(
      initialCameraPosition: _cameraPosition!,
      mapType: MapType.normal,
      onMapCreated: (GoogleMapController controller) {
        if (!_googleMapController.isCompleted) {
          _googleMapController.complete(controller);
        }
      },
      markers: _driverLocation != null
          ? {
              Marker(
                markerId: const MarkerId('driverLocation'),
                position: _driverLocation!,
                icon: BitmapDescriptor.defaultMarker,
              ),
            }
          : {}, // Display the driver's location as a marker on the map
    );
  }
}
