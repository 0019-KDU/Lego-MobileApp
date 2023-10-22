import 'package:firebase_database/firebase_database.dart';
import 'package:location/location.dart';

class LocationService {
  final Location _location = Location();
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref().child('locations');

  Future<void> shareLocation() async {
    final LocationData? location = await _location.getLocation();
    if (location != null) {
      await _databaseReference.set({
        'latitude': location.latitude,
        'longitude': location.longitude,
      });
    }
  }
}
