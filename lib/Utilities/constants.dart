import 'package:flutter/material.dart';

/// App-wide constants for MedTrack application

const String appName = 'MedTrack';
const String appVersion = '1.0.0';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color primaryLight = Color(0xFF60A5FA);

  // Status Colors
  static const Color good = Color(0xFF10B981);       // Green - Good medicine
  static const Color expiring = Color(0xFFF59E0B);   // Amber - Expiring soon
  static const Color expired = Color(0xFFEF4444);    // Red - Expired
  static const Color info = Color(0xFF3B82F6);       // Blue - Information

  // Neutral Colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);

  // Border & Dividers
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);

  // Dark Mode Palette
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCardBg = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF334155);

  static const Color transparent = Color(0x00000000);
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
}

class AppConstants {
  static const int expiryWarningDays = 30;
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration searchDebounceDuration = Duration(milliseconds: 400);
}

class AppStrings {
  static const String appTitle = 'MedTrack';
  static const String appSubtitle = 'Smart Medicine Expiry Reminders';

  static const String loginTitle = 'Welcome Back';
  static const String loginSubtitle = 'Sign in to continue managing your medicines.';
  static const String registerTitle = 'Create Account';
  static const String registerSubtitle = 'Join MedTrack to track medicine expiry.';

  static const String statusGood = 'Good';
  static const String statusExpiring = 'Expiring Soon';
  static const String statusExpired = 'Expired';

  static const String filterAll = 'All';
  static const String filterGood = 'Good';
  static const String filterExpiring = 'Expiring';
  static const String filterExpired = 'Expired';
}