import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThemeSelector extends StatelessWidget {
  final ThemeMode selected;
  final ValueChanged<ThemeMode> onChanged;

  const ThemeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ThemeOption(
          icon: CupertinoIcons.device_phone_portrait,
          label: 'System',
          isSelected: selected == ThemeMode.system,
          onTap: () => onChanged(ThemeMode.system),
        ),
        _ThemeOption(
          icon: CupertinoIcons.sun_max,
          label: 'Light',
          isSelected: selected == ThemeMode.light,
          onTap: () => onChanged(ThemeMode.light),
        ),
        _ThemeOption(
          icon: CupertinoIcons.moon,
          label: 'Dark',
          isSelected: selected == ThemeMode.dark,
          onTap: () => onChanged(ThemeMode.dark),
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
