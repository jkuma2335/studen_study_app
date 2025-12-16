import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Modern Elevated Button with glow effect
class ModernElevatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Gradient? gradient;
  final double? width;
  final bool enableGlow;

  const ModernElevatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.padding,
    this.borderRadius = 16,
    this.backgroundColor,
    this.gradient,
    this.width,
    this.enableGlow = true,
  });

  @override
  State<ModernElevatedButton> createState() => _ModernElevatedButtonState();
}

class _ModernElevatedButtonState extends State<ModernElevatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            width: widget.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              gradient: widget.gradient,
              color: widget.gradient == null
                  ? (widget.backgroundColor ?? theme.colorScheme.primary)
                  : null,
              boxShadow: widget.enableGlow
                  ? [
                      BoxShadow(
                        color: (widget.backgroundColor ?? theme.colorScheme.primary)
                            .withValues(alpha: 0.4 * _glowAnimation.value),
                        blurRadius: 16 * _glowAnimation.value,
                        spreadRadius: 2 * _glowAnimation.value,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: ElevatedButton(
              onPressed: null, // Handled by GestureDetector
              style: ElevatedButton.styleFrom(
                padding: widget.padding ??
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

/// Icon Button with modern styling
class ModernIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final String? tooltip;

  const ModernIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 24,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget button = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, size: size),
        color: iconColor ?? theme.colorScheme.primary,
        onPressed: onPressed,
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip, child: button);
    }
    return button;
  }
}

