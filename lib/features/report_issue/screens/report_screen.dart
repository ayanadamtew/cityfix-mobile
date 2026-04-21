// lib/features/report_issue/screens/report_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:cityfix/l10n/app_localizations.dart';
import 'package:cityfix/shared/l10n_extensions.dart';
import '../providers/report_provider.dart';
import '../../../shared/custom_text_field.dart';
import '../../../core/constants.dart';
import '../../../services/location_service.dart';
import '../../../shared/custom_toast.dart';

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

  Future<void> _getLocation(AppLocalizations l) async {
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
        ToastService.showError(context, l.locationError(e.toString()));
      }
    } finally {
      if (mounted) setState(() => _gettingLocation = false);
    }
  }

  Future<void> _setManualLocation(LatLng point, AppLocalizations l) async {
    setState(() {
      _lat = point.latitude;
      _lng = point.longitude;
      _hasSetLocation = true;
      _addressCtrl.text = l.fetchingAddress;
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

  Future<void> _submit(AppLocalizations l) async {
    if (!_hasSetLocation) {
      ToastService.showError(context, l.locationRequired);
      return;
    }

    // ── Duplicate check ──────────────────────────────────────────────────
    ToastService.showInfo(context, l.checkingDuplicates);

    final dupResult = await ref.read(reportProvider.notifier).checkDuplicate(
          latitude: _lat,
          longitude: _lng,
          category: _category,
        );

    final isDuplicate = dupResult['isDuplicate'] == true;

    if (isDuplicate && mounted) {
      final nearbyReports = List<Map<String, dynamic>>.from(
        (dupResult['nearbyReports'] as List).map((e) => Map<String, dynamic>.from(e)),
      );

      final shouldProceed = await _showDuplicateWarning(l, nearbyReports);
      if (shouldProceed != true) return;
    }

    // ── Proceed with submission ──────────────────────────────────────────
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
        final message = isOfflineSaved ? l.reportSaved : l.reportSuccess;
        if (isOfflineSaved) {
          ToastService.showInfo(context, message);
        } else {
          ToastService.showSuccess(context, message);
        }
        // Reset form and go to feed
        context.go('/feed');
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError(context, l.failedToSubmit(e.toString()));
      }
    }
  }

  /// Shows a warning dialog when duplicates are found.
  /// Returns true if the user wants to submit anyway.
  Future<bool?> _showDuplicateWarning(
    AppLocalizations l,
    List<Map<String, dynamic>> nearbyReports,
  ) {
    final minDistance = nearbyReports
        .map((r) => r['distance'] as int? ?? 0)
        .reduce((a, b) => a < b ? a : b);

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48),
        title: Text(l.duplicateWarningTitle),
        content: Text(l.duplicateWarningBody(minDistance.toString())),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(false);
              _showNearbyReportsSheet(l, nearbyReports);
            },
            child: Text(l.seeDuplications),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.submitAnyway),
          ),
        ],
      ),
    );
  }

  /// Shows a bottom sheet listing nearby duplicate reports.
  void _showNearbyReportsSheet(
    AppLocalizations l,
    List<Map<String, dynamic>> nearbyReports,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (_, scrollCtrl) => Column(
            children: [
              // Handle bar
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  l.nearbyReports,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.separated(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: nearbyReports.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final report = nearbyReports[i];
                    final desc = report['description'] as String? ?? '';
                    final distance = report['distance']?.toString() ?? '?';
                    final category = report['category'] as String? ?? '';
                    final id = report['id'] as String? ?? '';

                    return ListTile(
                      leading: Icon(
                        _categoryIcon(category),
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(
                        desc.length > 80 ? '${desc.substring(0, 80)}...' : desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${l.metersAway(distance)} • $category',
                        style: theme.textTheme.bodySmall,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        context.push('/feed/comments/$id');
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Water':
        return Icons.water_drop;
      case 'Waste':
        return Icons.delete;
      case 'Road':
        return Icons.add_road;
      case 'Electricity':
        return Icons.electric_bolt;
      default:
        return Icons.report;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(reportProvider).isLoading;
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l.reportAnIssue)),
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
                    labelText: l.category,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                  ),
                  items: AppConstants.categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(l.translateCategory(c))))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: 16),

                // ── Kebele Dropdown ──────────────────────────────────────────
                DropdownButtonFormField<String>(
                  initialValue: _kebele,
                  decoration: InputDecoration(
                    labelText: l.kebele,
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
                  label: l.detailedDescription,
                  hint: l.descriptionHint,
                  controller: _descCtrl,
                  maxLines: 4,
                  validator: (v) => v!.isEmpty ? l.required : null,
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
                              Text(l.tapToPhoto),
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
                        l.location,
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
                            onPressed: () => _getLocation(l),
                            icon: const Icon(Icons.my_location, size: 18),
                            label: Text(l.detectLocation),
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
                        maxZoom: 22.0,
                        onTap: (_, p) => _setManualLocation(p, l),
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                          userAgentPackageName: 'com.jimma.cityfix.cityfix_mobile',
                          maxZoom: 22.0,
                          maxNativeZoom: 19,
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
                          ? l.locationSelected(_addressCtrl.text) 
                          : l.locationPinpointed
                      : l.locationInstruction,
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
                        onPressed: () => _submit(l),
                        icon: const Icon(Icons.send),
                        label: Text(l.submitReport),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
