// lib/features/my_reports/screens/my_reports_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:cityfix/l10n/app_localizations.dart';
import 'package:cityfix/shared/l10n_extensions.dart';

import 'package:cached_network_image/cached_network_image.dart';

import '../../feed/providers/feed_provider.dart';
import '../providers/my_reports_provider.dart';
import '../widgets/my_report_card.dart';
import '../../../core/constants.dart';
import '../../../shared/custom_toast.dart';
import '../../../core/providers/connectivity_provider.dart';

class MyReportsScreen extends ConsumerStatefulWidget {
  const MyReportsScreen({super.key});

  @override
  ConsumerState<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends ConsumerState<MyReportsScreen> {
  void _showFeedbackModal(BuildContext context, WidgetRef ref, String issueId) {
    final l = AppLocalizations.of(context)!;
    double selectedRating = 5.0;
    final commentCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.rateResolution,
                style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 16),
            RatingBar.builder(
              initialRating: 5,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) => selectedRating = rating,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentCtrl,
              decoration: InputDecoration(
                hintText: l.optionalComment,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  try {
                    await ref
                        .read(myReportsProvider.notifier)
                        .submitFeedback(issueId, selectedRating, commentCtrl.text);
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ToastService.showSuccess(ctx, l.feedbackSubmitted);
                    }
                  } catch (e) {
                    if (ctx.mounted) {
                      ToastService.showError(ctx, l.failedGeneric(e.toString()));
                    }
                  }
                },
                child: Text(l.submitFeedback),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );
  }

  void _showEditModal(BuildContext context, WidgetRef ref, Issue issue) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditReportForm(issue: issue, ref: ref),
    );
  }

  void _confirmAndDelete(BuildContext context, WidgetRef ref, String issueId) {
    final l = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Report'),
        content: Text('Are you sure you want to delete this report? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel ?? 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(myReportsProvider.notifier).deleteIssue(issueId);
                if (context.mounted) {
                  ToastService.showSuccess(context, 'Report deleted successfully');
                }
              } catch (e) {
                if (context.mounted) {
                  ToastService.showError(context, l.failedGeneric(e.toString()));
                }
              }
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showConfirmationModal(BuildContext context, WidgetRef ref, Issue issue) {
    final l = AppLocalizations.of(context)!;
    final reasonCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Review Resolution',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('A technician has marked this issue as fixed. Please review the provided proof and confirm.', style: Theme.of(ctx).textTheme.bodyMedium),
            const SizedBox(height: 16),
            
            if (issue.proofAfterPhotoUrl != null && issue.proofAfterPhotoUrl!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: issue.proofAfterPhotoUrl!.startsWith('http')
                      ? issue.proofAfterPhotoUrl!
                      : '\${AppConstants.baseUrl}\${issue.proofAfterPhotoUrl}',
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
            ],
            
            if (issue.proofNotes != null && issue.proofNotes!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Technician Notes:', style: Theme.of(ctx).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(issue.proofNotes!),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                hintText: 'Reason (Required if rejecting)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () async {
                      if (reasonCtrl.text.trim().isEmpty) {
                        ToastService.showInfo(ctx, 'Please provide a reason for rejecting.');
                        return;
                      }
                      try {
                        await ref.read(myReportsProvider.notifier).confirmResolution(
                          issue.id,
                          false,
                          reason: reasonCtrl.text.trim(),
                        );
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ToastService.showSuccess(ctx, 'Fix rejected.');
                        }
                      } catch (e) {
                        if (ctx.mounted) {
                          ToastService.showError(ctx, 'Failed to reject fix.');
                        }
                      }
                    },
                    child: const Text('Not Fixed'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      try {
                        await ref.read(myReportsProvider.notifier).confirmResolution(
                          issue.id,
                          true,
                          reason: reasonCtrl.text.trim(),
                        );
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ToastService.showSuccess(ctx, 'Fix confirmed! Thank you.');
                          // Could automatically show feedback modal next
                        }
                      } catch (e) {
                        if (ctx.mounted) {
                          ToastService.showError(ctx, 'Failed to confirm fix.');
                        }
                      }
                    },
                    child: const Text('Confirm Fixed'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myReportsProvider);
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final isOffline = ref.watch(isOfflineProvider);

    // Listen for connectivity changes to show "Back Online" feedback
    ref.listen(isOfflineProvider, (previous, current) {
      if (previous == true && current == false) {
        ToastService.showSuccess(context, l.backOnline);
        ref.read(myReportsProvider.notifier).refresh();
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l.myReports)),
      body: RefreshIndicator(
        onRefresh: () => ref.read(myReportsProvider.notifier).refresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            if (isOffline)
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: Colors.red.shade800,
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l.offlineMode,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            state.when(
              data: (issues) {
                if (issues.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(child: Text(l.noReportsYet)),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.all(8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final issue = issues[index];
                        return MyReportCard(
                          issue: issue,
                          onEdit: () => _showEditModal(context, ref, issue),
                          onDelete: () => _confirmAndDelete(context, ref, issue.id),
                          onFeedback: () => _showFeedbackModal(context, ref, issue.id),
                          onConfirmResolution: () => _showConfirmationModal(context, ref, issue),
                        );
                      },
                      childCount: issues.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_off_rounded,
                          size: 64,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l.failedGeneric(e.toString()),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () => ref.read(myReportsProvider.notifier).refresh(),
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(l.retry),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditReportForm extends StatefulWidget {
  const _EditReportForm({required this.issue, required this.ref});
  final Issue issue;
  final WidgetRef ref;

  @override
  State<_EditReportForm> createState() => _EditReportFormState();
}

class _EditReportFormState extends State<_EditReportForm> {
  late final TextEditingController _descCtrl;
  late final MapController _mapController;

  late String _selectedCategory;
  String? _selectedSubcategory;
  late String _selectedKebele;
  late double _lat;
  late double _lng;
  late String _address;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(text: widget.issue.description);
    _mapController = MapController();

    _selectedCategory = widget.issue.category;
    if (!AppConstants.categories.contains(_selectedCategory)) {
      _selectedCategory = AppConstants.categories.first;
    }
    _selectedSubcategory = widget.issue.subcategory;

    final rawKebele = widget.issue.rawLocation?['kebele']?.toString() ?? '';
    _selectedKebele = AppConstants.jimmaKebeles.contains(rawKebele)
        ? rawKebele
        : AppConstants.jimmaKebeles.first;

    _lat = widget.issue.latitude() ?? 7.6750;
    _lng = widget.issue.longitude() ?? 36.8370;
    _address = widget.issue.rawLocation?['address']?.toString() ?? 'Coordinate chosen';
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _handleMapTap(TapPosition tapPosition, LatLng point) async {
    final l = AppLocalizations.of(context)!;
    setState(() {
      _lat = point.latitude;
      _lng = point.longitude;
      _address = l.fetchingAddress;
    });

    try {
      final placemarks = await geo.placemarkFromCoordinates(point.latitude, point.longitude);
      if (placemarks.isNotEmpty) {
        final pm = placemarks.first;
        final street = pm.street ?? '';
        final locality = pm.locality ?? '';
        final adminArea = pm.administrativeArea ?? '';
        setState(() {
          _address = [street, locality, adminArea].where((s) => s.isNotEmpty).join(', ');
        });
      } else {
        setState(() {
          _address = '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}';
        });
      }
    } catch (_) {
      setState(() {
        _address = '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}';
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_descCtrl.text.trim().isEmpty) return;
    final l = AppLocalizations.of(context)!;

    setState(() => _isSaving = true);
    try {
      final patchedIssue = Issue(
        id: widget.issue.id,
        title: widget.issue.title,
        description: widget.issue.description,
        status: widget.issue.status,
        category: widget.issue.category,
        urgencyScore: widget.issue.urgencyScore,
        createdAt: widget.issue.createdAt,
        photoUrl: widget.issue.photoUrl,
        rawLocation: {
           'latitude': _lat,
           'longitude': _lng,
           'address': _address,
           'kebele': _selectedKebele,
        }
      );

      await widget.ref.read(myReportsProvider.notifier).updateIssue(
            widget.issue.id,
            _descCtrl.text.trim(),
            _selectedCategory,
            _selectedKebele,
            patchedIssue.copyWith(subcategory: _selectedSubcategory),
          );
      if (mounted) {
        Navigator.pop(context);
        ToastService.showSuccess(context, l.reportUpdated);
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError(context, l.updateFailed(e.toString()));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              l.editReport,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: l.category,
                      border: const OutlineInputBorder(),
                    ),
                    items: AppConstants.categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(l.translateCategory(c))))
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedCategory = v!;
                        _selectedSubcategory = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  if (AppConstants.subcategories[_selectedCategory] != null) ...[
                    DropdownButtonFormField<String>(
                      value: _selectedSubcategory,
                      decoration: const InputDecoration(
                        labelText: 'Subcategory',
                        border: OutlineInputBorder(),
                      ),
                      items: AppConstants.subcategories[_selectedCategory]!
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedSubcategory = v),
                    ),
                    const SizedBox(height: 16),
                  ],

                  DropdownButtonFormField<String>(
                    initialValue: _selectedKebele,
                    decoration: InputDecoration(
                      labelText: l.kebele,
                      border: const OutlineInputBorder(),
                    ),
                    items: AppConstants.jimmaKebeles
                        .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedKebele = v!),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _descCtrl,
                    decoration: InputDecoration(
                      labelText: l.description,
                      alignLabelWithHint: true,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),

                  // Location Map
                  Text(
                    l.updateMapLocation,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 180,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: LatLng(_lat, _lng),
                          initialZoom: 15.0,
                          maxZoom: 22.0,
                          onTap: _handleMapTap,
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
                    _address,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  FilledButton(
                    onPressed: _isSaving ? null : _saveChanges,
                    child: _isSaving 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(l.saveChanges),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
