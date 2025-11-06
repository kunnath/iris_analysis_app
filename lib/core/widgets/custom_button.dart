import 'package:flutter/material.dart';

enum ButtonType {
  primary,
  secondary,
  outline,
  text,
  danger,
  success,
  warning,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? customColor;
  final Color? customTextColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool iconBefore;
  final double? iconSize;
  final Widget? child;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.customColor,
    this.customTextColor,
    this.fontSize,
    this.fontWeight,
    this.iconBefore = true,
    this.iconSize,
    this.child,
  });

  // Named constructors for common button types
  const CustomButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height,
    this.size = ButtonSize.medium,
    this.padding,
    this.borderRadius,
    this.fontSize,
    this.fontWeight,
    this.iconBefore = true,
    this.iconSize,
    this.child,
  }) : type = ButtonType.primary,
       customColor = null,
       customTextColor = null;

  const CustomButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height,
    this.size = ButtonSize.medium,
    this.padding,
    this.borderRadius,
    this.fontSize,
    this.fontWeight,
    this.iconBefore = true,
    this.iconSize,
    this.child,
  }) : type = ButtonType.secondary,
       customColor = null,
       customTextColor = null;

  const CustomButton.outline({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height,
    this.size = ButtonSize.medium,
    this.padding,
    this.borderRadius,
    this.fontSize,
    this.fontWeight,
    this.iconBefore = true,
    this.iconSize,
    this.child,
  }) : type = ButtonType.outline,
       customColor = null,
       customTextColor = null;

  const CustomButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height,
    this.size = ButtonSize.medium,
    this.padding,
    this.borderRadius,
    this.fontSize,
    this.fontWeight,
    this.iconBefore = true,
    this.iconSize,
    this.child,
  }) : type = ButtonType.text,
       customColor = null,
       customTextColor = null;

  const CustomButton.danger({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height,
    this.size = ButtonSize.medium,
    this.padding,
    this.borderRadius,
    this.fontSize,
    this.fontWeight,
    this.iconBefore = true,
    this.iconSize,
    this.child,
  }) : type = ButtonType.danger,
       customColor = null,
       customTextColor = null;

  const CustomButton.success({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height,
    this.size = ButtonSize.medium,
    this.padding,
    this.borderRadius,
    this.fontSize,
    this.fontWeight,
    this.iconBefore = true,
    this.iconSize,
    this.child,
  }) : type = ButtonType.success,
       customColor = null,
       customTextColor = null;

  const CustomButton.warning({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height,
    this.size = ButtonSize.medium,
    this.padding,
    this.borderRadius,
    this.fontSize,
    this.fontWeight,
    this.iconBefore = true,
    this.iconSize,
    this.child,
  }) : type = ButtonType.warning,
       customColor = null,
       customTextColor = null;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = !widget.isDisabled && !widget.isLoading && widget.onPressed != null;
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SizedBox(
            width: widget.width,
            height: widget.height ?? _getButtonHeight(),
            child: ElevatedButton(
              onPressed: isEnabled ? _handlePress : null,
              style: _getButtonStyle(theme, isEnabled),
              onLongPress: isEnabled ? _handleLongPress : null,
              child: _buildButtonContent(),
            ),
          ),
        );
      },
    );
  }

  void _handlePress() {
    if (widget.onPressed != null) {
      setState(() => _isPressed = true);
      _animationController.forward().then((_) {
        _animationController.reverse().then((_) {
          if (mounted) {
            setState(() => _isPressed = false);
            widget.onPressed!();
          }
        });
      });
    }
  }

  void _handleLongPress() {
    if (widget.onPressed != null) {
      _animationController.forward();
    }
  }

  double _getButtonHeight() {
    switch (widget.size) {
      case ButtonSize.small:
        return 36.0;
      case ButtonSize.medium:
        return 48.0;
      case ButtonSize.large:
        return 56.0;
    }
  }

  EdgeInsetsGeometry _getButtonPadding() {
    if (widget.padding != null) return widget.padding!;
    
    switch (widget.size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  double _getFontSize() {
    if (widget.fontSize != null) return widget.fontSize!;
    
    switch (widget.size) {
      case ButtonSize.small:
        return 12.0;
      case ButtonSize.medium:
        return 14.0;
      case ButtonSize.large:
        return 16.0;
    }
  }

  double _getIconSize() {
    if (widget.iconSize != null) return widget.iconSize!;
    
    switch (widget.size) {
      case ButtonSize.small:
        return 16.0;
      case ButtonSize.medium:
        return 18.0;
      case ButtonSize.large:
        return 20.0;
    }
  }

  ButtonStyle _getButtonStyle(ThemeData theme, bool isEnabled) {
    final colors = _getButtonColors(theme);
    
    return ElevatedButton.styleFrom(
      backgroundColor: colors['background'],
      foregroundColor: colors['foreground'],
      disabledBackgroundColor: colors['disabledBackground'],
      disabledForegroundColor: colors['disabledForeground'],
      elevation: _getElevation(),
      padding: _getButtonPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8.0),
        side: _getBorderSide(theme, colors),
      ),
      textStyle: TextStyle(
        fontSize: _getFontSize(),
        fontWeight: widget.fontWeight ?? FontWeight.w600,
      ),
    );
  }

  Map<String, Color?> _getButtonColors(ThemeData theme) {
    if (widget.customColor != null) {
      return {
        'background': widget.customColor,
        'foreground': widget.customTextColor ?? Colors.white,
        'disabledBackground': widget.customColor!.withOpacity(0.3),
        'disabledForeground': (widget.customTextColor ?? Colors.white).withOpacity(0.5),
      };
    }

    switch (widget.type) {
      case ButtonType.primary:
        return {
          'background': theme.primaryColor,
          'foreground': Colors.white,
          'disabledBackground': theme.primaryColor.withOpacity(0.3),
          'disabledForeground': Colors.white.withOpacity(0.5),
        };
      
      case ButtonType.secondary:
        return {
          'background': theme.colorScheme.secondary,
          'foreground': Colors.white,
          'disabledBackground': theme.colorScheme.secondary.withOpacity(0.3),
          'disabledForeground': Colors.white.withOpacity(0.5),
        };
      
      case ButtonType.outline:
        return {
          'background': Colors.transparent,
          'foreground': theme.primaryColor,
          'disabledBackground': Colors.transparent,
          'disabledForeground': theme.primaryColor.withOpacity(0.5),
        };
      
      case ButtonType.text:
        return {
          'background': Colors.transparent,
          'foreground': theme.primaryColor,
          'disabledBackground': Colors.transparent,
          'disabledForeground': theme.primaryColor.withOpacity(0.5),
        };
      
      case ButtonType.danger:
        return {
          'background': Colors.red,
          'foreground': Colors.white,
          'disabledBackground': Colors.red.withOpacity(0.3),
          'disabledForeground': Colors.white.withOpacity(0.5),
        };
      
      case ButtonType.success:
        return {
          'background': Colors.green,
          'foreground': Colors.white,
          'disabledBackground': Colors.green.withOpacity(0.3),
          'disabledForeground': Colors.white.withOpacity(0.5),
        };
      
      case ButtonType.warning:
        return {
          'background': Colors.orange,
          'foreground': Colors.white,
          'disabledBackground': Colors.orange.withOpacity(0.3),
          'disabledForeground': Colors.white.withOpacity(0.5),
        };
    }
  }

  double _getElevation() {
    switch (widget.type) {
      case ButtonType.outline:
      case ButtonType.text:
        return 0.0;
      default:
        return widget.isLoading ? 0.0 : 2.0;
    }
  }

  BorderSide _getBorderSide(ThemeData theme, Map<String, Color?> colors) {
    switch (widget.type) {
      case ButtonType.outline:
        return BorderSide(
          color: colors['foreground'] ?? theme.primaryColor,
          width: 1.0,
        );
      default:
        return BorderSide.none;
    }
  }

  Widget _buildButtonContent() {
    if (widget.child != null) {
      return widget.child!;
    }

    if (widget.isLoading) {
      return _buildLoadingContent();
    }

    if (widget.icon != null) {
      return _buildIconTextContent();
    }

    return Text(widget.text);
  }

  Widget _buildLoadingContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: _getIconSize(),
          height: _getIconSize(),
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getButtonColors(Theme.of(context))['foreground'] ?? Colors.white,
            ),
          ),
        ),
        if (widget.text.isNotEmpty) ...[
          const SizedBox(width: 8),
          Text(widget.text),
        ],
      ],
    );
  }

  Widget _buildIconTextContent() {
    final iconWidget = Icon(
      widget.icon,
      size: _getIconSize(),
    );

    if (widget.text.isEmpty) {
      return iconWidget;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.iconBefore) ...[
          iconWidget,
          const SizedBox(width: 8),
          Flexible(child: Text(widget.text)),
        ] else ...[
          Flexible(child: Text(widget.text)),
          const SizedBox(width: 8),
          iconWidget,
        ],
      ],
    );
  }
}

// Extension for easy button creation
extension CustomButtonExtension on Widget {
  Widget withLoading(bool isLoading) {
    if (this is CustomButton) {
      final button = this as CustomButton;
      return CustomButton(
        text: button.text,
        onPressed: button.onPressed,
        type: button.type,
        size: button.size,
        icon: button.icon,
        isLoading: isLoading,
        isDisabled: button.isDisabled,
        width: button.width,
        height: button.height,
        padding: button.padding,
        borderRadius: button.borderRadius,
        customColor: button.customColor,
        customTextColor: button.customTextColor,
        fontSize: button.fontSize,
        fontWeight: button.fontWeight,
        iconBefore: button.iconBefore,
        iconSize: button.iconSize,
        child: button.child,
      );
    }
    return this;
  }
}

// Utility class for button configurations
class ButtonConfig {
  static const Duration animationDuration = Duration(milliseconds: 200);
  static const Curve animationCurve = Curves.easeInOut;
  static const double defaultBorderRadius = 8.0;
  static const double defaultElevation = 2.0;
  
  // Common button styles
  static ButtonStyle get primaryStyle => ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    elevation: defaultElevation,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(defaultBorderRadius),
    ),
  );

  static ButtonStyle get secondaryStyle => ElevatedButton.styleFrom(
    backgroundColor: Colors.grey.shade600,
    foregroundColor: Colors.white,
    elevation: defaultElevation,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(defaultBorderRadius),
    ),
  );

  static ButtonStyle get outlineStyle => OutlinedButton.styleFrom(
    foregroundColor: Colors.blue,
    side: const BorderSide(color: Colors.blue),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(defaultBorderRadius),
    ),
  );

  static ButtonStyle get textStyle => TextButton.styleFrom(
    foregroundColor: Colors.blue,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(defaultBorderRadius),
    ),
  );
}
