import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      // Primary colors
      primary: Color.fromString("{brand-primary-500}"),
      surfaceTint: Color.fromString("{brand-primary-400}"),
      onPrimary: Color.fromString("{brand-primary-100}"),
      primaryContainer: Color.fromString("{brand-primary-300}"),
      onPrimaryContainer: Color.fromString("{brand-primary-900}"),
      // Secondary colors
      secondary: Color.fromString("{brand-secondary-500}"),
      onSecondary: Color.fromString("{brand-secondary-100}"),
      secondaryContainer: Color.fromString("{brand-secondary-300}"),
      onSecondaryContainer: Color.fromString("{brand-secondary-900}"),
      // Error colors
      error: Color.fromString("{brand-error-500}"),
      onError: Color.fromString("{brand-error-100}"),
      errorContainer: Color.fromString("{brand-error-300}"),
      onErrorContainer: Color.fromString("{brand-error-900}"),
      // Surface colors
      surface: Color.fromString("{brand-primary-100}"),
      onSurface: Color.fromString("{brand-primary-900}"),
      surfaceVariant: Color.fromString("{brand-primary-200}"),
      onSurfaceVariant: Color.fromString("{brand-primary-800}"),
      // Outline colors
      outline: Color.fromString("{brand-primary-400}"),
      outlineVariant: Color.fromString("{brand-primary-300}"),
      // Shadow and scrim
      shadow: Color.fromString("{brand-primary-900}"),
      scrim: Color.fromString("{brand-primary-900}"),
      // Inverse colors
      inverseSurface: Color.fromString("{brand-primary-800}"),
      onInverseSurface: Color.fromString("{brand-primary-100}"),
      inversePrimary: Color.fromString("{brand-primary-200}"),
      // Fixed colors
      primaryFixed: Color.fromString("{brand-primary-500}"),
      onPrimaryFixed: Color.fromString("{brand-primary-100}"),
      primaryFixedDim: Color.fromString("{brand-primary-400}"),
      onPrimaryFixedVariant: Color.fromString("{brand-primary-800}"),
      secondaryFixed: Color.fromString("{brand-secondary-500}"),
      onSecondaryFixed: Color.fromString("{brand-secondary-100}"),
      secondaryFixedDim: Color.fromString("{brand-secondary-400}"),
      onSecondaryFixedVariant: Color.fromString("{brand-secondary-800}"),
      // Surface containers
      surfaceDim: Color.fromString("{brand-primary-200}"),
      surfaceBright: Color.fromString("{brand-primary-100}"),
      surfaceContainerLowest: Color.fromString("{brand-primary-100}"),
      surfaceContainerLow: Color.fromString("{brand-primary-200}"),
      surfaceContainer: Color.fromString("{brand-primary-300}"),
      surfaceContainerHigh: Color.fromString("{brand-primary-400}"),
      surfaceContainerHighest: Color.fromString("{brand-primary-500}"),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      // Primary colors
      primary: Color.fromString("{brand-primary-400}"),
      surfaceTint: Color.fromString("{brand-primary-500}"),
      onPrimary: Color.fromString("{brand-primary-900}"),
      primaryContainer: Color.fromString("{brand-primary-700}"),
      onPrimaryContainer: Color.fromString("{brand-primary-100}"),
      // Secondary colors
      secondary: Color.fromString("{brand-secondary-400}"),
      onSecondary: Color.fromString("{brand-secondary-900}"),
      secondaryContainer: Color.fromString("{brand-secondary-700}"),
      onSecondaryContainer: Color.fromString("{brand-secondary-100}"),
      // Error colors
      error: Color.fromString("{brand-error-400}"),
      onError: Color.fromString("{brand-error-900}"),
      errorContainer: Color.fromString("{brand-error-700}"),
      onErrorContainer: Color.fromString("{brand-error-100}"),
      // Surface colors
      surface: Color.fromString("{brand-primary-900}"),
      onSurface: Color.fromString("{brand-primary-100}"),
      surfaceVariant: Color.fromString("{brand-primary-800}"),
      onSurfaceVariant: Color.fromString("{brand-primary-200}"),
      // Outline colors
      outline: Color.fromString("{brand-primary-600}"),
      outlineVariant: Color.fromString("{brand-primary-700}"),
      // Shadow and scrim
      shadow: Color.fromString("{brand-primary-900}"),
      scrim: Color.fromString("{brand-primary-900}"),
      // Inverse colors
      inverseSurface: Color.fromString("{brand-primary-200}"),
      onInverseSurface: Color.fromString("{brand-primary-900}"),
      inversePrimary: Color.fromString("{brand-primary-800}"),
      // Fixed colors
      primaryFixed: Color.fromString("{brand-primary-400}"),
      onPrimaryFixed: Color.fromString("{brand-primary-900}"),
      primaryFixedDim: Color.fromString("{brand-primary-500}"),
      onPrimaryFixedVariant: Color.fromString("{brand-primary-200}"),
      secondaryFixed: Color.fromString("{brand-secondary-400}"),
      onSecondaryFixed: Color.fromString("{brand-secondary-900}"),
      secondaryFixedDim: Color.fromString("{brand-secondary-500}"),
      onSecondaryFixedVariant: Color.fromString("{brand-secondary-200}"),
      // Surface containers
      surfaceDim: Color.fromString("{brand-primary-800}"),
      surfaceBright: Color.fromString("{brand-primary-900}"),
      surfaceContainerLowest: Color.fromString("{brand-primary-900}"),
      surfaceContainerLow: Color.fromString("{brand-primary-800}"),
      surfaceContainer: Color.fromString("{brand-primary-700}"),
      surfaceContainerHigh: Color.fromString("{brand-primary-600}"),
      surfaceContainerHighest: Color.fromString("{brand-primary-500}"),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,

    // Typography
    textTheme:
        TextTheme(
          // Display styles
          displayLarge: TextStyle.fromString("{typography-heading-bold}"),
          displayMedium: TextStyle.fromString("{typography-heading-medium}"),
          displaySmall: TextStyle.fromString("{typography-heading-regular}"),
          // Headline styles
          headlineLarge: TextStyle.fromString("{typography-heading-bold}"),
          headlineMedium: TextStyle.fromString("{typography-heading-medium}"),
          headlineSmall: TextStyle.fromString("{typography-heading-regular}"),
          // Title styles
          titleLarge: TextStyle.fromString("{typography-heading-medium}"),
          titleMedium: TextStyle.fromString("{typography-body-medium}"),
          titleSmall: TextStyle.fromString("{typography-body-regular}"),
          // Body styles
          bodyLarge: TextStyle.fromString("{typography-body-regular}"),
          bodyMedium: TextStyle.fromString("{typography-body-regular}"),
          bodySmall: TextStyle.fromString("{typography-body-small}"),
          // Label styles
          labelLarge: TextStyle.fromString("{typography-label}"),
          labelMedium: TextStyle.fromString("{typography-label}"),
          labelSmall: TextStyle.fromString("{typography-label}"),
        ).apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),

    // Base colors
    scaffoldBackgroundColor: colorScheme.background,
    canvasColor: colorScheme.surface,

    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle.fromString("{typography-heading-medium}"),
      toolbarTextStyle: TextStyle.fromString("{typography-accent-regular}"),
    ),

    // Bottom Navigation Bar
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      selectedLabelStyle: TextStyle.fromString("{typography-accent-medium}"),
      unselectedLabelStyle: TextStyle.fromString("{typography-accent-regular}"),
    ),

    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        textStyle: TextStyle.fromString("{typography-accent-medium}"),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.secondary,
      foregroundColor: colorScheme.onSecondary,
      elevation: 6,
    ),

    // Input Fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.transparent,
      labelStyle: TextStyle.fromString(
        "{typography-accent-regular}",
      ).copyWith(color: colorScheme.onSurfaceVariant),
      floatingLabelStyle: TextStyle.fromString(
        "{typography-accent-regular}",
      ).copyWith(color: colorScheme.primary),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(4),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(4),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.error),
        borderRadius: BorderRadius.circular(4),
      ),
    ),

    // Cards
    cardTheme: CardTheme(
      color: colorScheme.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // Chips
    chipTheme: ChipThemeData(
      backgroundColor: colorScheme.surfaceVariant,
      labelStyle: TextStyle.fromString("{typography-accent-regular}"),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // Data Tables
    dataTableTheme: DataTableThemeData(
      headingRowColor: MaterialStateProperty.all(colorScheme.surfaceVariant),
      headingTextStyle: TextStyle.fromString("{typography-accent-medium}"),
      dataTextStyle: TextStyle.fromString("{typography-body-regular}"),
      dividerThickness: 1,
    ),

    // Dialog
    dialogTheme: DialogTheme(
      backgroundColor: colorScheme.surface,
      elevation: 24,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
  );

  List<ExtendedColor> get extendedColors => [
    // Add extended colors if needed
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
