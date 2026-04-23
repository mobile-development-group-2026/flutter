import 'package:flutter/material.dart';
import '../../models/location_alert.dart';

class LocationAlertCard extends StatelessWidget {
  final LocationAlert alert;
  final VoidCallback onMarkAsRead;
  final VoidCallback onVisit;

  const LocationAlertCard({
    super.key,
    required this.alert,
    required this.onMarkAsRead,
    required this.onVisit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: alert.read ? const Color(0xFFF6F7F8) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: alert.read 
                        ? const Color(0xFFE4E7EC) 
                        : const Color(0xFF7B5BF2).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: alert.read 
                        ? const Color(0xFF6E7681) 
                        : const Color(0xFF7B5BF2),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.listingTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: alert.read ? FontWeight.w400 : FontWeight.w600,
                          color: const Color(0xFF212327),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert.address,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6E7681),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (!alert.read)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF7B5BF2),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              alert.message,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF212327),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Detected ${_formatTimeAgo(alert.timestamp)}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFB0B6BF),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onMarkAsRead,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6E7681),
                      side: const BorderSide(color: Color(0xFFE4E7EC)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Mark as Read'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onVisit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B5BF2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Visit Now'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}