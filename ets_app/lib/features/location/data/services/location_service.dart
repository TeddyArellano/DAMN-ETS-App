import 'package:geolocator/geolocator.dart';

class LocationService {
  const LocationService();

  static const double escomLatitude = 19.504630;
  static const double escomLongitude = -99.146120;

  Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception(
        'La ubicación está desactivada. Activa el GPS para continuar.',
      );
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception(
        'Permiso de ubicación denegado. Autoriza el permiso para usar la ubicación.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'El permiso de ubicación fue denegado permanentemente. Actívalo desde la configuración del dispositivo.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      ),
    );
  }

  double distanceToEscomInMeters(Position position) {
    return Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      escomLatitude,
      escomLongitude,
    );
  }
}