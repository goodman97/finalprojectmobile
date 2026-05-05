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
      const LatLng(0, 0);

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

    if (!userToggle) {
      if (!mounted) return;

      setState(() {
        locationEnabled = false;
        isLoading = false;
        events = [];
      });

      return;
    }

    bool gpsEnabled = await Geolocator.isLocationServiceEnabled();

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
        print("LOCATION NOT FOUND");

        if (!mounted) return;

        setState(() {
          isLoading = false;
          events = [];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Location not found. Please enable GPS and location permission.",
            ),
          ),
        );

        return;
      }

      currentLocation = LatLng(
        location.latitude,
        location.longitude,
      );

      final eventData = await EventService.getEvents();

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
    }on TimeoutException {
        print("GPS TIMEOUT");

        if (!mounted) return;

        setState(() {
          isLoading = false;
          events = [];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "GPS timeout. Please try again.",
            ),
          ),
        );
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
    final distanceKm = getDistanceKm(event);

    // asumsi kecepatan rata-rata kendaraan 40 km/jam
    final timeInHours = distanceKm / 40;

    final totalMinutes = (timeInHours * 60).round();

    if (totalMinutes < 60) {
      return "$totalMinutes mins";
    } else {
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;

      if (minutes == 0) {
        return "$hours hr";
      }

      return "$hours hr $minutes mins";
    }
  }

  String formatDate(dynamic date) {
  if (date == null) return "-";

  try {
    final d = DateTime.parse(date.toString());

    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];

    return "${months[d.month - 1]} ${d.day}, ${d.year}";
  } catch (e) {
    return "-";
  }
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

                  const SizedBox(height:20),

                  Expanded(
                    child: ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EventDetail(
                                  event: Map<String, dynamic>.from(event),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F1EA),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event["name"] ?? "-",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      Text(
                                        formatDate(
                                          event["start_date"] ??
                                              event["date"],
                                        ),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.near_me,
                                            size: 16,
                                            color: Colors.orange,
                                          ),
                                          const SizedBox(width: 4),

                                          Text(
                                            "${getDistanceKm(event).toStringAsFixed(1)} km",
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),

                                          const SizedBox(width: 16),

                                          const Icon(
                                            Icons.access_time,
                                            size: 16,
                                            color: Colors.orange,
                                          ),
                                          const SizedBox(width: 4),

                                          Text(
                                            getEstimatedTime(event),
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                Text(
                                  "\$${event["price"] ?? 0}",
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}