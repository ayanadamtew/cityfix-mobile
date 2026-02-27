// lib/features/report_issue/screens/report_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart' as geo;
import '../providers/report_provider.dart';
import '../../../shared/custom_text_field.dart';
import '../../../core/constants.dart';
import '../../../services/location_service.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  String _category = AppConstants.categories.first;
  String _kebele = AppConstants.jimmaKebeles.first;
  File? _imageFile;
  
  // Default bounds to Jimma City, Ethiopia roughly
  double _lat = 7.6756;
  double _lng = 36.8358;
  bool _hasSetLocation = false;
  bool _gettingLocation = false;
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _descCtrl.dispose();
    _addressCtrl.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final px = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (px != null) {
      setState(() => _imageFile = File(px.path));
    }
  }

  Future<void> _getLocation() async {
    setState(() => _gettingLocation = true);
    try {
      final res = await ref.read(locationServiceProvider).getCurrentLocation();
      setState(() {
        _lat = res.latitude;
        _lng = res.longitude;
        _hasSetLocation = true;
        _addressCtrl.text = res.address;
      });
      _mapController.move(LatLng(_lat, _lng), 15.0);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _gettingLocation = false);
    }
  }

  Future<void> _setManualLocation(LatLng point) async {
    setState(() {
      _lat = point.latitude;
      _lng = point.longitude;
      _hasSetLocation = true;
      _addressCtrl.text = "Fetching address...";
    });

    try {
      final placemarks = await geo.placemarkFromCoordinates(point.latitude, point.longitude);
      if (placemarks.isNotEmpty) {
        final pm = placemarks.first;
        final street = pm.street ?? '';
        final locality = pm.locality ?? '';
        final adminArea = pm.administrativeArea ?? '';

        setState(() {
          _addressCtrl.text = [street, locality, adminArea].where((s) => s.isNotEmpty).join(', ');
        });
      } else {
        setState(() {
          _addressCtrl.text = '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}';
        });
      }
    } catch (_) {
      setState(() {
        _addressCtrl.text = '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}';
      });
    }
  }

  Future<void> _submit() async {
    if (!_hasSetLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please detect your location or tap on the map')),
      );
      return;
    }

    try {
      final isOfflineSaved = await ref.read(reportProvider.notifier).submit(
            description: _descCtrl.text.trim(),
            category: _category,
            latitude: _lat,
            longitude: _lng,
            address: _addressCtrl.text,
            kebele: _kebele,
            localPhotoPath: _imageFile?.path,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isOfflineSaved
                ? 'Saved to Offline Drafts. Will sync automatically.'
                : 'Issue reported successfully!'),
            backgroundColor: isOfflineSaved ? Colors.orange.shade800 : Colors.green.shade800,
          ),
        );
        // Reset form and go to feed
        context.go('/feed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(reportProvider).isLoading;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Report an Issue')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Category ─────────────────────────────────────────────────
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                  ),
                  items: AppConstants.categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: 16),

                // ── Kebele Dropdown ──────────────────────────────────────────
                DropdownButtonFormField<String>(
                  initialValue: _kebele,
                  decoration: InputDecoration(
                    labelText: 'Kebele (Neighborhood)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                  ),
                  items: AppConstants.jimmaKebeles
                      .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                      .toList(),
                  onChanged: (v) => setState(() => _kebele = v!),
                ),
                const SizedBox(height: 16),

                // ── Description ──────────────────────────────────────────────
                CustomTextField(
                  label: 'Detailed Description',
                  hint: 'Describe the issue...',
                  controller: _descCtrl,
                  maxLines: 4,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // ── Photo ────────────────────────────────────────────────────
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      border: Border.all(color: theme.colorScheme.outlineVariant, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_imageFile!, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined, size: 48, color: theme.colorScheme.primary),
                              const SizedBox(height: 8),
                              const Text('Tap to take a photo'),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Location ─────────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Location',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    _gettingLocation
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : TextButton.icon(
                            onPressed: _getLocation,
                            icon: const Icon(Icons.my_location, size: 18),
                            label: const Text('Detect Current Location'),
                          ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 220,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: LatLng(_lat, _lng),
                        initialZoom: 14.0,
                        maxZoom: 22.0, // Allow user to zoom deeply
                        onTap: (_, p) => _setManualLocation(p),
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                        ),
                      ),
                      children: [
                        TileLayer(
                          // Esri World Imagery (Free satellite tiles)
                          urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                          userAgentPackageName: 'com.jimma.cityfix.cityfix_mobile',
                          maxZoom: 22.0,
                          maxNativeZoom: 19, // Use zoom 19 tiles and stretch them for zoom 20+
                        ),
                        if (_hasSetLocation)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(_lat, _lng),
                                width: 40,
                                height: 40,
                                child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                                alignment: Alignment.topCenter,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _hasSetLocation 
                      ? _addressCtrl.text.isNotEmpty 
                          ? 'Selected: ${_addressCtrl.text}' 
                          : 'Location pinpointed'
                      : 'Tap the map to set a location, or press detect.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _hasSetLocation ? theme.colorScheme.primary : theme.colorScheme.outline,
                    fontWeight: _hasSetLocation ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 32),

                // ── Submit ───────────────────────────────────────────────────
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : FilledButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.send),
                        label: const Text('Submit Report'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
