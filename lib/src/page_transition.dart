import 'package:flutter/material.dart';
import 'package:window_rounded_corners/window_rounded_corners.dart';

class HyperPageTransition extends StatelessWidget {
  const HyperPageTransition({
    super.key,
    required this.animation,
    required this.secondaryAnimation,
    this.child,
  });

  /// The animation that drives the [child]'s entrance and exit.
  final Animation<double> animation;

  /// The animation that transitions [child] when new content is pushed on top
  /// of it.
  final Animation<double> secondaryAnimation;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return DualTransitionBuilder(
        // child entrance and exit
        animation: animation,
        forwardBuilder: (context, animation, child) {
          /// child enter
          return _EnterTransition(
              animation: animation, reverse: false, child: child);
        },
        reverseBuilder: (context, animation, child) {
          /// child exit
          return _EnterTransition(
              animation: animation, reverse: true, child: child);
        },
        child: DualTransitionBuilder(
            // child with back stacks
            animation: ReverseAnimation(secondaryAnimation),
            forwardBuilder: (context, animation, child) {
              // child pushed into back stack
              return _ExitTransition(
                  animation: animation, reverse: false, child: child);
            },
            reverseBuilder: (context, animation, child) {
              // child re-enter form back stack
              return _ExitTransition(
                  animation: animation, reverse: true, child: child);
            },
            child: child));
  }
}

class _EnterTransition extends StatelessWidget {
  const _EnterTransition(
      {required this.animation, this.reverse = false, this.child});

  final Animation<double> animation;
  final Widget? child;
  final bool reverse;

  /// X : 100% -> 0%
  static final slideIn = Tween<Offset>(
    begin: const Offset(1.0, 0),
    end: Offset.zero,
  ).chain(CurveTween(curve: Curves.decelerate));

  /// X Reverse
  static final slideOut = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(1.0, 0),
  ).chain(CurveTween(curve: Curves.decelerate));

  @override
  Widget build(BuildContext context) {
    var corners = WindowCorners.getCorners();
    var child = this.child;
    if (corners != Corners.zero) {
      child = ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(corners.topLeft.toDouble()),
            topRight: Radius.circular(corners.topRight.toDouble()),
            bottomLeft: Radius.circular(corners.bottomLeft.toDouble()),
            bottomRight: Radius.circular(corners.bottomRight.toDouble()),
          ),
          child: child);
    }
    return SlideTransition(
      position: (reverse ? slideOut : slideIn).animate(animation),
      child: child,
    );
  }
}

class _ExitTransition extends StatelessWidget {
  const _ExitTransition(
      {required this.animation, this.reverse = false, this.child});

  final Animation<double> animation;
  final bool reverse;
  final Widget? child;

  /// X : -20% -> 0%
  static final slideIn = Tween<Offset>(
    begin: const Offset(-0.2, 0),
    end: Offset.zero,
  ).chain(CurveTween(curve: Curves.decelerate));

  static final slideOut = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(-0.2, 0),
  ).chain(CurveTween(curve: Curves.decelerate));

  static final Animatable<double> alphaIn = Tween<double>(begin: 0.5, end: 1)
      .chain(CurveTween(curve: Curves.decelerate));

  static final Animatable<double> alphaOut = TweenSequence([
    TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0.5)
            .chain(CurveTween(curve: Curves.decelerate)),
        weight: 1),
    TweenSequenceItem(tween: ConstantTween(0.5), weight: 1),
  ]);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
        color: Colors.black,
        child: FadeTransition(
            opacity: reverse
                ? alphaOut.animate(animation)
                : alphaIn.animate(animation),
            child: SlideTransition(
              position: (reverse ? slideOut : slideIn).animate(animation),
              child: child,
            )));
  }
}
