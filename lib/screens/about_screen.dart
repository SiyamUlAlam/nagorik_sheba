import 'package:flutter/material.dart';

import '../screens/admin_login_screen.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _openAdminLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminLoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_city_rounded,
                    color: Colors.white,
                    size: 50,
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Nagorik Sheba',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'A centralised civic service mobile application for Bangladesh.',
                    style: TextStyle(
                      color: Color(0xFFE0F2F1),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            const _InfoSection(
              title: 'Project Objective',
              icon: Icons.flag_rounded,
              description:
              'Nagorik Sheba helps citizens quickly find nearby essential civic services such as hospitals, police stations, fire service, ambulance support, pharmacies, and government offices.',
            ),

            const _InfoSection(
              title: 'Key Features',
              icon: Icons.star_rounded,
              description:
              'The app includes emergency calling, category-wise service browsing, search and filter, nearby map view, service details, incorrect information reporting, and admin management.',
            ),

            const _InfoSection(
              title: 'Data Reliability',
              icon: Icons.verified_rounded,
              description:
              'Users can report incorrect service information, and admins can review reports, update services, and activate or deactivate outdated information.',
            ),

            const _InfoSection(
              title: 'Technology Used',
              icon: Icons.code_rounded,
              description:
              'Flutter is used for the mobile application, Supabase is used for database and admin authentication, and OpenStreetMap is used for the free map view.',
            ),

            const _InfoSection(
              title: 'Limitations',
              icon: Icons.warning_rounded,
              description:
              'The current version is a prototype. Service data must be verified before real public use. The map uses free OpenStreetMap tiles, which are suitable for demo and academic use but need a dedicated provider for large-scale production.',
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.admin_panel_settings_rounded,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Admin Access',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Admin panel is used to review reports and manage civic service information.',
                    style: TextStyle(
                      color: AppColors.muted,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _openAdminLogin(context),
                      icon: const Icon(Icons.login_rounded),
                      label: const Text('Admin Login'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            const Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;

  const _InfoSection({
    required this.title,
    required this.icon,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFCCFBF1),
            child: Icon(
              icon,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
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

                const SizedBox(height: 6),

                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.muted,
                    height: 1.5,
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