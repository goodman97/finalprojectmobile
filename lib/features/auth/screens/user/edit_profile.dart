import 'package:flutter/material.dart';
import 'package:finalproject/services/auth_service.dart';
import 'package:finalproject/services/storage_service.dart';
import 'package:finalproject/services/biometric_service.dart';
import 'package:finalproject/config/api_config.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final oldPassController = TextEditingController();
  final newPassController = TextEditingController();
  final confirmPassController = TextEditingController();
  
  bool showPasswordForm = false;

  bool isLoading = true;
  bool biometricEnabled = false;

  File? imageFile;
  Uint8List? webImage;
  String? photoUrl;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadProfile();
    });

    loadBiometric();
  }

  // BIOMETRIC
  void loadBiometric() async {
    bool value = await StorageService.getBiometric();
    setState(() => biometricEnabled = value);
  }

  void toggleBiometric(bool value) async {
    if (value) {
      bool success = await BiometricService.authenticate();
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Verifikasi fingerprint gagal")),
        );
        return;
      }
    }

    await StorageService.setBiometric(value);
    setState(() => biometricEnabled = value);
  }

  // LOAD PROFILE
  Future<void> loadProfile() async {
    try {
      final data = await AuthService.getProfile();

      final name  = (data["name"] ?? "").toString();
      final email = (data["email"] ?? "").toString();
      final phone = (data["telephone"] ?? "").toString();
      final rawPhoto = (data["photo_profile"] ?? "").toString();

      nameController.text  = name;
      emailController.text = email;
      phoneController.text = phone;

      setState(() {
        photoUrl = rawPhoto.isNotEmpty
            ? rawPhoto.replaceAll("\\", "/")
            : null;

        isLoading = false;
      });
    } catch (e) {
      print("ERROR PROFILE: $e");
      setState(() => isLoading = false);
    }
  }

  // SAVE
  Future<void> saveProfile() async {
    try {
      if (imageFile != null) {
        await AuthService.uploadPhoto(imageFile);
      }

      if (webImage != null) {
        await AuthService.uploadPhoto(webImage);
      }

      await AuthService.updateProfile(
        nameController.text,
        emailController.text,
        phoneController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile berhasil diupdate")),
      );

      Navigator.pop(context, true);
    } catch (e) {
      print("SAVE ERROR: $e");
    }
  }

  // IMAGE
  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  Future<void> pickImageWeb() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() => webImage = result.files.first.bytes);
    }
  }

  void handlePickImage() {
    if (kIsWeb) {
      pickImageWeb();
    } else {
      pickImage();
    }
  }

  ImageProvider? getImage() {
    if (kIsWeb && webImage != null) return MemoryImage(webImage!);
    if (!kIsWeb && imageFile != null) return FileImage(imageFile!);
    if (photoUrl != null) {
      return NetworkImage("${ApiConfig.baseUrl}/$photoUrl");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final image = getImage();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Edit Profile", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// PHOTO
                  Center(
                    child: GestureDetector(
                      onTap: handlePickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 55,
                            backgroundColor: const Color(0xFF2F3E2F),
                            backgroundImage: image,
                            child: image == null
                                ? const Icon(Icons.person, size: 45, color: Colors.white)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE4572E),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt,
                                  size: 18, color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Center(
                    child: Text("Change Photo",
                        style: TextStyle(color: Color(0xFFE4572E))),
                  ),

                  const SizedBox(height: 30),

                  const Text("BASIC INFORMATION",
                      style: TextStyle(fontWeight: FontWeight.bold)),

                  const SizedBox(height: 15),

                  buildField("Full Name", nameController, Icons.person),
                  const SizedBox(height: 15),

                  buildField("Email Address", emailController, Icons.email, enabled: false),

                  const SizedBox(height: 5),

                  const Text("Email cannot be changed",
                      style: TextStyle(fontSize: 12, color: Colors.grey)),

                  const SizedBox(height: 15),

                  buildField("Phone Number", phoneController, Icons.phone),

                  const SizedBox(height: 30),

                  const Text("SECURITY",
                      style: TextStyle(fontWeight: FontWeight.bold)),

                  const SizedBox(height: 10),

                  ListTile(
                    onTap: () {
                      setState(() {
                        showPasswordForm = !showPasswordForm;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    tileColor: Colors.white,
                    leading: const Icon(Icons.lock),
                    title: const Text("Change Password"),
                    trailing: Icon(
                      showPasswordForm
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                  ),

                  if (showPasswordForm)
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          buildPasswordField("Old Password", oldPassController),
                          const SizedBox(height: 10),

                          buildPasswordField("New Password", newPassController),
                          const SizedBox(height: 10),

                          buildPasswordField("Confirm Password", confirmPassController),

                          const SizedBox(height: 15),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (newPassController.text !=
                                    confirmPassController.text) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("Password tidak sama")),
                                  );
                                  return;
                                }

                                await AuthService.changePassword(
                                  oldPassController.text,
                                  newPassController.text,
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Password berhasil diubah")),
                                );

                                setState(() {
                                  showPasswordForm = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE4572E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                "Save",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.fingerprint),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Biometric Login"),
                                Text("Use fingerprint to sign in",
                                    style: TextStyle(fontSize: 12))
                              ],
                            )
                          ],
                        ),
                        Switch(
                          value: biometricEnabled,
                          onChanged: toggleBiometric,
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE4572E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Save Changes",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Widget buildField(String label, TextEditingController controller, IconData icon,
      {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500)),

        const SizedBox(height: 6),

        TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPasswordField(
    String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}