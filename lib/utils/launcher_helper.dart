import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LauncherHelper {
  static Future<void> callNumber(BuildContext context, String? phone) async {
    if (phone == null || phone.trim().isEmpty) {
      _showMessage(context, 'Phone number is not available.');
      return;
    }

    final Uri uri = Uri(scheme: 'tel', path: phone);

    try {
      final bool canLaunch = await canLaunchUrl(uri);

      if (!canLaunch) {
        _showMessage(context, 'This device cannot open the phone dialer.');
        return;
      }

      await launchUrl(uri);
    } catch (error) {
      _showMessage(context, 'Could not open the phone dialer.');
    }
  }

  static Future<void> openMap(
      BuildContext context,
      double latitude,
      double longitude,
      ) async {
    final Uri uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    try {
      final bool canLaunch = await canLaunchUrl(uri);

      if (!canLaunch) {
        _showMessage(context, 'Map app is not available.');
        return;
      }

      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (error) {
      _showMessage(context, 'Could not open map.');
    }
  }

  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}