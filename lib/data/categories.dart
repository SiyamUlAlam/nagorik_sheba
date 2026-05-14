import '../models/civic_service.dart';

class CategoryItem {
  final ServiceCategory category;
  final String title;
  final String subtitle;
  final String icon;

  const CategoryItem({
    required this.category,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

const List<CategoryItem> categories = [
  CategoryItem(
    category: ServiceCategory.hospital,
    title: 'Hospitals',
    subtitle: 'Find nearby hospitals',
    icon: '🏥',
  ),
  CategoryItem(
    category: ServiceCategory.police,
    title: 'Police',
    subtitle: 'Find nearby police stations',
    icon: '👮',
  ),
  CategoryItem(
    category: ServiceCategory.fire,
    title: 'Fire Service',
    subtitle: 'Emergency fire support',
    icon: '🚒',
  ),
  CategoryItem(
    category: ServiceCategory.ambulance,
    title: 'Ambulance',
    subtitle: 'Quick ambulance support',
    icon: '🚑',
  ),
  CategoryItem(
    category: ServiceCategory.pharmacy,
    title: 'Pharmacy',
    subtitle: 'Nearby medicine shops',
    icon: '💊',
  ),
  CategoryItem(
    category: ServiceCategory.govt,
    title: 'Govt. Offices',
    subtitle: 'Citizen service offices',
    icon: '🏛️',
  ),
];

String getCategoryTitle(ServiceCategory category) {
  return categories
      .firstWhere((item) => item.category == category)
      .title;
}