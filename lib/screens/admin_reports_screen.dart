import 'package:flutter/material.dart';

import '../models/service_report.dart';
import '../repositories/service_repository.dart';
import '../theme/app_theme.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final ServiceRepository _repository = ServiceRepository();

  bool _isLoading = true;
  String? _error;
  List<ServiceReport> _reports = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final List<ServiceReport> reports =
      await _repository.getServiceReports();

      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _error = 'Could not load reports: $error';
      });
    }
  }

  Future<void> _changeStatus(ServiceReport report, String status) async {
    try {
      await _repository.updateReportStatus(
        reportId: report.id,
        status: status,
      );

      await _loadReports();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report marked as $status.'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not update report: $error'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'resolved':
        return AppColors.primary;
      case 'reviewed':
        return Colors.orange;
      case 'rejected':
        return AppColors.danger;
      default:
        return AppColors.muted;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown date';

    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final int pendingCount =
        _reports.where((report) => report.status == 'pending').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Reports'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadReports,
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
                    Icons.analytics_rounded,
                    color: AppColors.primary,
                    size: 38,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      '${_reports.length} total reports\n$pendingCount pending review',
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
                padding: EdgeInsets.only(top: 20),
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
                      onPressed: _loadReports,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),

            if (!_isLoading && _reports.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(
                  child: Text(
                    'No reports submitted yet.',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

            ..._reports.map(
                  (report) {
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
                                report.serviceName,
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
                                color: _statusColor(report.status)
                                    .withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                report.status.toUpperCase(),
                                style: TextStyle(
                                  color: _statusColor(report.status),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Text(
                          report.issueType,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          report.issueDescription,
                          style: const TextStyle(
                            color: AppColors.text,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'Reporter: ${report.reporterName?.isNotEmpty == true ? report.reporterName : 'Not provided'}',
                          style: const TextStyle(
                            color: AppColors.muted,
                          ),
                        ),

                        Text(
                          'Phone: ${report.reporterPhone?.isNotEmpty == true ? report.reporterPhone : 'Not provided'}',
                          style: const TextStyle(
                            color: AppColors.muted,
                          ),
                        ),

                        Text(
                          'Date: ${_formatDate(report.createdAt)}',
                          style: const TextStyle(
                            color: AppColors.muted,
                          ),
                        ),

                        const SizedBox(height: 14),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton(
                              onPressed: () =>
                                  _changeStatus(report, 'reviewed'),
                              child: const Text('Reviewed'),
                            ),
                            OutlinedButton(
                              onPressed: () =>
                                  _changeStatus(report, 'resolved'),
                              child: const Text('Resolved'),
                            ),
                            OutlinedButton(
                              onPressed: () =>
                                  _changeStatus(report, 'rejected'),
                              child: const Text('Reject'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}