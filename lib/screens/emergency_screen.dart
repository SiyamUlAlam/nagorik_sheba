import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/launcher_helper.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_EmergencyItem> items = [
      const _EmergencyItem(
        title: 'National Emergency Service',
        subtitle: 'Police, Fire Service, Ambulance',
        phone: '999',
        icon: Icons.emergency_rounded,
        color: AppColors.danger,
      ),
      const _EmergencyItem(
        title: 'Citizen Service Helpline',
        subtitle: 'Government information and citizen support',
        phone: '333',
        icon: Icons.support_agent_rounded,
        color: AppColors.primary,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Support'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          return Card(
            color: AppColors.card,
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    item.icon,
                    size: 42,
                    color: item.color,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        LauncherHelper.callNumber(context, item.phone);
                      },
                      icon: const Icon(Icons.call),
                      label: Text('Call ${item.phone}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: item.color,
                        foregroundColor: Colors.white,
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
          );
        },
      ),
    );
  }
}

class _EmergencyItem {
  final String title;
  final String subtitle;
  final String phone;
  final IconData icon;
  final Color color;

  const _EmergencyItem({
    required this.title,
    required this.subtitle,
    required this.phone,
    required this.icon,
    required this.color,
  });
}