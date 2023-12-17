import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:maps_launcher/maps_launcher.dart';

class MapScreen extends StatefulWidget {
  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MapScreen> {
  LocationData? currentLocation;
  Location location = Location();

  late FollowOnLocationUpdate _followOnLocationUpdate;
  late StreamController<double?> _followCurrentLocationStreamController;

  final String data1 =
      "Lorem Ipsum is simply dummy text of the printing and typesetting industry.";
  final String data2 =
      "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, "
      "when an unknown printer took a galley of type and scrambled it to make a type specimen book.";
  final String data3 =
      "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, "
      "totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo";
  final String data4 =
      "Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, "
      "sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.";
  late String dataSlide;
  late double long = 0.0; // Initialize long to 0.0
  late double lat = 0.0;

  List<Marker> allMarkers = [];

  @override
  void initState() {
    super.initState();

    _getLocation();
    _followOnLocationUpdate = FollowOnLocationUpdate.once;
    _followCurrentLocationStreamController = StreamController<double?>();

    dataSlide = data1;

    initializeMarkers();
  }

  void initializeMarkers() {
    allMarkers.clear();

    // Removed the default markers for now
    addMarker(-7.772883015693774, 110.35162041008356, data1);
    addMarker(-7.776925950151403, 110.417587608133, data2);
    addMarker(-7.810447112334517, 110.3317282395377, data3);
    addMarker(-7.814152804539516, 110.39514515931207, data4);
  }

  void addMarker(double latitude, double longitude, String data) {
    allMarkers.add(
      Marker(
        width: 100.0,
        height: 100.0,
        point: LatLng(latitude, longitude),
        child: Container(
          child: IconButton(
            onPressed: () {
              setState(() {
                dataSlide = data;
                lat = latitude;
                long = longitude;
              });
            },
            icon: Icon(Icons.pin_drop, color: Colors.red),
          ),
        ),
      ),
    );
  }

  Future<void> _getLocation() async {
    try {
      currentLocation = await location.getLocation();
      lat = currentLocation?.latitude ?? 0.0;
      long = currentLocation?.longitude ?? 0.0;
      print('Latitude: ${currentLocation?.latitude}, Longitude: ${currentLocation?.longitude}');
      setState(() {});
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          print('Tapped on the map!');
        },
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                onTap: (TapPosition? tapPosition, LatLng latLng) {
                  bool locationHasMarker = allMarkers.any((marker) =>
                  marker.point.latitude == latLng.latitude &&
                      marker.point.longitude == latLng.longitude);

                  setState(() {
                    lat = latLng.latitude;
                    long = latLng.longitude;
                    if (!locationHasMarker) {
                      dataSlide = "Lorem Ipsum is simply dummy text of the printing and typesetting industry";
                      initializeMarkers();
                      addMarker(latLng.latitude, latLng.longitude, "Lorem Ipsum is simply dummy text of the printing and typesetting industry");
                    }
                  });
                },
                initialCenter: LatLng(
                  currentLocation?.latitude ?? -2.5489,
                  currentLocation?.longitude ?? 118.0149,
                ),
                initialZoom: 3.2,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                CurrentLocationLayer(
                  followOnLocationUpdate: _followOnLocationUpdate,
                ),
                MarkerLayer(markers: allMarkers),
              ],
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  setState(() => _followOnLocationUpdate = FollowOnLocationUpdate.once);
                },
                child: const Icon(
                  Icons.my_location,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: EdgeInsets.all(16),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Details:\n${dataSlide.isEmpty ? 'Lorem Ipsum' : dataSlide}\n\nLocation Details:\nLat: ${lat.toString()}\nLong: ${long.toString()}",
            ),
            ElevatedButton(
              onPressed: () {
                MapsLauncher.launchCoordinates(lat, long);
              },
              child: Text("Navigasi"),
            ),
          ],
        ),
      ),
    );
  }
}
