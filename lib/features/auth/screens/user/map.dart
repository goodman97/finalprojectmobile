import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:finalproject/services/event_service.dart';
import 'package:finalproject/services/location_service.dart';
import 'package:finalproject/features/auth/screens/user/event_detail.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class UserMapScreen extends StatefulWidget {
  const UserMapScreen({super.key});

  @override
  State<UserMapScreen> createState() =>
      _UserMapScreenState();
}

class _UserMapScreenState
    extends State<UserMapScreen> {
  List events = [];
  LatLng userLocation =
      const LatLng(-6.2, 106.8);

  bool isLoading = true;
  bool locationEnabled = false;

  @override
  void initState() {
    super.initState();
    checkLocationStatus();
  }

  Future<void> checkLocationStatus() async {
    final prefs =
        await SharedPreferences.getInstance();

    final bool userToggle =
        prefs.getBool(
              "location_enabled",
            ) ??
            false;

    print(
        "LOCATION TOGGLE STATUS: $userToggle");

    // kalau switch OFF
    if (!userToggle) {
      if (!mounted) return;

      setState(() {
        locationEnabled = false;
        isLoading = false;
        events = [];
      });

      return;
    }

    // cek GPS device
    bool gpsEnabled =
        await Geolocator
            .isLocationServiceEnabled();

    print("GPS STATUS: $gpsEnabled");

    if (!gpsEnabled) {
      if (!mounted) return;

      setState(() {
        locationEnabled = false;
        isLoading = false;
        events = [];
      });

      return;
    }

    if (!mounted) return;

    setState(() {
      locationEnabled = true;
    });

    await loadMapData();
  }

  Future<void> loadMapData() async {
    try {
      print("START LOAD MAP DATA");

      final location = await LocationService
          .getCurrentLocation()
          .timeout(
            const Duration(seconds: 8),
          );

      print("LOCATION RESULT: $location");

      LatLng currentLocation;

      if (location == null) {
        print("LOCATION NULL -> fallback");

        currentLocation = const LatLng(
          -6.9175,
          107.6191,
        );
      } else {
        currentLocation = LatLng(
          location.latitude,
          location.longitude,
        );
      }

      final eventData =
          await EventService.getEvents();

      print(
          "EVENT COUNT: ${eventData.length}");

      final validEvents =
          eventData.where((e) {
        return e["latitude"] != null &&
            e["longitude"] != null &&
            e["latitude"] != 0 &&
            e["longitude"] != 0;
      }).toList();

      print(
          "VALID EVENT COUNT: ${validEvents.length}");

      if (!mounted) return;

      setState(() {
        userLocation = currentLocation;
        events = validEvents;
        isLoading = false;
      });
    } on TimeoutException {
      print("GPS TIMEOUT");

      if (!mounted) return;

      setState(() {
        userLocation = const LatLng(
          -6.9175,
          107.6191,
        );
        isLoading = false;
      });
    } catch (e) {
      print("MAP ERROR: $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  double getDistanceKm(Map event) {
    final distanceInMeters =
        Geolocator.distanceBetween(
      userLocation.latitude,
      userLocation.longitude,
      double.parse(
        event["latitude"]
            .toString(),
      ),
      double.parse(
        event["longitude"]
            .toString(),
      ),
    );

    return distanceInMeters / 1000;
  }

  String getEstimatedTime(Map event) {
    final km =
        getDistanceKm(event);

    final minutes =
        ((km / 30) * 60)
            .round();

    if (minutes < 1) {
      return "<1 min";
    }

    return "$minutes mins";
  }

  @override
  Widget build(
      BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    if (!locationEnabled) {
      return Scaffold(
        backgroundColor:
            const Color(
                0xFFF5F1E8),
        appBar: AppBar(
          title: const Text(
              "Nearby Events"),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment
                    .center,
            children: [
              Icon(
                Icons.location_off,
                size: 70,
                color:
                    Colors.grey,
              ),
              SizedBox(
                  height: 16),
              Text(
                "Enable location from profile first",
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          const Color(
              0xFFF5F1E8),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter:
                  userLocation,
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName:
                    "com.example.finalproject",
              ),

              MarkerLayer(
                markers: [
                  Marker(
                    point:
                        userLocation,
                    width: 50,
                    height: 50,
                    child:
                        const Icon(
                      Icons
                          .my_location,
                      color: Colors
                          .blue,
                      size: 35,
                    ),
                  ),

                  ...events.map(
                    (event) =>
                        Marker(
                      point:
                          LatLng(
                        double.parse(
                          event["latitude"]
                              .toString(),
                        ),
                        double.parse(
                          event["longitude"]
                              .toString(),
                        ),
                      ),
                      width:
                          50,
                      height:
                          50,
                      child:
                          GestureDetector(
                        onTap:
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) =>
                                      EventDetail(
                                event: Map<String,
                                    dynamic>.from(
                                  event,
                                ),
                              ),
                            ),
                          );
                        },
                        child:
                            const Icon(
                          Icons
                              .location_on,
                          color: Color(
                              0xFF2F3E2F),
                          size:
                              40,
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 250,
              padding:
                  const EdgeInsets
                      .all(
                          20),
              decoration:
                  const BoxDecoration(
                color: Colors
                    .white,
                borderRadius:
                    BorderRadius.vertical(
                  top: Radius
                      .circular(
                          30),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  const Text(
                    "Nearby Events",
                    style:
                        TextStyle(
                      fontSize:
                          22,
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),

                  const SizedBox(
                      height:
                          20),

                  Expanded(
                    child:
                        ListView.builder(
                      itemCount:
                          events.length,
                      itemBuilder:
                          (_, i) {
                        final event =
                            events[i];

                        return GestureDetector(
                          onTap:
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        EventDetail(
                                  event: Map<String,
                                      dynamic>.from(
                                    event,
                                  ),
                                ),
                              ),
                            );
                          },
                          child:
                              Container(
                            margin:
                                const EdgeInsets.only(
                                    bottom:
                                        14),
                            padding:
                                const EdgeInsets.all(
                                    16),
                            decoration:
                                BoxDecoration(
                              color:
                                  const Color(
                                      0xFFF5F1E8),
                              borderRadius:
                                  BorderRadius.circular(
                                      20),
                            ),
                            child:
                                Row(
                              children: [
                                Expanded(
                                  child:
                                      Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event["name"] ??
                                            "-",
                                      ),
                                      Text(
                                        event["address"] ??
                                            "-",
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "Rp ${event["price"]}",
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}