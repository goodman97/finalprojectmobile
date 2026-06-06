import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finalproject/services/auth_service.dart';
import 'package:finalproject/services/biometric_service.dart';
import 'package:finalproject/services/storage_service.dart';
import 'package:finalproject/services/ticket_service.dart';

class ProfileController extends GetxController {
  // State (reactive variables) 

  final name             = ''.obs;
  final email            = ''.obs;
  final telephone        = '-'.obs;
  final dateCreated      = '-'.obs;
  final profileImage     = Rxn<String>();
  final totalTickets     = 0.obs;
  final totalAttended    = 0.obs;
  final notificationCount = 0.obs;
  final isLoading        = true.obs;
  final biometricEnabled = false.obs;
  final locationEnabled  = false.obs;

  // Lifecycle 

  @override
  void onInit() {
    super.onInit();
    loadProfile();
    loadLocationPreference();
    loadNotificationCount();
  }

  // Data fetching

  /// Ambil data profil dari server
  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      final data = await AuthService.getProfile();

      name.value          = data['name']?.toString()      ?? '-';
      email.value         = data['email']?.toString()     ?? '-';
      telephone.value     = data['telephone']?.toString() ?? '-';
      dateCreated.value   = data['created_at']?.toString() ?? '-';
      biometricEnabled.value = data['biometric_enabled']  ?? false;
      totalTickets.value  = int.tryParse(data['total_tickets'].toString())  ?? 0;
      totalAttended.value = int.tryParse(data['total_attended'].toString()) ?? 0;

      final img = data['profile_image']?.toString();
      profileImage.value  = (img != null && img.isNotEmpty)
          ? img.replaceAll('\\', '/')
          : null;
    } catch (e) {
      print('ERROR PROFILE CONTROLLER: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadNotificationCount() async {
    final count = await TicketService.getUnreadNotificationCount();
    notificationCount.value = count;
  }
  Future<void> loadLocationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    locationEnabled.value = prefs.getBool('location_enabled') ?? false;
  }

  // Actions
  Future<String> toggleLocation(bool value) async {
    if (value) {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return 'Please enable GPS first';
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return 'Location permission denied';
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('location_enabled', true);
      locationEnabled.value = true;
      return 'Nearby events enabled';
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('location_enabled', false);
      locationEnabled.value = false;
      return 'Nearby events disabled';
    }
  }

  Future<String> toggleBiometric(bool value) async {
    if (value) {
      final success = await BiometricService.authenticate();
      if (!success) return '';   // gagal → tidak lakukan apa-apa

      await AuthService.updateBiometric(true);
      await StorageService.setBiometric(true);
      biometricEnabled.value = true;
      return 'Biometric enabled';
    } else {
      await AuthService.updateBiometric(false);
      await StorageService.setBiometric(false);
      biometricEnabled.value = false;
      return 'Biometric disabled';
    }
  }

  Future<void> logout() async {
    await StorageService.clear();
  }
}