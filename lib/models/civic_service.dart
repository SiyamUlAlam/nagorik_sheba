enum ServiceCategory {
  hospital,
  police,
  fire,
  ambulance,
  pharmacy,
  govt,
}

ServiceCategory serviceCategoryFromString(String value) {
  switch (value) {
    case 'hospital':
      return ServiceCategory.hospital;
    case 'police':
      return ServiceCategory.police;
    case 'fire':
      return ServiceCategory.fire;
    case 'ambulance':
      return ServiceCategory.ambulance;
    case 'pharmacy':
      return ServiceCategory.pharmacy;
    case 'govt':
      return ServiceCategory.govt;
    default:
      return ServiceCategory.hospital;
  }
}

String serviceCategoryToString(ServiceCategory category) {
  switch (category) {
    case ServiceCategory.hospital:
      return 'hospital';
    case ServiceCategory.police:
      return 'police';
    case ServiceCategory.fire:
      return 'fire';
    case ServiceCategory.ambulance:
      return 'ambulance';
    case ServiceCategory.pharmacy:
      return 'pharmacy';
    case ServiceCategory.govt:
      return 'govt';
  }
}

String serviceCategoryLabel(ServiceCategory category) {
  switch (category) {
    case ServiceCategory.hospital:
      return 'Hospital';
    case ServiceCategory.police:
      return 'Police';
    case ServiceCategory.fire:
      return 'Fire Service';
    case ServiceCategory.ambulance:
      return 'Ambulance';
    case ServiceCategory.pharmacy:
      return 'Pharmacy';
    case ServiceCategory.govt:
      return 'Govt. Office';
  }
}

class CivicService {
  final String id;
  final String name;
  final ServiceCategory category;
  final String address;
  final String area;
  final String district;
  final String? phone;
  final double latitude;
  final double longitude;
  final bool isOpen24Hours;
  final String description;
  final bool isActive;

  const CivicService({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.area,
    required this.district,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.isOpen24Hours,
    required this.description,
    this.isActive = true,
  });

  factory CivicService.fromMap(Map<String, dynamic> map) {
    return CivicService(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      category: serviceCategoryFromString(map['category']?.toString() ?? ''),
      address: map['address']?.toString() ?? '',
      area: map['area']?.toString() ?? '',
      district: map['district']?.toString() ?? '',
      phone: map['phone']?.toString(),
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
      isOpen24Hours: map['is_open_24_hours'] == true,
      description: map['description']?.toString() ?? '',
      isActive: map['is_active'] != false,
    );
  }
}