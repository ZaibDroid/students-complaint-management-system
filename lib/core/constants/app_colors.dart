import 'package:flutter/material.dart';

/// App-wide Color Palette for DCMS (Department Complaint Management System)
/// Branding: Primary #172548, Clean, Modern, Bright, Minimal, Professional
class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF172548);
  static const Color primaryLight = Color(0xFF223769);
  static const Color primaryDark = Color(0xFF0F182E);
  static const Color primarySurface = Color(0xFFF0F4FA);

  // Secondary & Accents
  static const Color secondary = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFF2563EB);
  static const Color accentLight = Color(0xFF60A5FA);

  // Neutral Colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFE2E8F0);

  // Status & Workflow Colors
  static const Color statusPending = Color(0xFFF59E0B);      // Amber
  static const Color statusPendingLight = Color(0xFFFEF3C7);
  
  static const Color statusForwarded = Color(0xFF3B82F6);    // Blue
  static const Color statusForwardedLight = Color(0xFFDBEAFE);

  static const Color statusInReview = Color(0xFF8B5CF6);     // Purple
  static const Color statusInReviewLight = Color(0xFFEDE9FE);

  static const Color statusResolved = Color(0xFF10B981);     // Emerald Green
  static const Color statusResolvedLight = Color(0xFFD1FAE5);

  static const Color statusRejected = Color(0xFFEF4444);     // Crimson Red
  static const Color statusRejectedLight = Color(0xFFFEE2E2);

  static const Color statusReturned = Color(0xFFEC4899);     // Pink / Orange
  static const Color statusReturnedLight = Color(0xFFFCE7F3);

  // Priority Colors
  static const Color priorityLow = Color(0xFF10B981);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityHigh = Color(0xFFF97316);
  static const Color priorityUrgent = Color(0xFFEF4444);

  // Additional Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF172548), Color(0xFF273E73)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
  );
}
