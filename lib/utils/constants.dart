import 'package:flutter/material.dart';

class AppConstants {
  // Cores principais
  static const int backgroundColorValue = 0xFF1A1A1A;
  static const int surfaceColorValue = 0xFF2A2A2A;
  static const int primaryColorValue = 0xFFE53E3E;
  static const int textColorValue = 0xFFFFFFFF;

  // Cores de ranking
  static const int goldColorValue = 0xFFFFD700;
  static const int silverColorValue = 0xFFFF8C00;
  static const int bronzeColorValue = 0xFFCD853F;

  // Tamanhos
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 16.0;
  static const double cardRadius = 12.0;

  // Textos
  static const String appName = "Comentarista";
  static const String appVersion = "1.0.0";
}

class AppColors {
  static const Color backgroundColor = Color(AppConstants.backgroundColorValue);
  static const Color surfaceColor = Color(AppConstants.surfaceColorValue);
  static const Color primaryColor = Color(AppConstants.primaryColorValue);
  static const Color textColor = Color(AppConstants.textColorValue);
  static const Color goldColor = Color(AppConstants.goldColorValue);
  static const Color silverColor = Color(AppConstants.silverColorValue);
  static const Color bronzeColor = Color(AppConstants.bronzeColorValue);
}
