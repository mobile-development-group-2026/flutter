import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/gps_viewmodel.dart';
import '../widgets/location_alert_card.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCFCFD),
        elevation: 0,
        title: const Text(
          'Nearby Alerts',
          style: TextStyle(
            color: Color(0xFF212327),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer<GPSViewModel>(
            builder: (context, viewModel, child) {
              return IconButton(
                icon: Icon(
                  viewModel.isListening ? Icons.location_on : Icons.location_off,
                  color: viewModel.isListening 
                      ? const Color(0xFF7B5BF2) 
                      : const Color(0xFF6E7681),
                ),
                onPressed: () {
                  if (viewModel.isListening) {
                    viewModel.stopLocationMonitoring();
                  } else {
                    if (viewModel.permissionsGranted) {
                      viewModel.startLocationMonitoring();
                    } else {
                      _showPermissionDialog(context);
                    }
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<GPSViewModel>(
        builder: (context, viewModel, child) {
          if (!viewModel.permissionsGranted) {
            return _buildPermissionRequest(context, viewModel);
          }

          if (!viewModel.isListening) {
            return _buildStartMonitoring(context, viewModel);
          }

          if (viewModel.alerts.isEmpty) {
            return _buildEmptyState();
          }

          return _buildAlertsList(viewModel);
        },
      ),
    );
  }

  Widget _buildPermissionRequest(BuildContext context, GPSViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF7B5BF2).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_disabled,
                size: 60,
                color: Color(0xFF7B5BF2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Location Access Needed',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212327),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'To get alerts when you\'re near saved listings, we need access to your location.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6E7681),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                bool granted = await viewModel.requestPermissions();
                if (granted) {
                  viewModel.startLocationMonitoring();
                  await viewModel.loadSavedListings();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B5BF2),
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Grant Permission'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartMonitoring(BuildContext context, GPSViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFE4E7EC).withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_searching,
              size: 60,
              color: Color(0xFF6E7681),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Start Monitoring',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212327),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Enable location monitoring to get alerts when you\'re near your saved listings.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6E7681),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              viewModel.startLocationMonitoring();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7B5BF2),
              foregroundColor: Colors.white,
              minimumSize: const Size(200, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFE4E7EC).withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none,
              size: 60,
              color: Color(0xFF6E7681),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Nearby Listings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212327),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'You\'ll get alerts here when you\'re close to one of your saved listings.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6E7681),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsList(GPSViewModel viewModel) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.alerts.length,
      itemBuilder: (context, index) {
        final alert = viewModel.alerts[index];
        return LocationAlertCard(
          alert: alert,
          onMarkAsRead: () => viewModel.markAlertAsRead(alert.id),
          onVisit: () => viewModel.markListingAsVisited(alert.listingId),
        );
      },
    );
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
          'This feature needs location permissions to work. Please grant access in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF7B5BF2),
            ),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}