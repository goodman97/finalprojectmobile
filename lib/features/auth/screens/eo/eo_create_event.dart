import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:finalproject/services/eo_event_service.dart';
import 'package:finalproject/config/api_config.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class EoCreateEvent extends StatefulWidget {
  /// Jika diisi → mode edit, kosong → mode create
  final Map<String, dynamic>? editEvent;

  const EoCreateEvent({super.key, this.editEvent});

  @override
  State<EoCreateEvent> createState() => _EoCreateEventState();
}

class _EoCreateEventState extends State<EoCreateEvent> {
  final _form = GlobalKey<FormState>();
  final _name        = TextEditingController();
  final _address     = TextEditingController();
  final _startDate   = TextEditingController();
  final _endDate     = TextEditingController();
  final _startTime   = TextEditingController();
  final _price       = TextEditingController();
  final _quota       = TextEditingController();
  final _description = TextEditingController();

  double? _lat, _lng;
  File?   _imageFile;
  String? _existingImage;
  bool    _isSubmitting = false;
  XFile? selectedImage;
  Uint8List? webImage;
  bool get _isEdit => widget.editEvent != null;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final e = widget.editEvent!;
      _name.text        = e["name"]        ?? "";
      _address.text     = e["address"]     ?? "";
      _price.text       = e["price"]?.toString() ?? "";
      _quota.text       = e["quota"]?.toString()  ?? "";
      _description.text = e["description"] ?? "";
      _existingImage    = e["event_image"];
      _lat = double.tryParse(e["latitude"]?.toString()  ?? "");
      _lng = double.tryParse(e["longitude"]?.toString() ?? "");

      // ── Fix timezone: parse lalu konversi ke local time device ──────────
      // Backend mengembalikan waktu dengan offset (misal +07:00).
      // DateTime.parse() otomatis membaca offset tsb, lalu .toLocal()
      // memastikan kita display dalam waktu lokal tanpa dobel konversi.
      if (e["start_date"] != null) {
        try {
          final dt = DateTime.parse(e["start_date"].toString()).toLocal();
          _startDate.text = DateFormat("yyyy-MM-dd").format(dt);
          _startTime.text = DateFormat("HH:mm").format(dt);
        } catch (_) {}
      }
      if (e["end_date"] != null) {
        try {
          final dt = DateTime.parse(e["end_date"].toString()).toLocal();
          _endDate.text = DateFormat("yyyy-MM-dd").format(dt);
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    for (final c in [_name,_address,_startDate,_endDate,_startTime,_price,_quota,_description]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          selectedImage = pickedFile;
          webImage = bytes;
          _imageFile = null;
        });
      } else {
        setState(() {
          selectedImage = pickedFile;
          webImage = null;
          _imageFile = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _pickDate(TextEditingController ctrl) async {
    final now  = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF2F3E2F)),
        ),
        child: child!,
      ),
    );
    if (date != null) {
      ctrl.text = DateFormat("yyyy-MM-dd").format(date);
    }
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (t != null) {
      _startTime.text =
          "${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}";
    }
  }

  // Map picker bottom sheet ─────────────────────────────────────────────
  Future<void> _openMapPicker() async {
    LatLng center = _lat != null && _lng != null
        ? LatLng(_lat!, _lng!)
        : const LatLng(-6.2088, 106.8456); // Jakarta default

    LatLng? selected = _lat != null && _lng != null ? center : null;
    final mapCtrl = MapController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text("Pilih Lokasi",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (selected != null) {
                          try {
                            final placemarks = await placemarkFromCoordinates(
                                selected!.latitude, selected!.longitude);
                            if (placemarks.isNotEmpty) {
                              final p = placemarks.first;
                              final addr = [
                                p.street,
                                p.subLocality,
                                p.locality,
                                p.administrativeArea,
                              ].where((s) => s != null && s.isNotEmpty).join(", ");
                              setState(() {
                                _lat = selected!.latitude;
                                _lng = selected!.longitude;
                                _address.text = addr;
                              });
                            }
                          } catch (_) {
                            setState(() {
                              _lat = selected!.latitude;
                              _lng = selected!.longitude;
                            });
                          }
                          if (mounted) Navigator.pop(ctx);
                        }
                      },
                      child: const Text("Konfirmasi",
                          style: TextStyle(color: Color(0xFFE4572E))),
                    ),
                  ],
                ),
              ),
              if (selected != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    "${selected!.latitude.toStringAsFixed(5)}, ${selected!.longitude.toStringAsFixed(5)}",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              Expanded(
                child: FlutterMap(
                  mapController: mapCtrl,
                  options: MapOptions(
                    center: center,
                    zoom: 14,
                    onTap: (tapPos, point) async {
                      setS(() => selected = point);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName: "com.finalproject.app",
                    ),
                    if (selected != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: selected!,
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.location_pin,
                                color: Color(0xFFE4572E), size: 40),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;

    if (!_isEdit && selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih gambar event terlebih dahulu")),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      if (_isEdit) {
        await EoEventService.editEvent(
          id:          widget.editEvent!["id"].toString(),
          name:        _name.text,
          address:     _address.text,
          startDate:   _startDate.text,
          startTime:   _startTime.text,
          endDate:     _endDate.text,
          price:       _price.text,
          quota:       _quota.text,
          description: _description.text,
          latitude:    _lat,
          longitude:   _lng,
          imageFile:   _imageFile,
          webImage:    webImage,
        );
      } else {
        await EoEventService.createEvent(
          name:        _name.text,
          address:     _address.text,
          startDate:   _startDate.text,
          startTime:   _startTime.text,
          endDate:     _endDate.text,
          price:       _price.text,
          quota:       _quota.text,
          description: _description.text,
          latitude:    _lat,
          longitude:   _lng,
          imageFile:   _imageFile,
          webImage:    webImage,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit ? "Event berhasil diupdate!" : "Event berhasil dibuat!"),
          backgroundColor: const Color(0xFF2F3E2F),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              decoration: const BoxDecoration(
                color: Color(0xFF2F3E2F),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isEdit ? "Edit Event" : "Create Event",
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const Text("Fill in the event details",
                          style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image picker
                      _label("Event Image"),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: double.infinity,
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: Colors.grey.shade300, width: 1.5),
                          ),
                          child: selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: kIsWeb
                                    ? Image.memory(
                                        webImage!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: 160,
                                      )
                                    : Image.file(
                                        _imageFile!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: 160,
                                      ),
                              )
                            : _existingImage != null && _existingImage!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: Image.network(
                                      "${ApiConfig.baseUrl}/uploads/events/$_existingImage",
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: 160,
                                      errorBuilder: (_, __, ___) => _imgPlaceholder(),
                                    ),
                                  )
                                : _imgPlaceholder(),
                        ),
                      ),

                      const SizedBox(height: 14),
                      _label("Event Name"),
                      _textField(_name, "Summer Music Festival",
                          validator: _req),

                      const SizedBox(height: 14),
                      _label("Location"),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _textField(
                              _address,
                              "Central Park, New York",
                              prefixIcon: Icons.location_on_outlined,
                              validator: _req,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _openMapPicker,
                            child: Container(
                              height: 54,
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2F3E2F),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.map, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      if (_lat != null && _lng != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            "📍 ${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)}",
                            style: const TextStyle(
                                color: Color(0xFF2F3E2F), fontSize: 11),
                          ),
                        ),

                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label("Start Date"),
                                GestureDetector(
                                  onTap: () => _pickDate(_startDate),
                                  child: AbsorbPointer(
                                    child: _textField(
                                      _startDate, "dd/mm/yyyy",
                                      prefixIcon: Icons.calendar_today,
                                      validator: _req,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label("End Date"),
                                GestureDetector(
                                  onTap: () => _pickDate(_endDate),
                                  child: AbsorbPointer(
                                    child: _textField(
                                      _endDate, "dd/mm/yyyy",
                                      prefixIcon: Icons.calendar_today,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),
                      _label("Start Time"),
                      GestureDetector(
                        onTap: _pickTime,
                        child: AbsorbPointer(
                          child: _textField(
                            _startTime, "--:--",
                            prefixIcon: Icons.access_time,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label("Ticket Price (Rp)"),
                                _textField(
                                  _price, "50000",
                                  keyboardType: TextInputType.number,
                                  validator: _req,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label("Quota"),
                                _textField(
                                  _quota, "500",
                                  prefixIcon: Icons.people_outline,
                                  keyboardType: TextInputType.number,
                                  validator: _req,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),
                      _label("Description"),
                      TextFormField(
                        controller: _description,
                        maxLines: 4,
                        validator: _req,
                        decoration: InputDecoration(
                          hintText: "Tell people about your event...",
                          hintStyle: const TextStyle(
                              color: Colors.grey, fontSize: 13),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Publish button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE4572E),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                          ),
                          child: _isSubmitting
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  _isEdit ? "Update Event" : "Publish Event",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel",
                              style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2F3E2F),
                fontSize: 13)),
      );

  Widget _imgPlaceholder() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.image_outlined, size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text("Click to upload image",
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          Text("PNG, JPG up to 5MB",
              style: TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      );

  Widget _textField(
    TextEditingController ctrl,
    String hint, {
    IconData? prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: Colors.grey, size: 18)
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      );

  String? _req(String? v) =>
      v == null || v.isEmpty ? "Field ini wajib diisi" : null;
}