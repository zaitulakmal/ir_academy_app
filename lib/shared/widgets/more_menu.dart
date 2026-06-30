import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';

class MoreMenuItem {
  final String label;
  final IconData icon;
  final Widget? screen;
  final String? url;

  const MoreMenuItem({required this.label, required this.icon, this.screen, this.url})
      : assert(screen != null || url != null, 'Provide either screen or url');
}

class MoreMenuScreen extends StatelessWidget {
  final List<MoreMenuItem> items;

  const MoreMenuScreen({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              if (item.url != null) {
                final uri = Uri.parse(item.url!);
                if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => item.screen!),
                );
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, color: AppColors.primary, size: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
