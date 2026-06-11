import 'package:flutter/material.dart';

import 'theme_constants.dart';

/// Semantic roles that Material 3's [ColorScheme] doesn't cover (success,
/// warning). Exposed as a [ThemeExtension] so widgets resolve them through
/// `Theme.of(context)` instead of hardcoding colors.
@immutable
class KeikoSemanticColors extends ThemeExtension<KeikoSemanticColors> {
  const KeikoSemanticColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
  });

  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;

  static const KeikoSemanticColors light = KeikoSemanticColors(
    success: BrandColors.accent500,
    onSuccess: BrandColors.accent100,
    successContainer: BrandColors.accent200,
    onSuccessContainer: BrandColors.accent900,
    warning: BrandColors.warning500,
    onWarning: BrandColors.warning100,
    warningContainer: BrandColors.warning200,
    onWarningContainer: BrandColors.warning900,
  );

  static const KeikoSemanticColors dark = KeikoSemanticColors(
    success: BrandColors.accent400,
    onSuccess: BrandColors.accent900,
    successContainer: BrandColors.accent700,
    onSuccessContainer: BrandColors.accent100,
    warning: BrandColors.warning400,
    onWarning: BrandColors.warning900,
    warningContainer: BrandColors.warning700,
    onWarningContainer: BrandColors.warning100,
  );

  /// Resolves the extension from [context], falling back to [light] so
  /// widgets keep working under themes that didn't register it.
  static KeikoSemanticColors of(BuildContext context) =>
      Theme.of(context).extension<KeikoSemanticColors>() ?? light;

  @override
  KeikoSemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
  }) {
    return KeikoSemanticColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
    );
  }

  @override
  KeikoSemanticColors lerp(KeikoSemanticColors? other, double t) {
    if (other == null) return this;
    return KeikoSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      onSuccessContainer:
          Color.lerp(onSuccessContainer, other.onSuccessContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      onWarningContainer:
          Color.lerp(onWarningContainer, other.onWarningContainer, t)!,
    );
  }
}
