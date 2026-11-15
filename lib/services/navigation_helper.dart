import 'package:flutter/material.dart';

/// Smooth, cinematic cross-fade page route transition to eliminate black screen flickers
class NasaFadeRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  NasaFadeRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 280),
          reverseTransitionDuration: const Duration(milliseconds: 240),
        );
}
