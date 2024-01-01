import 'dart:async';
// import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../assistants/assistant_methods.dart';
import '../global/global.dart';
import 'package:intl/intl.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  DatabaseReference? ref = FirebaseDatabase.instance.ref().child("drivers").child(currentFirebaseUser!.uid);
  late DatabaseReference? refNewRide;
  String timeNow = DateFormat.yMEd().add_jms().format(DateTime.now());
  GoogleMapController? newGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  Position? driverCurrentPosition;

  String statusText = "Now Offline";
  Color buttonColor = Colors.grey;
  bool isDriverActive = false;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  blackThemeGoogleMap() {
    newGoogleMapController!.setMapStyle('''
                    [
                      {
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "featureType": "administrative.locality",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#263c3f"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#6b9a76"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#38414e"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#212a37"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#9ca5b3"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#1f2835"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#f3d19c"
                          }
                        ]
                      },
                      {
                        "featureType": "transit",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#2f3948"
                          }
                        ]
                      },
                      {
                        "featureType": "transit.station",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#515c6d"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      }
                    ]
                ''');
  }

  locateDriverPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

    CameraPosition cameraPosition = CameraPosition(target: latLngPosition, zoom: 14);

    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress = await AssistantMethods.searchAddressForGeographicCoOrdinates(driverCurrentPosition!, context);
    print("this is your address = " + humanReadableAddress);
  }

  @override
  Widget build(BuildContext context) {
    double heightMedia = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          myLocationEnabled: true,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controllerGoogleMap.complete(controller);
            newGoogleMapController = controller;

            //black theme google map
            blackThemeGoogleMap();
            locateDriverPosition();
          },
        ),
        // ui for online offline driver
        statusText != "Now Online"
            ? Container(
                height: heightMedia,
                width: double.infinity,
                color: Colors.black87,
              )
            : Container(),

        //button for online offline driver
        Positioned(
          top: statusText != "Now Online" ? heightMedia * 0.46 : heightMedia * 0.07,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (!isDriverActive) {
                    driverIsOnlineNow();
                    updateDriversLocationAtRealTime();

                    setState(() {
                      statusText = "Now Online";
                      isDriverActive = true;
                      buttonColor = Colors.transparent;
                    });
                    // display Toast
                    Fluttertoast.showToast(msg: "you are online now");
                  } else {
                    driverIsOfflineNow();
                    setState(() {
                      statusText = "Now Offline";
                      isDriverActive = false;
                      buttonColor = Colors.grey;
                    });
                    // display Toast
                    Fluttertoast.showToast(msg: "you are offline now");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: statusText != "Now Online"
                    ? Text(
                        statusText,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.phonelink_ring,
                        color: Colors.white,
                        size: 26,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  driverIsOnlineNow() async {
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    driverCurrentPosition = pos;

    // Titik awal
    // Position testCurrentPosition = Position(
    //   latitude: -7.422231,
    //   longitude: 109.2410066,
    //   timestamp: DateTime.now(),
    // );

    // double initialLatitude = -7.422231;
    // double initialLongitude = 109.2410066;
    // Geofire.initialize("activeDrivers");

    // // Mengubah koordinat setiap 10 detik sejauh 1 km
    // Timer.periodic(Duration(seconds: 10), (timer) {
    //   double distance = 1; // Jarak dalam kilometer
    //   double bearing = Random().nextDouble() * (2 * pi); // Arah dalam radian (0 - 2 * pi)

    //   // Menghitung perubahan koordinat berdasarkan jarak dan arah
    //   double deltaLat = distance / 6371 * (180 / pi) * cos(initialLatitude * pi / 180);
    //   double deltaLon = distance / 6371 * (180 / pi) / sin(initialLatitude * pi / 180) * sin(bearing);

    //   // Update koordinat
    //   initialLatitude += deltaLat;
    //   initialLongitude += deltaLon;
    //   Geofire.setLocation(currentFirebaseUser!.uid, initialLatitude, initialLongitude);

    //   print('Latitude: $initialLatitude, Longitude: $initialLongitude');
    // });

    Geofire.initialize("activeDrivers");
    Geofire.setLocation(currentFirebaseUser!.uid, driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
    // Geofire.queryAtLocation(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude, 10)?.listen((map) {
    //   print('cek map $map');
    //   if (map != null) {
    //     var callBack = map['callBack'];
    //   }
    // });
    // DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers").child(currentFirebaseUser!.uid);

    ref!.child("startOnlineLocale").set(timeNow);
    await ref!.child("startOnlineServer").set(ServerValue.timestamp);
    final snapshot = await ref!.child("startOnlineServer").get();
    if (snapshot.exists) {
      // Mendapatkan nilai timestamp dari Firebase Realtime Database
      int firebaseTimestamp = int.parse(snapshot.value.toString()); // Contoh timestamp dari Firebase

// Konversi timestamp menjadi objek DateTime
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(firebaseTimestamp);

// Format waktu dan tanggal sesuai kebutuhan
      String formattedDateTime = DateFormat.yMEd().add_jms().format(dateTime);
      ref!.child("startOnlineServer").set(formattedDateTime);
      print('Waktu dari Firebase Start: $formattedDateTime');
    }
    DatabaseReference refNewRide = ref!.child("newRideStatus");
    refNewRide.set("idle"); //searching for ride request
    refNewRide.onValue.listen((event) {});
  }

  updateDriversLocationAtRealTime() {
    streamSubscriptionPosition = Geolocator.getPositionStream().listen((Position position) {
      driverCurrentPosition = position;

      if (isDriverActive) {
        Geofire.setLocation(currentFirebaseUser!.uid, driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
      }

      LatLng latLng = LatLng(
        driverCurrentPosition!.latitude,
        driverCurrentPosition!.longitude,
      );

      newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  driverIsOfflineNow() async {
    await Geofire.stopListener();
    bool? responses = await Geofire.removeLocation(currentFirebaseUser!.uid);
    print('cek responnya $responses');

    // DatabaseReference? refActiveDriver = FirebaseDatabase.instance.ref().child("activeDrivers");
    // refActiveDriver.onDisconnect();
    // refActiveDriver.remove();
    // refActiveDriver = null;

    // DatabaseReference? refId = FirebaseDatabase.instance.ref().child("drivers").child(currentFirebaseUser!.uid);
    ref!.child("lastOnlineLocale").set(timeNow);
    await ref!.child("lastOnlineServer").set(ServerValue.timestamp);
    final snapshot = await ref!.child("lastOnlineServer").get();
    if (snapshot.exists) {
      // Mendapatkan nilai timestamp dari Firebase Realtime Database
      int firebaseTimestamp = int.parse(snapshot.value.toString()); // Contoh timestamp dari Firebase

// Konversi timestamp menjadi objek DateTime
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(firebaseTimestamp);

// Format waktu dan tanggal sesuai kebutuhan
      String formattedDateTime = DateFormat.yMEd().add_jms().format(dateTime);
      ref!.child("lastOnlineServer").set(formattedDateTime);
      print('Waktu dari Firebase: $formattedDateTime');
    }

    DatabaseReference? refRideStatus = ref!.child("newRideStatus");
    refRideStatus.onDisconnect();
    refRideStatus.remove();
    refRideStatus = null;

    // Future.delayed(const Duration(milliseconds: 2000), () {
    //   //SystemChannels.platform.invokeMethod("SystemNavigator.pop");
    //   SystemNavigator.pop();
    // });
  }
}
