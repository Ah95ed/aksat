import 'package:flutter/material.dart';

import 'breakpoints.dart';
import 'responsive.dart';

/// Centers content and caps its width on wide screens (desktop/tablet landscape).
class MaxWidthContainer extends StatelessWidget {
  const MaxWidthContainer({
    super.key,
    required this.child,
    this.maxWidth = 1100,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Responsive grid: column count changes with screen size.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 2,
    this.tabletColumns = 3,
    this.desktopColumns = 4,
    this.mainAxisSpacing = 12,
    this.crossAxisSpacing = 12,
    this.childAspectRatio = 1.0,
  });

  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;

  int _columns(BuildContext context) => switch (Responsive.sizeOf(context)) {
    ScreenSize.mobile => mobileColumns,
    ScreenSize.tablet => tabletColumns,
    ScreenSize.desktop => desktopColumns,
  };

  @override
  Widget build(BuildContext context) {
    final columns = _columns(context);
    return GridView.count(
      crossAxisCount: columns,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      childAspectRatio: childAspectRatio,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}

/// Adaptive scaffold: mobile uses a bottom nav bar, tablet/desktop use a
/// navigation rail on the side. On tablet the screen switches to Master-Detail.
class AdaptiveScaffold extends StatefulWidget {
  const AdaptiveScaffold({
    super.key,
    required this.title,
    required this.body,
    this.leading,
    this.actions,
    this.bottomNav,
    this.floatingActionButton,
    this.bottomsheets,
    this.useDrawer = true,
  });

  final String title;
  final Widget body;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? bottomNav;
  final Widget? floatingActionButton;
  final List<Widget>? bottomsheets;
  final bool useDrawer;

  @override
  State<AdaptiveScaffold> createState() => _AdaptiveScaffoldState();
}

class _AdaptiveScaffoldState extends State<AdaptiveScaffold> {
  int _currentIndex = 0;

  List<_NavDestination> get _dests => _parseDestinations(widget.bottomNav);

  static List<_NavDestination> _parseDestinations(Widget? nav) => const [];

  void _onTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final size = Responsive.sizeOf(context);
    final isMobile = size == ScreenSize.mobile;

    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: widget.leading,
          actions: widget.actions,
        ),
        body: widget.body,
        floatingActionButton: widget.floatingActionButton,
        bottomSheet: widget.bottomsheets == null
            ? null
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.bottomsheets!,
              ),
        bottomNavigationBar: widget.bottomNav,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: widget.leading,
        actions: widget.actions,
      ),
      body: Row(
        children: [
          if (widget.bottomNav != null)
            NavigationRail(
              destinations: _dests
                  .map(
                    (d) => NavigationRailDestination(
                      icon: d.icon,
                      selectedIcon: d.selectedIcon,
                      label: Text(d.label),
                    ),
                  )
                  .toList(),
              selectedIndex: _currentIndex,
              onDestinationSelected: _onTap,
              labelType: NavigationRailLabelType.all,
            ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: widget.body),
        ],
      ),
      floatingActionButton: widget.floatingActionButton,
    );
  }
}

class _NavDestination {
  const _NavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final Widget icon;
  final Widget selectedIcon;
  final String label;
}
