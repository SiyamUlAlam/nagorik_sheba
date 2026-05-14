import 'package:flutter/material.dart';

import '../models/civic_service.dart';
import '../screens/report_issue_screen.dart';
import '../theme/app_theme.dart';
import '../utils/launcher_helper.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final CivicService service;

  const ServiceDetailsScreen({
    super.key,
    required this.service,
  });

  void _openReportScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportIssueScreen(service: service),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasPhone = service.phone != null && service.phone!.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderCard(service: service),

            const SizedBox(height: 22),

            _InfoTile(
              icon: Icons.location_on_rounded,
              title: 'Address',
              value: service.address,
            ),
            _InfoTile(
              icon: Icons.map_rounded,
              title: 'Area',
              value: '${service.area}, ${service.district}',
            ),
            _InfoTile(
              icon: Icons.access_time_rounded,
              title: 'Availability',
              value: service.isOpen24Hours ? 'Open 24 hours' : 'Limited hours',
            ),
            _InfoTile(
              icon: Icons.call_rounded,
              title: 'Phone',
              value: hasPhone ? service.phone! : 'Not available',
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: hasPhone
                    ? () {
                  LauncherHelper.callNumber(context, service.phone);
                }
                    : null,
                icon: const Icon(Icons.call),
                label: const Text('Call Service'),
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

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  LauncherHelper.openMap(
                    context,
                    service.latitude,
                    service.longitude,
                  );
                },
                icon: const Icon(Icons.map_rounded),
                label: const Text('Open in Google Maps'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => _openReportScreen(context),
                icon: const Icon(Icons.report_problem_rounded),
                label: const Text('Report Incorrect Information'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
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

class _HeaderCard extends StatelessWidget {
  final CivicService service;

  const _HeaderCard({
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.business_rounded,
            size: 46,
            color: AppColors.primary,
          ),
          const SizedBox(height: 14),
          Text(
            service.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            service.description,
            style: const TextStyle(
              color: AppColors.muted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
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