import 'package:flutter/material.dart';

class NavItem extends StatelessWidget {
  final double size;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const NavItem({
    super.key,
    required this.size,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;
    final bg = selected ? colors.primary : Colors.transparent;
    final fg = selected
        ? (isDark ? Colors.black : Colors.white)
        : (isDark ? Colors.white : Colors.black);

    return GestureDetector(
      behavior: HitTestBehavior.opaque, // keeps tap area generous
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
        alignment: Alignment.center,
        child: Icon(icon, color: fg),
      ),
    );
  }
}
