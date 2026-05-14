import 'package:flutter/material.dart';
import '../models/civic_service.dart';
import '../theme/app_theme.dart';

class ServiceCard extends StatelessWidget {
  final CivicService service;
  final double? distanceKm;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.service,
    required this.onTap,
    this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
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
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  if (distanceKm != null)
                    Text(
                      '${distanceKm!.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                service.address,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(
                    service.isOpen24Hours
                        ? Icons.check_circle
                        : Icons.schedule,
                    size: 18,
                    color: service.isOpen24Hours
                        ? AppColors.primary
                        : AppColors.muted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    service.isOpen24Hours
                        ? 'Open 24 hours'
                        : 'Limited hours',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: service.isOpen24Hours
                          ? AppColors.primary
                          : AppColors.muted,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'View details',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
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