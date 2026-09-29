import 'package:flutter/material.dart';

/// Reusable const spacing dimensions for zero-overhead layout rendering
class AppSpacing {
  AppSpacing._();

  // Vertical SizedBox Spacers
  static const SizedBox v2 = SizedBox(height: 2);
  static const SizedBox v4 = SizedBox(height: 4);
  static const SizedBox v6 = SizedBox(height: 6);
  static const SizedBox v8 = SizedBox(height: 8);
  static const SizedBox v10 = SizedBox(height: 10);
  static const SizedBox v12 = SizedBox(height: 12);
  static const SizedBox v14 = SizedBox(height: 14);
  static const SizedBox v16 = SizedBox(height: 16);
  static const SizedBox v20 = SizedBox(height: 20);
  static const SizedBox v24 = SizedBox(height: 24);
  static const SizedBox v28 = SizedBox(height: 28);
  static const SizedBox v32 = SizedBox(height: 32);
  static const SizedBox v40 = SizedBox(height: 40);
  static const SizedBox v48 = SizedBox(height: 48);

  // Horizontal SizedBox Spacers
  static const SizedBox h2 = SizedBox(width: 2);
  static const SizedBox h4 = SizedBox(width: 4);
  static const SizedBox h6 = SizedBox(width: 6);
  static const SizedBox h8 = SizedBox(width: 8);
  static const SizedBox h10 = SizedBox(width: 10);
  static const SizedBox h12 = SizedBox(width: 12);
  static const SizedBox h16 = SizedBox(width: 16);
  static const SizedBox h20 = SizedBox(width: 20);
  static const SizedBox h24 = SizedBox(width: 24);
  static const SizedBox h32 = SizedBox(width: 32);
}

/// Reusable const EdgeInsets for performance optimization
class AppPaddings {
  AppPaddings._();

  static const EdgeInsets zero = EdgeInsets.zero;
  static const EdgeInsets all4 = EdgeInsets.all(4);
  static const EdgeInsets all6 = EdgeInsets.all(6);
  static const EdgeInsets all8 = EdgeInsets.all(8);
  static const EdgeInsets all10 = EdgeInsets.all(10);
  static const EdgeInsets all12 = EdgeInsets.all(12);
  static const EdgeInsets all14 = EdgeInsets.all(14);
  static const EdgeInsets all16 = EdgeInsets.all(16);
  static const EdgeInsets all20 = EdgeInsets.all(20);
  static const EdgeInsets all24 = EdgeInsets.all(24);

  static const EdgeInsets h8 = EdgeInsets.symmetric(horizontal: 8);
  static const EdgeInsets h12 = EdgeInsets.symmetric(horizontal: 12);
  static const EdgeInsets h16 = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets h20 = EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets h24 = EdgeInsets.symmetric(horizontal: 24);

  static const EdgeInsets v8 = EdgeInsets.symmetric(vertical: 8);
  static const EdgeInsets v12 = EdgeInsets.symmetric(vertical: 12);
  static const EdgeInsets v16 = EdgeInsets.symmetric(vertical: 16);
  static const EdgeInsets v24 = EdgeInsets.symmetric(vertical: 24);

  static const EdgeInsets page = EdgeInsets.all(16);
  static const EdgeInsets card = EdgeInsets.all(16);
  static const EdgeInsets dialog = EdgeInsets.all(24);
  static const EdgeInsets chip = EdgeInsets.symmetric(horizontal: 10, vertical: 5);
}

/// Reusable const BorderRadius
class AppBorderRadii {
  AppBorderRadii._();

  static const BorderRadius r4 = BorderRadius.all(Radius.circular(4));
  static const BorderRadius r6 = BorderRadius.all(Radius.circular(6));
  static const BorderRadius r8 = BorderRadius.all(Radius.circular(8));
  static const BorderRadius r10 = BorderRadius.all(Radius.circular(10));
  static const BorderRadius r12 = BorderRadius.all(Radius.circular(12));
  static const BorderRadius r16 = BorderRadius.all(Radius.circular(16));
  static const BorderRadius r20 = BorderRadius.all(Radius.circular(20));
  static const BorderRadius r24 = BorderRadius.all(Radius.circular(24));
  static const BorderRadius rFull = BorderRadius.all(Radius.circular(999));
}

/// Reusable BoxShadow presets
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get soft => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get elevated => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get card => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
}
