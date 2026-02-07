import 'package:flutter/material.dart';

/// Transitions de page personnalisées pour une navigation fluide
class PageTransitions {
  PageTransitions._();

  /// Transition par défaut avec fade et slide
  static Route<T> fadeSlide<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOut),
        );

        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, 0.05),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// Transition slide horizontale (iOS-like)
  static Route<T> slideHorizontal<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 300),
    bool fromRight = true,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final begin = fromRight ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0);
        
        final slideAnimation = Tween<Offset>(
          begin: begin,
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        ));

        // Légère animation de scale pour la page précédente
        final scaleAnimation = Tween<double>(
          begin: 1.0,
          end: 0.95,
        ).animate(CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeInOut,
        ));

        return SlideTransition(
          position: slideAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// Transition slide verticale (bottom sheet style)
  static Route<T> slideVertical<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 350),
    bool fromBottom = true,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final begin = fromBottom ? const Offset(0.0, 1.0) : const Offset(0.0, -1.0);
        
        final slideAnimation = Tween<Offset>(
          begin: begin,
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));

        return SlideTransition(
          position: slideAnimation,
          child: child,
        );
      },
    );
  }

  /// Transition scale (zoom in/out)
  static Route<T> scale<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 300),
    Alignment alignment = Alignment.center,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ));

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            alignment: alignment,
            child: child,
          ),
        );
      },
    );
  }

  /// Transition fade simple
  static Route<T> fade<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 250),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: child,
        );
      },
    );
  }

  /// Transition avec effet de partage (shared axis)
  static Route<T> sharedAxis<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 300),
    SharedAxisDirection direction = SharedAxisDirection.horizontal,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
          ),
        );

        final fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(
            parent: secondaryAnimation,
            curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
          ),
        );

        Offset getSlideOffset(bool entering) {
          final factor = entering ? 1.0 : -1.0;
          switch (direction) {
            case SharedAxisDirection.horizontal:
              return Offset(0.3 * factor, 0.0);
            case SharedAxisDirection.vertical:
              return Offset(0.0, 0.3 * factor);
          }
        }

        final slideIn = Tween<Offset>(
          begin: getSlideOffset(true),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));

        return FadeTransition(
          opacity: fadeIn,
          child: FadeTransition(
            opacity: fadeOut,
            child: SlideTransition(
              position: slideIn,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

enum SharedAxisDirection {
  horizontal,
  vertical,
}

/// Wrapper pour des transitions hero améliorées
class HeroTransitionWidget extends StatelessWidget {
  final String tag;
  final Widget child;
  final ShapeBorder? shape;

  const HeroTransitionWidget({
    super.key,
    required this.tag,
    required this.child,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      flightShuttleBuilder: (
        flightContext,
        animation,
        flightDirection,
        fromHeroContext,
        toHeroContext,
      ) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            return Material(
              color: Colors.transparent,
              shape: shape,
              child: child,
            );
          },
        );
      },
      child: Material(
        color: Colors.transparent,
        shape: shape,
        child: child,
      ),
    );
  }
}

/// Extension pour faciliter la navigation avec transitions
extension NavigatorTransitionExtension on NavigatorState {
  Future<T?> pushFadeSlide<T>(Widget page, {RouteSettings? settings}) {
    return push(PageTransitions.fadeSlide<T>(page: page, settings: settings));
  }

  Future<T?> pushSlideHorizontal<T>(Widget page, {RouteSettings? settings, bool fromRight = true}) {
    return push(PageTransitions.slideHorizontal<T>(page: page, settings: settings, fromRight: fromRight));
  }

  Future<T?> pushSlideVertical<T>(Widget page, {RouteSettings? settings, bool fromBottom = true}) {
    return push(PageTransitions.slideVertical<T>(page: page, settings: settings, fromBottom: fromBottom));
  }

  Future<T?> pushScale<T>(Widget page, {RouteSettings? settings}) {
    return push(PageTransitions.scale<T>(page: page, settings: settings));
  }

  Future<T?> pushFade<T>(Widget page, {RouteSettings? settings}) {
    return push(PageTransitions.fade<T>(page: page, settings: settings));
  }
}
