import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../data/categories.dart';
import '../models/civic_service.dart';
import '../repositories/service_repository.dart';
import '../screens/service_details_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/service_card.dart';

class ServiceListScreen extends StatefulWidget {
  final ServiceCategory category;

  const ServiceListScreen({
    super.key,
    required this.category,
  });

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ServiceRepository _repository = ServiceRepository();

  Position? _currentPosition;
  bool _isLoadingLocation = true;
  bool _isLoadingServices = true;
  String? _locationError;
  String? _serviceError;

  List<CivicService> _services = [];

  String _selectedDistrict = 'All';
  bool _showOnlyOpen24Hours = false;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {});
    });

    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadUserLocation(),
      _loadServices(),
    ]);
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoadingServices = true;
      _serviceError = null;
    });

    try {
      final List<CivicService> loadedServices =
      await _repository.getServicesByCategory(widget.category);

      setState(() {
        _services = loadedServices;
        _isLoadingServices = false;
      });
    } catch (error) {
      setState(() {
        _isLoadingServices = false;
        _serviceError = 'Could not load services from database.';
      });
    }
  }

  Future<void> _loadUserLocation() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          _isLoadingLocation = false;
          _locationError = 'Location service is disabled.';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          _isLoadingLocation = false;
          _locationError = 'Location permission denied.';
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
          _locationError =
          'Location permission permanently denied. Enable it from settings.';
        });
        return;
      }

      final Position position = await Geolocator.getCurrentPosition();

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
        _locationError = null;
      });
    } catch (error) {
      setState(() {
        _isLoadingLocation = false;
        _locationError = 'Could not get your location.';
      });
    }
  }

  Future<void> _refreshPage() async {
    await Future.wait([
      _loadUserLocation(),
      _loadServices(),
    ]);
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

  List<String> _getDistricts() {
    final Set<String> districts =
    _services.map((service) => service.district).toSet();

    final List<String> districtList = districts.toList()..sort();

    return ['All', ...districtList];
  }

  bool _matchesSearch(CivicService service, String query) {
    final String lowerQuery = query.toLowerCase();

    return service.name.toLowerCase().contains(lowerQuery) ||
        service.address.toLowerCase().contains(lowerQuery) ||
        service.area.toLowerCase().contains(lowerQuery) ||
        service.district.toLowerCase().contains(lowerQuery);
  }

  List<CivicService> _getFilteredAndSortedServices() {
    final String query = _searchController.text.trim();

    List<CivicService> filtered = _services.where((service) {
      if (_selectedDistrict == 'All') return true;
      return service.district == _selectedDistrict;
    }).where((service) {
      if (!_showOnlyOpen24Hours) return true;
      return service.isOpen24Hours;
    }).where((service) {
      if (query.isEmpty) return true;
      return _matchesSearch(service, query);
    }).toList();

    if (_currentPosition != null) {
      filtered.sort((a, b) {
        final double distanceA = _distanceFromUser(a) ?? 999999;
        final double distanceB = _distanceFromUser(b) ?? 999999;
        return distanceA.compareTo(distanceB);
      });
    }

    return filtered;
  }

  void _openDetails(CivicService service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceDetailsScreen(service: service),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedDistrict = 'All';
      _showOnlyOpen24Hours = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<CivicService> serviceList = _getFilteredAndSortedServices();
    final List<String> districts = _getDistricts();

    return Scaffold(
      appBar: AppBar(
        title: Text(getCategoryTitle(widget.category)),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPage,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _SearchAndFilterBox(
              searchController: _searchController,
              districts: districts,
              selectedDistrict: _selectedDistrict,
              showOnlyOpen24Hours: _showOnlyOpen24Hours,
              onDistrictChanged: (value) {
                if (value == null) return;

                setState(() {
                  _selectedDistrict = value;
                });
              },
              onOpenOnlyChanged: (value) {
                setState(() {
                  _showOnlyOpen24Hours = value ?? false;
                });
              },
              onClearFilters: _clearFilters,
            ),

            const SizedBox(height: 16),

            if (_isLoadingLocation || _isLoadingServices)
              const Padding(
                padding: EdgeInsets.only(bottom: 14),
                child: LinearProgressIndicator(),
              ),

            if (_locationError != null)
              _WarningBox(message: _locationError!),

            if (_serviceError != null)
              _ErrorBox(
                message: _serviceError!,
                onRetry: _loadServices,
              ),

            Row(
              children: [
                Expanded(
                  child: Text(
                    '${serviceList.length} service found',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (_currentPosition != null)
                  const Text(
                    'Sorted by nearest',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 14),

            if (!_isLoadingServices && serviceList.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: Text(
                    'No services found. Try changing search or filter.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

            ...serviceList.map(
                  (service) => ServiceCard(
                service: service,
                distanceKm: _distanceFromUser(service),
                onTap: () => _openDetails(service),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchAndFilterBox extends StatelessWidget {
  final TextEditingController searchController;
  final List<String> districts;
  final String selectedDistrict;
  final bool showOnlyOpen24Hours;
  final ValueChanged<String?> onDistrictChanged;
  final ValueChanged<bool?> onOpenOnlyChanged;
  final VoidCallback onClearFilters;

  const _SearchAndFilterBox({
    required this.searchController,
    required this.districts,
    required this.selectedDistrict,
    required this.showOnlyOpen24Hours,
    required this.onDistrictChanged,
    required this.onOpenOnlyChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search by name, area, address...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: selectedDistrict,
            decoration: InputDecoration(
              labelText: 'District',
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            items: districts
                .map(
                  (district) => DropdownMenuItem(
                value: district,
                child: Text(district),
              ),
            )
                .toList(),
            onChanged: onDistrictChanged,
          ),

          const SizedBox(height: 8),

          CheckboxListTile(
            value: showOnlyOpen24Hours,
            onChanged: onOpenOnlyChanged,
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Show 24-hour services only',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onClearFilters,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Clear filters'),
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningBox extends StatelessWidget {
  final String message;

  const _WarningBox({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF9A3412),
          fontWeight: FontWeight.w700,
        ),
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
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
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