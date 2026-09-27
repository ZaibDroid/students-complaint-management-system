import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Priority of a complaint
enum PriorityLevel {
  low,
  medium,
  high,
  urgent;

  String get displayName {
    switch (this) {
      case PriorityLevel.low:
        return 'Low';
      case PriorityLevel.medium:
        return 'Medium';
      case PriorityLevel.high:
        return 'High';
      case PriorityLevel.urgent:
        return 'Urgent';
    }
  }

  String get value => name;

  Color get color {
    switch (this) {
      case PriorityLevel.low:
        return AppColors.priorityLow;
      case PriorityLevel.medium:
        return AppColors.priorityMedium;
      case PriorityLevel.high:
        return AppColors.priorityHigh;
      case PriorityLevel.urgent:
        return AppColors.priorityUrgent;
    }
  }

  static PriorityLevel fromString(String? priority) {
    if (priority == null) return PriorityLevel.medium;
    switch (priority.toLowerCase()) {
      case 'low':
        return PriorityLevel.low;
      case 'high':
        return PriorityLevel.high;
      case 'urgent':
        return PriorityLevel.urgent;
      case 'medium':
      default:
        return PriorityLevel.medium;
    }
  }
}
