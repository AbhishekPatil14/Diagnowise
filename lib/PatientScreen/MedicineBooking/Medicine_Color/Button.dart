import 'package:flutter/material.dart';
import 'Color.dart';

/// A reusable button component with consistent styling
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;
  final bool isPrimary;
  final bool isOutlined;
  final double borderRadius;

  /// Creates a primary button with elevated style
  const AppButton.primary({
    Key? key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 56,
    this.borderRadius = 12,
  })  : isPrimary = true,
        isOutlined = false,
        super(key: key);

  /// Creates a secondary button with outlined style
  const AppButton.secondary({
    Key? key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 56,
    this.borderRadius = 12,
  })  : isPrimary = false,
        isOutlined = true,
        super(key: key);

  /// Creates a text button with minimal styling
  const AppButton.text({
    Key? key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 44,
    this.borderRadius = 8,
  })  : isPrimary = false,
        isOutlined = false,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    if (isPrimary) {
      return _buildElevatedButton(context, isDarkMode);
    } else if (isOutlined) {
      return _buildOutlinedButton(context, isDarkMode);
    } else {
      return _buildTextButton(context, isDarkMode);
    }
  }

  Widget _buildElevatedButton(BuildContext context, bool isDarkMode) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: isDarkMode
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.primary.withOpacity(0.4),
          disabledForegroundColor: AppColors.white.withOpacity(0.6),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: _buildButtonContent(isDarkMode),
      ),
    );
  }

  Widget _buildOutlinedButton(BuildContext context, bool isDarkMode) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          backgroundColor: Colors.transparent,
          disabledForegroundColor: isDarkMode
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.primary.withOpacity(0.4),
          side: BorderSide(
            color: isLoading
                ? (isDarkMode
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.primary.withOpacity(0.4))
                : AppColors.primary,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: _buildButtonContent(isDarkMode, outlined: true),
      ),
    );
  }

  Widget _buildTextButton(BuildContext context, bool isDarkMode) {
    return SizedBox(
      width: width,
      height: height,
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          backgroundColor: Colors.transparent,
          disabledForegroundColor: isDarkMode
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.primary.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: _buildButtonContent(isDarkMode, outlined: true),
      ),
    );
  }

  Widget _buildButtonContent(bool isDarkMode, {bool outlined = false}) {
    if (isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            outlined ? AppColors.primary : AppColors.white,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      );
    }

    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}