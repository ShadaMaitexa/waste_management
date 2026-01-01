import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'responsive_layout.dart';

class ResponsiveScaffold extends StatelessWidget {
  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Color? backgroundColor;

  const ResponsiveScaffold({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    this.title,
    this.actions,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppTheme.grey50,
      appBar: (ResponsiveLayout.isMobile(context) && title != null)
          ? AppBar(
              title: Text(title!),
              actions: actions,
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            )
          : null, // No AppBar on desktop if using sidebar usually, or keep it.
                  // For this app, screens have their own SliverAppBars, so we might want to hide THIS AppBar usually.
                  // Actually, let's keep it flexible. If title is passed, show it (mostly for mobile simple screens).

      body: Row(
        children: [
          if (!ResponsiveLayout.isMobile(context))
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              backgroundColor: Colors.white,
              selectedIconTheme: const IconThemeData(color: AppTheme.primaryGreen),
              selectedLabelTextStyle: const TextStyle(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelTextStyle: const TextStyle(
                color: AppTheme.grey600,
              ),
              elevation: 5,
              destinations: destinations.map((d) {
                return NavigationRailDestination(
                  icon: d.icon,
                  selectedIcon: d.selectedIcon,
                  label: Text(d.label),
                );
              }).toList(),
            ),
          if (!ResponsiveLayout.isMobile(context))
            const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: body, // The screen content
          ),
        ],
      ),
      bottomNavigationBar: ResponsiveLayout.isMobile(context)
          ? NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              backgroundColor: Colors.white,
              indicatorColor: AppTheme.primaryGreen.withOpacity(0.1),
              destinations: destinations,
            )
          : null,
    );
  }
}
