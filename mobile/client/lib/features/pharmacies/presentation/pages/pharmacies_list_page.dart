import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/pharmacy_entity.dart';
import '../../../../config/providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../providers/pharmacies_state.dart';
import '../widgets/pharmacy_card.dart';

class PharmaciesListPage extends ConsumerStatefulWidget {
  const PharmaciesListPage({super.key});

  @override
  ConsumerState<PharmaciesListPage> createState() => _PharmaciesListPageState();
}

enum DistanceFilter {
  all('Toutes distances'),
  km1('< 1 km'),
  km5('< 5 km'),
  km10('< 10 km');

  final String label;
  const DistanceFilter(this.label);
}

enum AvailabilityFilter {
  all('Toutes'),
  open('Ouvertes seulement'),
  closed('Fermées seulement');

  final String label;
  const AvailabilityFilter(this.label);
}

enum PharmacyListMode { all, nearby, onDuty }

class _PharmaciesListPageState extends ConsumerState<PharmaciesListPage> {
  final _scrollController = ScrollController();
  PharmacyListMode _mode = PharmacyListMode.all;
  Position? _currentPosition;
  DistanceFilter _distanceFilter = DistanceFilter.all;
  AvailabilityFilter _availabilityFilter = AvailabilityFilter.all;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Fetch pharmacies on initial load
    Future.microtask(
      () =>
          ref.read(pharmaciesProvider.notifier).fetchPharmacies(refresh: true),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      ref.read(pharmaciesProvider.notifier).fetchPharmacies();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> _toggleNearbyMode() async {
    setState(() {
      _mode = _mode == PharmacyListMode.nearby
          ? PharmacyListMode.all
          : PharmacyListMode.nearby;
    });

    if (_mode == PharmacyListMode.nearby) {
      await _fetchNearbyPharmacies();
    } else {
      await ref
          .read(pharmaciesProvider.notifier)
          .fetchPharmacies(refresh: true);
    }
  }

  Future<void> _fetchNearbyPharmacies() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          _showLocationServiceDialog();
        }
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            _showPermissionDeniedSnackBar();
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          _showPermissionDeniedForeverDialog();
        }
        return;
      }

      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Text('Localisation en cours...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _mode = PharmacyListMode.nearby;
      });

      // Fetch nearby pharmacies
      await ref
          .read(pharmaciesProvider.notifier)
          .fetchNearbyPharmacies(
            latitude: position.latitude,
            longitude: position.longitude,
            radius: 10.0, // 10 km radius
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pharmacies à proximité chargées'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de localisation: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      setState(() {
        _mode = PharmacyListMode.all;
      });
    }
  }

  Future<void> _fetchOnDutyPharmacies() async {
    setState(() {
      _mode = PharmacyListMode.onDuty;
    });

    await ref.read(pharmaciesProvider.notifier).fetchOnDutyPharmacies(
          latitude: _currentPosition?.latitude,
          longitude: _currentPosition?.longitude,
        );
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Services de localisation désactivés'),
        content: const Text(
          'Veuillez activer les services de localisation pour trouver les pharmacies à proximité.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openLocationSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ouvrir paramètres'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Permission de localisation refusée'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showPermissionDeniedForeverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission requise'),
        content: const Text(
          'L\'accès à la localisation a été refusé de manière permanente. '
          'Veuillez activer la permission dans les paramètres de l\'application.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ouvrir paramètres'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pharmaciesState = ref.watch(pharmaciesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _mode == PharmacyListMode.nearby
              ? 'Pharmacies à proximité'
              : _mode == PharmacyListMode.onDuty
                  ? 'Pharmacies de garde'
                  : 'Pharmacies',
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // On Duty Button
          if (_mode != PharmacyListMode.onDuty)
            IconButton(
              icon: const Icon(Icons.emergency, color: Colors.white),
              tooltip: 'Pharmacies de garde',
              onPressed: _fetchOnDutyPharmacies,
            ),
          // Filter button (only in nearby mode)
          if (_mode == PharmacyListMode.nearby)
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              tooltip: 'Filtres',
              onPressed: _showFiltersDialog,
            ),
          // Toggle between all and nearby (if not in onDuty mode, or switch out of onDuty)
          IconButton(
            icon: Icon(
              _mode == PharmacyListMode.nearby
                  ? Icons.list
                  : Icons.location_on,
              color: Colors.white,
            ),
            tooltip: _mode == PharmacyListMode.nearby
                ? 'Voir toutes les pharmacies'
                : 'Pharmacies à proximité',
            onPressed: () {
               if (_mode == PharmacyListMode.onDuty) {
                  // Switch to all
                  setState(() { _mode = PharmacyListMode.all; });
                  ref.read(pharmaciesProvider.notifier).fetchPharmacies();
               } else {
                 _toggleNearbyMode();
               }
            },
          ),
          IconButton(
            icon: const Icon(Icons.map, color: Colors.white),
            tooltip: 'Voir la carte',
            onPressed: () => context.goToPharmaciesMap(
              pharmacies: pharmaciesState.pharmacies,
              userLatitude: _currentPosition?.latitude,
              userLongitude: _currentPosition?.longitude,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (_mode == PharmacyListMode.nearby) {
            await _fetchNearbyPharmacies();
          } else {
            await ref
                .read(pharmaciesProvider.notifier)
                .fetchPharmacies(refresh: true);
          }
        },
        child: Column(
          children: [
            // Active filters display
            if (_mode == PharmacyListMode.nearby &&
                (_distanceFilter != DistanceFilter.all ||
                    _availabilityFilter != AvailabilityFilter.all))
              _buildActiveFiltersChips(),
            Expanded(child: _buildBody(pharmaciesState)),
          ],
        ),
      ),
      floatingActionButton: _mode != PharmacyListMode.nearby
          ? FloatingActionButton.extended(
              onPressed: _fetchNearbyPharmacies,
              icon: const Icon(Icons.my_location),
              label: const Text('À proximité'),
              backgroundColor: AppColors.success,
            )
          : null,
    );
  }

  Widget _buildBody(PharmaciesState state) {
    if (state.status == PharmaciesStatus.loading && state.pharmacies.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == PharmaciesStatus.error && state.pharmacies.isEmpty) {
      return _buildError(state.errorMessage ?? 'Une erreur est survenue');
    }

    // Select list based on mode
    List<PharmacyEntity> sourceList;
    switch (_mode) {
      case PharmacyListMode.nearby:
        sourceList = state.nearbyPharmacies;
        break;
      case PharmacyListMode.onDuty:
        sourceList = state.onDutyPharmacies;
        break;
      case PharmacyListMode.all:
        sourceList = state.pharmacies;
        break;
    }

    // Apply filters
    var filteredPharmacies = sourceList;

    // Apply availability filter
    if (_availabilityFilter != AvailabilityFilter.all) {
      filteredPharmacies = filteredPharmacies.where((pharmacy) {
        if (_availabilityFilter == AvailabilityFilter.open) {
          return pharmacy.isOpen;
        } else {
          return !pharmacy.isOpen;
        }
      }).toList();
    }

    if (filteredPharmacies.isEmpty) {
      return _buildEmptyState(
        message: 'Aucune pharmacie ne correspond aux filtres sélectionnés',
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: state.hasReachedMax
          ? filteredPharmacies.length
          : filteredPharmacies.length + 1,
      itemBuilder: (context, index) {
        if (index >= filteredPharmacies.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final pharmacy = filteredPharmacies[index];

        // Calculate distance if we have current position and pharmacy coordinates
        double? distance;
        if (_currentPosition != null &&
            pharmacy.latitude != null &&
            pharmacy.longitude != null) {
          distance =
              Geolocator.distanceBetween(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
                pharmacy.latitude!,
                pharmacy.longitude!,
              ) /
              1000; // Convert to kilometers

          // Apply distance filter
          if (_distanceFilter != DistanceFilter.all) {
            if (_distanceFilter == DistanceFilter.km1 && distance >= 1) {
              return const SizedBox.shrink();
            } else if (_distanceFilter == DistanceFilter.km5 && distance >= 5) {
              return const SizedBox.shrink();
            } else if (_distanceFilter == DistanceFilter.km10 &&
                distance >= 10) {
              return const SizedBox.shrink();
            }
          }
        }

        return PharmacyCard(
          pharmacy: pharmacy,
          distance: distance,
          onTap: () => context.goToPharmacy(pharmacyId: pharmacy.id),
        );
      },
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(pharmaciesProvider.notifier)
                    .fetchPharmacies(refresh: true);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({String? message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_pharmacy_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              message ?? 'Aucune pharmacie disponible',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Les pharmacies apparaîtront ici',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFiltersChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          if (_distanceFilter != DistanceFilter.all)
            Chip(
              avatar: const Icon(Icons.straighten, size: 18),
              label: Text(_distanceFilter.label),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () {
                setState(() {
                  _distanceFilter = DistanceFilter.all;
                });
              },
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              side: BorderSide.none,
            ),
          if (_availabilityFilter != AvailabilityFilter.all)
            Chip(
              avatar: Icon(
                _availabilityFilter == AvailabilityFilter.open
                    ? Icons.check_circle
                    : Icons.cancel,
                size: 18,
                color: _availabilityFilter == AvailabilityFilter.open
                    ? AppColors.success
                    : AppColors.error,
              ),
              label: Text(_availabilityFilter.label),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () {
                setState(() {
                  _availabilityFilter = AvailabilityFilter.all;
                });
              },
              backgroundColor:
                  (_availabilityFilter == AvailabilityFilter.open
                          ? AppColors.success
                          : AppColors.error)
                      .withValues(alpha: 0.1),
              side: BorderSide.none,
            ),
        ],
      ),
    );
  }

  void _showFiltersDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filtres',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Distance filter
              const Text(
                'Distance maximale',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: DistanceFilter.values.map((filter) {
                  final isSelected = _distanceFilter == filter;
                  return ChoiceChip(
                    label: Text(filter.label),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _distanceFilter = filter;
                      });
                      setModalState(() {});
                    },
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.primary,
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Availability filter
              const Text(
                'Disponibilité',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AvailabilityFilter.values.map((filter) {
                  final isSelected = _availabilityFilter == filter;
                  return ChoiceChip(
                    label: Text(filter.label),
                    selected: isSelected,
                    avatar: filter == AvailabilityFilter.open
                        ? Icon(
                            Icons.check_circle,
                            size: 18,
                            color: isSelected ? AppColors.success : Colors.grey,
                          )
                        : filter == AvailabilityFilter.closed
                        ? Icon(
                            Icons.cancel,
                            size: 18,
                            color: isSelected ? AppColors.error : Colors.grey,
                          )
                        : null,
                    onSelected: (selected) {
                      setState(() {
                        _availabilityFilter = filter;
                      });
                      setModalState(() {});
                    },
                    selectedColor: filter == AvailabilityFilter.open
                        ? AppColors.success.withValues(alpha: 0.2)
                        : filter == AvailabilityFilter.closed
                        ? AppColors.error.withValues(alpha: 0.2)
                        : AppColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: filter == AvailabilityFilter.open
                        ? AppColors.success
                        : filter == AvailabilityFilter.closed
                        ? AppColors.error
                        : AppColors.primary,
                    side: BorderSide(
                      color: isSelected
                          ? (filter == AvailabilityFilter.open
                                ? AppColors.success
                                : filter == AvailabilityFilter.closed
                                ? AppColors.error
                                : AppColors.primary)
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _distanceFilter = DistanceFilter.all;
                          _availabilityFilter = AvailabilityFilter.all;
                        });
                        setModalState(() {});
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Réinitialiser'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Appliquer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
