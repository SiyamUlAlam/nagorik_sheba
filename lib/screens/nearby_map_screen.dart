import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/civic_service.dart';
import '../repositories/service_repository.dart';
import '../screens/service_details_screen.dart';
import '../theme/app_theme.dart';

class NearbyMapScreen extends StatefulWidget {
  const NearbyMapScreen({super.key});

  @override
  State<NearbyMapScreen> createState() => _NearbyMapScreenState();
}

class _NearbyMapScreenState extends State<NearbyMapScreen> {
  final ServiceRepository _repository = ServiceRepository();
  final MapController _mapController = MapController();

  bool _isLoading = true;
  String? _error;

  Position? _currentPosition;
  List<CivicService> _services = [];
  CivicService? _selectedService;

  ServiceCategory? _selectedCategory;

  static const LatLng _defaultCenter = LatLng(23.8103, 90.4125);

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  Future<void> _loadMapData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await Future.wait([
        _loadUserLocation(),
        _loadServices(),
      ]);

      setState(() {
        _isLoading = false;
      });

      _moveMapToUser();
    } catch (error) {
      setState(() {
        _isLoading = false;
        _error = 'Could not load map data: $error';
      });
    }
  }

  Future<void> _loadServices() async {
    final List<CivicService> services = await _repository.getActiveServices();

    setState(() {
      _services = services;
    });
  }

  Future<void> _loadUserLocation() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Location service is disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission permanently denied. Enable it from settings.',
      );
    }

    final Position position = await Geolocator.getCurrentPosition();

    setState(() {
      _currentPosition = position;
    });
  }

  void _moveMapToUser() {
    if (_currentPosition == null) return;

    _mapController.move(
      LatLng(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      ),
      13,
    );
  }

  List<CivicService> get _filteredServices {
    if (_selectedCategory == null) return _services;

    return _services
        .where((service) => service.category == _selectedCategory)
        .toList();
  }

  List<Marker> get _markers {
    final List<Marker> markers = [];

    if (_currentPosition != null) {
      markers.add(
        Marker(
          point: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          width: 46,
          height: 46,
          child: const _UserLocationMarker(),
        ),
      );
    }

    for (final CivicService service in _filteredServices) {
      markers.add(
        Marker(
          point: LatLng(service.latitude, service.longitude),
          width: 48,
          height: 48,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedService = service;
              });

              _mapController.move(
                LatLng(service.latitude, service.longitude),
                15,
              );
            },
            child: _ServiceMarker(
              category: service.category,
            ),
          ),
        ),
      );
    }

    return markers;
  }

  double? _distanceFromUser(CivicService service) {
    if (_currentPosition == null) return null;

    final double distanceInMeters = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      service.latitude,
      service.longitude,
    );

    return distanceInMeters / 1000;
  }

  void _openServiceDetails(CivicService service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceDetailsScreen(service: service),
      ),
    );
  }

  void _focusOnService(CivicService service) {
    _mapController.move(
      LatLng(service.latitude, service.longitude),
      15,
    );

    setState(() {
      _selectedService = service;
    });
  }

  void _changeCategory(ServiceCategory? category) {
    setState(() {
      _selectedCategory = category;
      _selectedService = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<CivicService> filteredServices = _filteredServices;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Services Map'),
        actions: [
          IconButton(
            onPressed: _loadMapData,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition == null
                  ? _defaultCenter
                  : LatLng(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
              ),
              initialZoom: _currentPosition == null ? 7 : 13,
              onTap: (_, __) {
                setState(() {
                  _selectedService = null;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'uftb.androidlab.nagorik_sheba',
              ),
              MarkerLayer(
                markers: _markers,
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),

          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: _CategoryFilterBar(
              selectedCategory: _selectedCategory,
              onChanged: _changeCategory,
            ),
          ),

          Positioned(
            right: 12,
            top: 74,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'locate_user',
                  backgroundColor: AppColors.card,
                  foregroundColor: AppColors.primary,
                  onPressed: _moveMapToUser,
                  child: const Icon(Icons.my_location_rounded),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom_in',
                  backgroundColor: AppColors.card,
                  foregroundColor: AppColors.primary,
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(
                      _mapController.camera.center,
                      currentZoom + 1,
                    );
                  },
                  child: const Icon(Icons.add_rounded),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom_out',
                  backgroundColor: AppColors.card,
                  foregroundColor: AppColors.primary,
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(
                      _mapController.camera.center,
                      currentZoom - 1,
                    );
                  },
                  child: const Icon(Icons.remove_rounded),
                ),
              ],
            ),
          ),

          if (_isLoading)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(),
            ),

          if (_error != null)
            Positioned(
              top: 80,
              left: 12,
              right: 12,
              child: _ErrorBox(
                message: _error!,
                onRetry: _loadMapData,
              ),
            ),

          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: _selectedService == null
                ? _ServiceSummaryPanel(
              serviceCount: filteredServices.length,
              services: filteredServices,
              distanceFromUser: _distanceFromUser,
              onTapService: _focusOnService,
            )
                : _SelectedServicePanel(
              service: _selectedService!,
              distanceKm: _distanceFromUser(_selectedService!),
              onClose: () {
                setState(() {
                  _selectedService = null;
                });
              },
              onOpenDetails: () {
                _openServiceDetails(_selectedService!);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UserLocationMarker extends StatelessWidget {
  const _UserLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.18),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceMarker extends StatelessWidget {
  final ServiceCategory category;

  const _ServiceMarker({
    required this.category,
  });

  IconData get _icon {
    switch (category) {
      case ServiceCategory.hospital:
        return Icons.local_hospital_rounded;
      case ServiceCategory.police:
        return Icons.local_police_rounded;
      case ServiceCategory.fire:
        return Icons.fire_truck_rounded;
      case ServiceCategory.ambulance:
        return Icons.emergency_rounded;
      case ServiceCategory.pharmacy:
        return Icons.medication_rounded;
      case ServiceCategory.govt:
        return Icons.account_balance_rounded;
    }
  }

  Color get _color {
    switch (category) {
      case ServiceCategory.hospital:
        return Colors.red;
      case ServiceCategory.police:
        return Colors.blue;
      case ServiceCategory.fire:
        return Colors.deepOrange;
      case ServiceCategory.ambulance:
        return Colors.pink;
      case ServiceCategory.pharmacy:
        return Colors.green;
      case ServiceCategory.govt:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      _icon,
      color: _color,
      size: 38,
      shadows: const [
        Shadow(
          color: Colors.white,
          blurRadius: 8,
        ),
      ],
    );
  }
}

class _CategoryFilterBar extends StatelessWidget {
  final ServiceCategory? selectedCategory;
  final ValueChanged<ServiceCategory?> onChanged;

  const _CategoryFilterBar({
    required this.selectedCategory,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<_MapFilterItem> filters = [
      const _MapFilterItem(label: 'All', category: null),
      const _MapFilterItem(
        label: 'Hospitals',
        category: ServiceCategory.hospital,
      ),
      const _MapFilterItem(
        label: 'Police',
        category: ServiceCategory.police,
      ),
      const _MapFilterItem(
        label: 'Fire',
        category: ServiceCategory.fire,
      ),
      const _MapFilterItem(
        label: 'Ambulance',
        category: ServiceCategory.ambulance,
      ),
      const _MapFilterItem(
        label: 'Pharmacy',
        category: ServiceCategory.pharmacy,
      ),
      const _MapFilterItem(
        label: 'Govt.',
        category: ServiceCategory.govt,
      ),
    ];

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final _MapFilterItem item = filters[index];
          final bool isSelected = selectedCategory == item.category;

          return ChoiceChip(
            selected: isSelected,
            label: Text(item.label),
            selectedColor: const Color(0xFFCCFBF1),
            labelStyle: TextStyle(
              color: isSelected ? AppColors.primaryDark : AppColors.text,
              fontWeight: FontWeight.w800,
            ),
            onSelected: (_) => onChanged(item.category),
          );
        },
      ),
    );
  }
}

class _MapFilterItem {
  final String label;
  final ServiceCategory? category;

  const _MapFilterItem({
    required this.label,
    required this.category,
  });
}

class _ServiceSummaryPanel extends StatelessWidget {
  final int serviceCount;
  final List<CivicService> services;
  final double? Function(CivicService service) distanceFromUser;
  final ValueChanged<CivicService> onTapService;

  const _ServiceSummaryPanel({
    required this.serviceCount,
    required this.services,
    required this.distanceFromUser,
    required this.onTapService,
  });

  @override
  Widget build(BuildContext context) {
    final List<CivicService> nearestServices = [...services];

    nearestServices.sort((a, b) {
      final double distanceA = distanceFromUser(a) ?? 999999;
      final double distanceB = distanceFromUser(b) ?? 999999;
      return distanceA.compareTo(distanceB);
    });

    final List<CivicService> topServices = nearestServices.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.place_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$serviceCount active services found',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (topServices.isEmpty)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'No services available for this filter.',
                style: TextStyle(
                  color: AppColors.muted,
                ),
              ),
            )
          else
            ...topServices.map(
                  (service) {
                final double? distanceKm = distanceFromUser(service);

                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  onTap: () => onTapService(service),
                  leading: const Icon(
                    Icons.location_on_rounded,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    service.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: Text(
                    distanceKm == null
                        ? service.address
                        : '${distanceKm.toStringAsFixed(1)} km • ${service.address}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _SelectedServicePanel extends StatelessWidget {
  final CivicService service;
  final double? distanceKm;
  final VoidCallback onClose;
  final VoidCallback onOpenDetails;

  const _SelectedServicePanel({
    required this.service,
    required this.distanceKm,
    required this.onClose,
    required this.onOpenDetails,
  });

  @override
  Widget build(BuildContext context) {
    final double? safeDistanceKm = distanceKm;

    final String categoryAndDistance = safeDistanceKm == null
        ? serviceCategoryLabel(service.category)
        : '${serviceCategoryLabel(service.category)} • ${safeDistanceKm.toStringAsFixed(1)} km away';

    return Container(
      decoration: _panelDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.business_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  service.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            service.address,
            style: const TextStyle(
              color: AppColors.muted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            categoryAndDistance,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onOpenDetails,
              icon: const Icon(Icons.info_rounded),
              label: const Text('View Details'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBox({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _panelDecoration(),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Text(
            message,
            style: const TextStyle(
              color: AppColors.danger,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _panelDecoration() {
  return BoxDecoration(
    color: AppColors.card,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.15),
        blurRadius: 14,
        offset: const Offset(0, 5),
      ),
    ],
  );
}