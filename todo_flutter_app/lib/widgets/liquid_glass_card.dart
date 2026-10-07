import 'dart:ui';
import 'package:flutter/material.dart';

class LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final EdgeInsetsGeometry padding;
  final Color? tintColor;
  final Color? glowColor;
  final bool showGloss;
  final VoidCallback? onTap;

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.borderRadius = 24.0,
    this.blur = 16.0,
    this.padding = const EdgeInsets.all(20.0),
    this.tintColor,
    this.glowColor,
    this.showGloss = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardBody = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (tintColor ?? Colors.white).withValues(alpha: 0.22),
                (tintColor ?? Colors.white).withValues(alpha: 0.06),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.32),
              width: 1.2,
            ),
          ),
          child: Stack(
            children: [
              if (showGloss)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 38,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(borderRadius),
                      topRight: Radius.circular(borderRadius),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.18),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: padding,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );

    Widget styledCard = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          if (glowColor != null)
            BoxShadow(
              color: glowColor!.withValues(alpha: 0.2),
              blurRadius: 22,
              spreadRadius: -2,
            ),
        ],
      ),
      child: cardBody,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: styledCard,
      );
    }

    return styledCard;
  }
}