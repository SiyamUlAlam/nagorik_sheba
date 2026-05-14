import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../data/categories.dart';
import '../models/civic_service.dart';
import '../repositories/service_repository.dart';
import '../screens/emergency_screen.dart';
import '../screens/nearby_map_screen.dart';
import '../screens/service_details_screen.dart';
import '../screens/service_list_screen.dart';
import '../theme/app_theme.dart';
import '../utils/launcher_helper.dart';
import '../widgets/category_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ServiceRepository _repository = ServiceRepository();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _error;

  List<CivicService> _services = [];
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {});
    });

    _loadHomeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHomeData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final List<CivicService> services = await _repository.getActiveServices();

      setState(() {
        _services = services;
      });

      await _loadUserLocationSafely();

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _error = 'Could not load home data: $error';
      });
    }
  }

  Future<void> _loadUserLocationSafely() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final Position position = await Geolocator.getCurrentPosition();

      setState(() {
        _currentPosition = position;
      });
    } catch (_) {
      // Location is helpful but not mandatory on the homepage.
    }
  }

  void _openCategory(BuildContext context, CategoryItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceListScreen(category: item.category),
      ),
    );
  }

  void _openEmergency(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EmergencyScreen(),
      ),
    );
  }

  void _openNearbyMap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NearbyMapScreen(),
      ),
    );
  }

  void _openServiceDetails(CivicService service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceDetailsScreen(service: service),
      ),
    );
  }

  int _countByCategory(ServiceCategory category) {
    return _services.where((service) => service.category == category).length;
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

  List<CivicService> get _nearestEmergencyServices {
    final List<CivicService> importantServices = _services.where((service) {
      return service.category == ServiceCategory.hospital ||
          service.category == ServiceCategory.police ||
          service.category == ServiceCategory.fire ||
          service.category == ServiceCategory.ambulance;
    }).toList();

    if (_currentPosition != null) {
      importantServices.sort((a, b) {
        final double distanceA = _distanceFromUser(a) ?? 999999;
        final double distanceB = _distanceFromUser(b) ?? 999999;
        return distanceA.compareTo(distanceB);
      });
    }

    return importantServices.take(3).toList();
  }

  List<CivicService> get _searchResults {
    final String query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) return [];

    return _services.where((service) {
      return service.name.toLowerCase().contains(query) ||
          service.address.toLowerCase().contains(query) ||
          service.area.toLowerCase().contains(query) ||
          service.district.toLowerCase().contains(query) ||
          serviceCategoryLabel(service.category).toLowerCase().contains(query);
    }).take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<CivicService> searchResults = _searchResults;
    final List<CivicService> nearestEmergencyServices =
        _nearestEmergencyServices;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadHomeData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroSection(
                  totalServices: _services.length,
                  onEmergencyCall: () {
                    LauncherHelper.callNumber(context, '999');
                  },
                  onEmergencyOptions: () {
                    _openEmergency(context);
                  },
                  onNearbyMap: () {
                    _openNearbyMap(context);
                  },
                ),

                const SizedBox(height: 18),

                if (_isLoading) const LinearProgressIndicator(),

                if (_error != null)
                  _ErrorBox(
                    message: _error!,
                    onRetry: _loadHomeData,
                  ),

                const SizedBox(height: 18),

                _DashboardSummary(
                  totalServices: _services.length,
                  hospitalCount: _countByCategory(ServiceCategory.hospital),
                  policeCount: _countByCategory(ServiceCategory.police),
                  pharmacyCount: _countByCategory(ServiceCategory.pharmacy),
                  emergencyCount: _countByCategory(ServiceCategory.fire) +
                      _countByCategory(ServiceCategory.ambulance),
                ),

                const SizedBox(height: 22),

                _HomeSearchBox(
                  controller: _searchController,
                ),

                if (searchResults.isNotEmpty)
                  _SearchResultsPanel(
                    results: searchResults,
                    distanceFromUser: _distanceFromUser,
                    onTapService: _openServiceDetails,
                  ),

                const SizedBox(height: 22),

                _NearestEmergencySection(
                  services: nearestEmergencyServices,
                  hasLocation: _currentPosition != null,
                  distanceFromUser: _distanceFromUser,
                  onTapService: _openServiceDetails,
                ),

                const SizedBox(height: 26),

                const Text(
                  'Service Categories',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),

                const SizedBox(height: 14),

                ...categories.map(
                      (item) => CategoryCard(
                    item: item,
                    onTap: () => _openCategory(context, item),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final int totalServices;
  final VoidCallback onEmergencyCall;
  final VoidCallback onEmergencyOptions;
  final VoidCallback onNearbyMap;

  const _HeroSection({
    required this.totalServices,
    required this.onEmergencyCall,
    required this.onEmergencyOptions,
    required this.onNearbyMap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.location_city_rounded,
            color: Colors.white,
            size: 42,
          ),

          const SizedBox(height: 14),

          const Text(
            'Nagorik Sheba',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            totalServices == 0
                ? 'Find nearby civic services quickly and easily.'
                : '$totalServices active civic services available.',
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFFE0F2F1),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onEmergencyCall,
              icon: const Icon(Icons.call),
              label: const Text('Emergency Call 999'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEmergencyOptions,
                  icon: const Icon(Icons.emergency_share_rounded),
                  label: const Text('Emergency'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white70),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onNearbyMap,
                  icon: const Icon(Icons.map_rounded),
                  label: const Text('Map View'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardSummary extends StatelessWidget {
  final int totalServices;
  final int hospitalCount;
  final int policeCount;
  final int pharmacyCount;
  final int emergencyCount;

  const _DashboardSummary({
    required this.totalServices,
    required this.hospitalCount,
    required this.policeCount,
    required this.pharmacyCount,
    required this.emergencyCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Service Summary',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.text,
          ),
        ),

        const SizedBox(height: 12),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.65,
          children: [
            _StatCard(
              icon: Icons.apps_rounded,
              title: 'All Services',
              value: totalServices.toString(),
            ),
            _StatCard(
              icon: Icons.local_hospital_rounded,
              title: 'Hospitals',
              value: hospitalCount.toString(),
            ),
            _StatCard(
              icon: Icons.local_police_rounded,
              title: 'Police',
              value: policeCount.toString(),
            ),
            _StatCard(
              icon: Icons.medication_rounded,
              title: 'Pharmacy',
              value: pharmacyCount.toString(),
            ),
            _StatCard(
              icon: Icons.emergency_rounded,
              title: 'Emergency',
              value: emergencyCount.toString(),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFCCFBF1),
            child: Icon(
              icon,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeSearchBox extends StatelessWidget {
  final TextEditingController controller;

  const _HomeSearchBox({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search hospital, police, pharmacy, area...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
          onPressed: controller.clear,
          icon: const Icon(Icons.close_rounded),
        ),
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
      ),
    );
  }
}

class _SearchResultsPanel extends StatelessWidget {
  final List<CivicService> results;
  final double? Function(CivicService service) distanceFromUser;
  final ValueChanged<CivicService> onTapService;

  const _SearchResultsPanel({
    required this.results,
    required this.distanceFromUser,
    required this.onTapService,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Search Results',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),

          const SizedBox(height: 8),

          ...results.map(
                (service) {
              final double? distanceKm = distanceFromUser(service);

              return ListTile(
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
                      ? '${serviceCategoryLabel(service.category)} • ${service.area}'
                      : '${serviceCategoryLabel(service.category)} • ${distanceKm.toStringAsFixed(1)} km',
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

class _NearestEmergencySection extends StatelessWidget {
  final List<CivicService> services;
  final bool hasLocation;
  final double? Function(CivicService service) distanceFromUser;
  final ValueChanged<CivicService> onTapService;

  const _NearestEmergencySection({
    required this.services,
    required this.hasLocation,
    required this.distanceFromUser,
    required this.onTapService,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.near_me_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasLocation
                      ? 'Nearest Emergency Services'
                      : 'Important Emergency Services',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            hasLocation
                ? 'Sorted based on your current location.'
                : 'Enable location to sort services by distance.',
            style: const TextStyle(
              color: AppColors.muted,
            ),
          ),

          const SizedBox(height: 12),

          if (services.isEmpty)
            const Text(
              'No emergency services found yet.',
              style: TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            ...services.map(
                  (service) {
                final double? distanceKm = distanceFromUser(service);

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () => onTapService(service),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFCCFBF1),
                    child: Icon(
                      _serviceIcon(service.category),
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(
                    service.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  subtitle: Text(
                    distanceKm == null
                        ? '${serviceCategoryLabel(service.category)} • ${service.area}'
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

  static IconData _serviceIcon(ServiceCategory category) {
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
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: const TextStyle(
              color: Color(0xFF991B1B),
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