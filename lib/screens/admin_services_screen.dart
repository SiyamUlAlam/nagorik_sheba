import 'package:flutter/material.dart';

import '../models/civic_service.dart';
import '../repositories/service_repository.dart';
import '../screens/admin_service_form_screen.dart';
import '../theme/app_theme.dart';

class AdminServicesScreen extends StatefulWidget {
  const AdminServicesScreen({super.key});

  @override
  State<AdminServicesScreen> createState() => _AdminServicesScreenState();
}

class _AdminServicesScreenState extends State<AdminServicesScreen> {
  final ServiceRepository _repository = ServiceRepository();

  bool _isLoading = true;
  String? _error;
  List<CivicService> _services = [];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final List<CivicService> services =
      await _repository.getAllServicesForAdmin();

      setState(() {
        _services = services;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _error = 'Could not load services: $error';
      });
    }
  }

  Future<void> _openServiceForm({CivicService? service}) async {
    final bool? changed = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminServiceFormScreen(service: service),
      ),
    );

    if (changed == true) {
      await _loadServices();
    }
  }

  Future<void> _toggleActive(CivicService service) async {
    try {
      await _repository.toggleServiceActive(
        serviceId: service.id,
        isActive: !service.isActive,
      );

      await _loadServices();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            service.isActive
                ? 'Service deactivated.'
                : 'Service activated.',
          ),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not update service: $error'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Color _statusColor(bool isActive) {
    return isActive ? AppColors.primary : AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final int activeCount =
        _services.where((service) => service.isActive).length;
    final int inactiveCount = _services.length - activeCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Services'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openServiceForm(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Service'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadServices,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.business_rounded,
                    color: AppColors.primary,
                    size: 40,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      '${_services.length} total services\n$activeCount active, $inactiveCount inactive',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 30),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),

            if (_error != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: Color(0xFF991B1B),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _loadServices,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),

            if (!_isLoading && _services.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(
                  child: Text(
                    'No services added yet.',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

            ..._services.map(
                  (service) {
                return Card(
                  color: AppColors.card,
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: _statusColor(service.isActive)
                                    .withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                service.isActive ? 'ACTIVE' : 'INACTIVE',
                                style: TextStyle(
                                  color: _statusColor(service.isActive),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Text(
                          serviceCategoryLabel(service.category),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
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
                          '${service.area}, ${service.district}',
                          style: const TextStyle(
                            color: AppColors.muted,
                          ),
                        ),

                        const SizedBox(height: 14),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () =>
                                  _openServiceForm(service: service),
                              icon: const Icon(Icons.edit_rounded),
                              label: const Text('Edit'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _toggleActive(service),
                              icon: Icon(
                                service.isActive
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                              ),
                              label: Text(
                                service.isActive ? 'Deactivate' : 'Activate',
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: service.isActive
                                    ? AppColors.danger
                                    : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}