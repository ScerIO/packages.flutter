import 'dart:ui';

extension ColorUtils on Color {
  Color mix(Color another, double amount) => Color.lerp(this, another, amount);
}
