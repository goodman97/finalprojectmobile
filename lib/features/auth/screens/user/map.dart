import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:finalproject/services/event_service.dart';
import 'package:finalproject/services/location_service.dart';
import 'package:finalproject/features/auth/screens/user/event_detail.dart';
import 'package:geolocator/geolocator.dart';

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

  @override
  void initState() {
    super.initState();
    loadMapData();
  }

  Future<void> loadMapData() async {
    try {
      final location =
          await LocationService.getCurrentLocation();

      if (location == null) {
        print("Lokasi user tidak tersedia, pakai fallback");

        userLocation = const LatLng(
          -6.9175, // Bandung fallback
          107.6191,
        );
      }

      final eventData =
          await EventService.getEvents();

      setState(() {
        if (location != null) {
          userLocation = LatLng(
            location.latitude,
            location.longitude,
          );
        }

        events = eventData;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  double getDistanceKm(Map event) {
    if (event["latitude"] == null ||
        event["longitude"] == null) {
      return -1;
    }

    final distanceInMeters =
        Geolocator.distanceBetween(
      userLocation.latitude,
      userLocation.longitude,
      double.parse(
        event["latitude"].toString(),
      ),
      double.parse(
        event["longitude"].toString(),
      ),
    );

    return distanceInMeters / 1000;
  }

  String getEstimatedTime(Map event) {
    final km = getDistanceKm(event);

    if (km < 0) return "-";

    // asumsi rata-rata kendaraan kota 30 km/jam
    final minutes = ((km / 30) * 60).round();

    if (minutes < 1) {
      return "<1 min";
    }

    return "$minutes mins";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F1E8),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : Stack(
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
                    ),

                    MarkerLayer(
                      markers: [
                        Marker(
                          point:
                              userLocation,
                          width: 50,
                          height: 50,
                          child: const Icon(
                            Icons.my_location,
                            color:
                                Colors.blue,
                            size: 35,
                          ),
                        ),

                        ...events
                            .where((e) =>
                                e["latitude"] !=
                                    null &&
                                e["longitude"] !=
                                    null)
                            .map(
                              (event) =>
                                  Marker(
                                point: LatLng(
                                  double.parse(
                                    event[
                                            "latitude"]
                                        .toString(),
                                  ),
                                  double.parse(
                                    event[
                                            "longitude"]
                                        .toString(),
                                  ),
                                ),
                                width: 50,
                                height: 50,
                                child:
                                    GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) =>
                                                EventDetail(
                                          event: Map<
                                              String,
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
                                    size: 40,
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
                        const EdgeInsets.all(
                            20),
                    decoration:
                        const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(
                        top:
                            Radius.circular(
                                30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 5,
                            decoration:
                                BoxDecoration(
                              color: Colors
                                  .grey,
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          20),
                            ),
                          ),
                        ),
                        const SizedBox(
                            height: 20),

                        const Text(
                          "Nearby Events",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        const SizedBox(
                            height: 20),

                        Expanded(
                          child: Builder(
                            builder: (_) {final validEvents = events.where((e) {
                              return e["latitude"] != null &&
                                  e["longitude"] != null;
                            }).toList();

                            return ListView.builder(
                            itemCount: validEvents.length,
                            itemBuilder: (_, i) {
                              final event = validEvents[i];

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
                                  margin: const EdgeInsets.only(bottom: 14),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F1E8),
                                    borderRadius: BorderRadius.circular(20),
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
                                                fontSize: 16,
                                                fontWeight:
                                                    FontWeight.bold,
                                                color:
                                                    Color(0xFF2F3E2F),
                                              ),
                                            ),

                                            const SizedBox(height: 6),

                                            Text(
                                              event["address"] ?? "-",
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 13,
                                              ),
                                            ),

                                            const SizedBox(height: 10),

                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.near_me,
                                                  size: 14,
                                                  color:
                                                      Color(0xFFE4572E),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  "${getDistanceKm(event).toStringAsFixed(1)} km",
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),

                                                const SizedBox(width: 14),

                                                const Icon(
                                                  Icons.access_time,
                                                  size: 14,
                                                  color:
                                                      Color(0xFFE4572E),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  getEstimatedTime(event),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),

                                      Text(
                                        "Rp ${event["price"]}",
                                        style: const TextStyle(
                                          color: Color(0xFFE4572E),
                                          fontWeight:
                                              FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                              },
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