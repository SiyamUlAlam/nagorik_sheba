import 'package:flutter/material.dart';

import '../models/civic_service.dart';
import '../repositories/service_repository.dart';
import '../theme/app_theme.dart';

class AdminServiceFormScreen extends StatefulWidget {
  final CivicService? service;

  const AdminServiceFormScreen({
    super.key,
    this.service,
  });

  @override
  State<AdminServiceFormScreen> createState() => _AdminServiceFormScreenState();
}

class _AdminServiceFormScreenState extends State<AdminServiceFormScreen> {
  final ServiceRepository _repository = ServiceRepository();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  ServiceCategory _selectedCategory = ServiceCategory.hospital;
  bool _isOpen24Hours = true;
  bool _isActive = true;
  bool _isSaving = false;

  bool get _isEditing => widget.service != null;

  @override
  void initState() {
    super.initState();

    final CivicService? service = widget.service;

    if (service != null) {
      _nameController.text = service.name;
      _addressController.text = service.address;
      _areaController.text = service.area;
      _districtController.text = service.district;
      _phoneController.text = service.phone ?? '';
      _latitudeController.text = service.latitude.toString();
      _longitudeController.text = service.longitude.toString();
      _descriptionController.text = service.description;
      _selectedCategory = service.category;
      _isOpen24Hours = service.isOpen24Hours;
      _isActive = service.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _areaController.dispose();
    _districtController.dispose();
    _phoneController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required.';
    }

    return null;
  }

  String? _numberValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required.';
    }

    final double? number = double.tryParse(value.trim());

    if (number == null) {
      return 'Enter a valid number.';
    }

    return null;
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) return;

    final double latitude = double.parse(_latitudeController.text.trim());
    final double longitude = double.parse(_longitudeController.text.trim());

    setState(() {
      _isSaving = true;
    });

    try {
      if (_isEditing) {
        await _repository.updateService(
          serviceId: widget.service!.id,
          name: _nameController.text.trim(),
          category: _selectedCategory,
          address: _addressController.text.trim(),
          area: _areaController.text.trim(),
          district: _districtController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          latitude: latitude,
          longitude: longitude,
          isOpen24Hours: _isOpen24Hours,
          description: _descriptionController.text.trim(),
          isActive: _isActive,
        );
      } else {
        await _repository.createService(
          name: _nameController.text.trim(),
          category: _selectedCategory,
          address: _addressController.text.trim(),
          area: _areaController.text.trim(),
          district: _districtController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          latitude: latitude,
          longitude: longitude,
          isOpen24Hours: _isOpen24Hours,
          description: _descriptionController.text.trim(),
          isActive: _isActive,
        );
      }

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Service updated successfully.'
                : 'Service added successfully.',
          ),
          backgroundColor: AppColors.primary,
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save service: $error'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Service' : 'Add Service'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              _SectionCard(
                title: 'Basic Information',
                children: [
                  TextFormField(
                    controller: _nameController,
                    validator: _requiredValidator,
                    decoration: _inputDecoration(
                      label: 'Service name',
                      icon: Icons.business_rounded,
                    ),
                  ),

                  const SizedBox(height: 14),

                  DropdownButtonFormField<ServiceCategory>(
                    value: _selectedCategory,
                    decoration: _inputDecoration(
                      label: 'Category',
                      icon: Icons.category_rounded,
                    ),
                    items: ServiceCategory.values
                        .map(
                          (category) => DropdownMenuItem(
                        value: category,
                        child: Text(serviceCategoryLabel(category)),
                      ),
                    )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _descriptionController,
                    validator: _requiredValidator,
                    maxLines: 4,
                    decoration: _inputDecoration(
                      label: 'Description',
                      icon: Icons.description_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _SectionCard(
                title: 'Location Information',
                children: [
                  TextFormField(
                    controller: _addressController,
                    validator: _requiredValidator,
                    decoration: _inputDecoration(
                      label: 'Address',
                      icon: Icons.location_on_rounded,
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _areaController,
                    validator: _requiredValidator,
                    decoration: _inputDecoration(
                      label: 'Area',
                      icon: Icons.map_rounded,
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _districtController,
                    validator: _requiredValidator,
                    decoration: _inputDecoration(
                      label: 'District',
                      icon: Icons.location_city_rounded,
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _latitudeController,
                    validator: _numberValidator,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    decoration: _inputDecoration(
                      label: 'Latitude',
                      icon: Icons.my_location_rounded,
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _longitudeController,
                    validator: _numberValidator,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    decoration: _inputDecoration(
                      label: 'Longitude',
                      icon: Icons.explore_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _SectionCard(
                title: 'Contact and Status',
                children: [
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration(
                      label: 'Phone, optional',
                      icon: Icons.call_rounded,
                    ),
                  ),

                  const SizedBox(height: 8),

                  SwitchListTile(
                    value: _isOpen24Hours,
                    onChanged: (value) {
                      setState(() {
                        _isOpen24Hours = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Open 24 hours',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                  ),

                  SwitchListTile(
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Active in user app',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    subtitle: const Text(
                      'Inactive services will not appear for normal users.',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveService,
                  icon: _isSaving
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    _isSaving
                        ? 'Saving...'
                        : _isEditing
                        ? 'Update Service'
                        : 'Add Service',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.muted,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}