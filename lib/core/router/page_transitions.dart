import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Transitions de page personnalisées pour GoRouter
class SlideUpTransition extends CustomTransitionPage<void> {
  SlideUpTransition({required super.child, super.key})
      : super(
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween<Offset>(
              begin: const Offset(0, 0.25),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic));

            final fadeTween = Tween<double>(begin: 0, end: 1).chain(
              CurveTween(curve: Curves.easeOut),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: animation.drive(fadeTween),
                child: child,
              ),
            );
          },
        );
}

class FadeScaleTransition extends CustomTransitionPage<void> {
  FadeScaleTransition({required super.child, super.key})
      : super(
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final scaleTween = Tween<double>(begin: 0.92, end: 1.0).chain(
              CurveTween(curve: Curves.easeOutCubic),
            );
            final fadeTween = Tween<double>(begin: 0, end: 1).chain(
              CurveTween(curve: Curves.easeOut),
            );

            return ScaleTransition(
              scale: animation.drive(scaleTween),
              child: FadeTransition(
                opacity: animation.drive(fadeTween),
                child: child,
              ),
            );
          },
        );
}

class SlideRightTransition extends CustomTransitionPage<void> {
  SlideRightTransition({required super.child, super.key})
      : super(
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}
