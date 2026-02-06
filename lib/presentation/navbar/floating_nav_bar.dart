import 'package:firefly_books/presentation/navbar/nav_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FloatingBottomNavBar extends StatelessWidget {
  final double height;
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const FloatingBottomNavBar({
    super.key,
    required this.height,
    required this.currentIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const double itemSize = 48; // circle size

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: height,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: colors.secondary,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, // <-- no full width
            children: [
              NavItem(
                size: itemSize,
                icon: currentIndex == 0
                    ? CupertinoIcons.book_fill
                    : CupertinoIcons.book,
                selected: currentIndex == 0,
                onTap: () => onChanged(0),
              ),
              const SizedBox(width: 20),

              NavItem(
                size: itemSize,
                icon: currentIndex == 1
                    ? CupertinoIcons.heart_fill
                    : CupertinoIcons.heart,
                selected: currentIndex == 1,
                onTap: () => onChanged(1),
              ),
              const SizedBox(width: 20),

              NavItem(
                size: itemSize,
                icon: currentIndex == 2
                    ? CupertinoIcons.time_solid
                    : CupertinoIcons.time,
                selected: currentIndex == 2,
                onTap: () => onChanged(2),
              ),
              const SizedBox(width: 20),

              NavItem(
                size: itemSize,
                icon: currentIndex == 3
                    ? CupertinoIcons.gear_solid
                    : CupertinoIcons.gear,
                selected: currentIndex == 3,
                onTap: () => onChanged(3),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}
