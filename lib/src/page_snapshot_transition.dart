import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:window_rounded_corners/window_rounded_corners.dart';

class HyperSnapshotPageTransition extends StatelessWidget {
  const HyperSnapshotPageTransition({
    super.key,
    required this.animation,
    required this.secondaryAnimation,
    required this.allowSnapshotting,
    required this.allowEnterRouteSnapshotting,
    this.child,
  });

  /// The animation that drives the [child]'s entrance and exit.
  final Animation<double> animation;

  /// The animation that transitions [child] when new content is pushed on top
  /// of it.
  final Animation<double> secondaryAnimation;
  final bool allowSnapshotting;
  final bool allowEnterRouteSnapshotting;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return DualTransitionBuilder(
        // child entrance and exit
        animation: animation,
        forwardBuilder: (context, animation, child) {
          /// child enter
          return _EnterTransition(
              animation: animation,
              allowSnapshotting:
                  allowSnapshotting && allowEnterRouteSnapshotting,
              reverse: false,
              child: child);
        },
        reverseBuilder: (context, animation, child) {
          /// child exit
          return _EnterTransition(
              animation: animation,
              allowSnapshotting: allowSnapshotting,
              reverse: true,
              child: child);
        },
        child: DualTransitionBuilder(
            // child with back stacks
            animation: ReverseAnimation(secondaryAnimation),
            forwardBuilder: (context, animation, child) {
              // child pushed into back stack
              return _ExitTransition(
                  animation: animation,
                  allowSnapshotting: allowSnapshotting,
                  reverse: false,
                  child: child);
            },
            reverseBuilder: (context, animation, child) {
              // child re-enter form back stack
              return _ExitTransition(
                  animation: animation,
                  allowSnapshotting:
                      allowSnapshotting && allowEnterRouteSnapshotting,
                  reverse: true,
                  child: child);
            },
            child: child));
  }
}

//////////////////
//////////////////
//////////////////
class _EnterTransition extends StatefulWidget {
  const _EnterTransition(
      {required this.allowSnapshotting,
      required this.animation,
      this.reverse = false,
      this.child});

  final bool allowSnapshotting;
  final Animation<double> animation;
  final bool reverse;
  final Widget? child;

  @override
  State<StatefulWidget> createState() => _EnterTransitionState();
}

class _EnterTransitionState extends State<_EnterTransition> {
  final SnapshotController snapshotController = SnapshotController();
  static final slideIn = Tween<double>(
    begin: 1,
    end: 0,
  ).chain(CurveTween(curve: Curves.decelerate));

  static final slideOut = Tween<double>(
    begin: 0,
    end: 1,
  ).chain(CurveTween(curve: Curves.decelerate));

  bool get useSnapshot => !kIsWeb && widget.allowSnapshotting;

  late Animation<double> slideAnimate;
  late _EnterPainter snapshotPainter;

  void _prepareAnimate() {
    slideAnimate =
        (widget.reverse ? slideOut : slideIn).animate(widget.animation);
    widget.animation.addListener(onAnimationValueChange);
    widget.animation.addStatusListener(onAnimationStatusChange);
  }

  @override
  void initState() {
    _prepareAnimate();
    snapshotPainter =
        _EnterPainter(translate: slideAnimate, animation: widget.animation);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _EnterTransition oldWidget) {
    if (oldWidget.reverse != widget.reverse ||
        oldWidget.animation != widget.animation) {
      oldWidget.animation.removeListener(onAnimationValueChange);
      oldWidget.animation.removeStatusListener(onAnimationStatusChange);
      _prepareAnimate();
      snapshotPainter.dispose();
      snapshotPainter =
          _EnterPainter(translate: slideAnimate, animation: widget.animation);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.animation.removeListener(onAnimationValueChange);
    widget.animation.removeStatusListener(onAnimationStatusChange);
    snapshotPainter.dispose();
    snapshotController.dispose();
    super.dispose();
  }

  void onAnimationValueChange() {
    if (slideAnimate.value == 0.0 || slideAnimate.value == 1.0) {
      snapshotController.allowSnapshotting = false;
    } else {
      snapshotController.allowSnapshotting = useSnapshot;
    }
  }

  void onAnimationStatusChange(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.dismissed:
      case AnimationStatus.completed:
        snapshotController.allowSnapshotting = false;
      case AnimationStatus.forward:
      case AnimationStatus.reverse:
        snapshotController.allowSnapshotting = useSnapshot;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SnapshotWidget(
        controller: snapshotController,
        painter: snapshotPainter,
        child: widget.child);
  }
}

class _EnterPainter extends SnapshotPainter {
  _EnterPainter({required this.translate, required this.animation}) {
    animation.addListener(notifyListeners);
    animation.addStatusListener(_onStatusChange);
  }

  final Corners corners = WindowCorners.getCorners();

  final Animation<double> translate;
  final Animation<double> animation;
  final Matrix4 matrix = Matrix4.zero();
  final LayerHandle<TransformLayer> transformLayerHandler =
      LayerHandle<TransformLayer>();
  final LayerHandle<ClipRRectLayer> clipLayerHandler =
      LayerHandle<ClipRRectLayer>();

  void _onStatusChange(_) {
    notifyListeners();
  }

  @override
  void dispose() {
    animation.removeListener(notifyListeners);
    animation.removeStatusListener(_onStatusChange);
    transformLayerHandler.layer = null;
    clipLayerHandler.layer = null;
    super.dispose();
  }

  // snapshotting is disabled
  @override
  void paint(PaintingContext context, Offset offset, Size size,
      PaintingContextCallback painter) {
    switch (animation.status) {
      case AnimationStatus.completed:
      case AnimationStatus.dismissed:
        {
          painter(context, offset);
        }
      case AnimationStatus.forward:
      case AnimationStatus.reverse:
        {
          matrix.setIdentity();
          matrix.translate(size.width * translate.value);
          transformLayerHandler.layer =
              context.pushTransform(true, offset, matrix, (context, offset) {
            if (corners == Corners.zero) {
              painter(context, offset);
            } else {
              final bounds = Rect.fromLTWH(0, 0, size.width, size.height);
              final clipRRect = RRect.fromLTRBAndCorners(
                0,
                0,
                size.width,
                size.height,
                topLeft: Radius.circular(corners.topLeft),
                topRight: Radius.circular(corners.topRight),
                bottomRight: Radius.circular(corners.bottomRight),
                bottomLeft: Radius.circular(corners.bottomLeft),
              );
              clipLayerHandler.layer = context.pushClipRRect(
                  true, offset, bounds, clipRRect, painter);
            }
          });
        }
    }
  }

  // snapshotting is enable
  @override
  void paintSnapshot(PaintingContext context, Offset offset, Size size,
      ui.Image image, Size sourceSize, double pixelRatio) {
    final left = offset.dx + size.width * translate.value;
    final right = offset.dy;

    context.canvas.clipRRect(RRect.fromLTRBAndCorners(
      left,
      right,
      left + size.width,
      right + size.height,
      topLeft: Radius.circular(corners.topLeft),
      topRight: Radius.circular(corners.topRight),
      bottomRight: Radius.circular(corners.bottomRight),
      bottomLeft: Radius.circular(corners.bottomLeft),
    ));

    final Rect src = Rect.fromLTWH(0, 0, sourceSize.width, sourceSize.height);
    final Rect dst = Rect.fromLTWH(left, right, size.width, size.height);
    context.canvas.drawImageRect(image, src, dst, Paint());
  }

  @override
  bool shouldRepaint(_EnterPainter oldPainter) {
    return oldPainter.animation.value != animation.value;
  }
}

class _ExitTransition extends StatefulWidget {
  const _ExitTransition(
      {required this.allowSnapshotting,
      required this.animation,
      this.reverse = false,
      this.child});

  final bool allowSnapshotting;
  final Animation<double> animation;
  final bool reverse;
  final Widget? child;

  @override
  State<StatefulWidget> createState() => _ExitTransitionState();
}

class _ExitTransitionState extends State<_ExitTransition> {
  final SnapshotController snapshotController = SnapshotController();

  static final slideIn = Tween<double>(
    begin: -0.12,
    end: 0,
  ).chain(CurveTween(curve: Curves.decelerate));

  static final slideOut = Tween<double>(
    begin: 0,
    end: -0.12,
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

  bool get useSnapshot => !kIsWeb && widget.allowSnapshotting;

  late Animation<double> slideAnimate;
  late Animation<double> alphaAnimate;
  late _ExitPainter snapshotPainter;

  void _prepareAnimate() {
    slideAnimate =
        (widget.reverse ? slideOut : slideIn).animate(widget.animation);
    alphaAnimate =
        (widget.reverse ? alphaOut : alphaIn).animate(widget.animation);
    widget.animation.addListener(onAnimationValueChange);
    widget.animation.addStatusListener(onAnimationStatusChange);
  }

  @override
  void initState() {
    _prepareAnimate();
    snapshotPainter = _ExitPainter(
        translate: slideAnimate,
        alpha: alphaAnimate,
        animation: widget.animation);

    super.initState();
  }

  @override
  void didUpdateWidget(covariant _ExitTransition oldWidget) {
    if (oldWidget.reverse != widget.reverse ||
        oldWidget.animation != widget.animation) {
      oldWidget.animation.removeListener(onAnimationValueChange);
      oldWidget.animation.removeStatusListener(onAnimationStatusChange);
      _prepareAnimate();
      snapshotPainter.dispose();
      snapshotPainter = _ExitPainter(
          translate: slideAnimate,
          alpha: alphaAnimate,
          animation: widget.animation);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.animation.removeListener(onAnimationValueChange);
    widget.animation.removeStatusListener(onAnimationStatusChange);
    snapshotPainter.dispose();
    snapshotController.dispose();
    super.dispose();
  }

  void onAnimationValueChange() {
    if (slideAnimate.value == 0 || slideAnimate.value == -0.12) {
      snapshotController.allowSnapshotting = false;
    } else {
      snapshotController.allowSnapshotting = useSnapshot;
    }
  }

  void onAnimationStatusChange(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.dismissed:
      case AnimationStatus.completed:
        snapshotController.allowSnapshotting = false;
      case AnimationStatus.forward:
      case AnimationStatus.reverse:
        snapshotController.allowSnapshotting = useSnapshot;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SnapshotWidget(
        controller: snapshotController,
        painter: snapshotPainter,
        child: widget.child);
  }
}

class _ExitPainter extends SnapshotPainter {
  _ExitPainter(
      {required this.translate, required this.alpha, required this.animation}) {
    animation.addListener(notifyListeners);
    animation.addStatusListener(_onStatusChange);
  }

  final Animation<double> translate;
  final Animation<double> alpha;
  final Animation<double> animation;

  final Matrix4 matrix = Matrix4.zero();
  final LayerHandle<TransformLayer> transformLayerHandler =
      LayerHandle<TransformLayer>();
  final LayerHandle<OpacityLayer> opacityLayerHandler =
      LayerHandle<OpacityLayer>();

  void _onStatusChange(_) {
    notifyListeners();
  }

  @override
  void dispose() {
    animation.removeListener(notifyListeners);
    animation.removeStatusListener(_onStatusChange);
    transformLayerHandler.layer = null;
    opacityLayerHandler.layer = null;
    super.dispose();
  }

  @override
  void paint(PaintingContext context, Offset offset, Size size,
      PaintingContextCallback painter) {
    switch (animation.status) {
      case AnimationStatus.completed:
      case AnimationStatus.dismissed:
        {
          painter(context, offset);
        }
      case AnimationStatus.forward:
      case AnimationStatus.reverse:
        {
          final translateX = size.width * translate.value;
          final left = offset.dx + translateX;
          final right = offset.dy;
          context.canvas.drawRect(
              Rect.fromLTWH(left, right, size.width, size.height),
              Paint()..color = Colors.black);
          matrix.setIdentity();
          matrix.translate(translateX);
          transformLayerHandler.layer =
              context.pushTransform(true, offset, matrix, (context, offset) {
            opacityLayerHandler.layer = context.pushOpacity(
                offset, (255 * alpha.value).toInt(), painter);
          });
        }
    }
  }

  @override
  void paintSnapshot(PaintingContext context, Offset offset, Size size,
      ui.Image image, Size sourceSize, double pixelRatio) {
    final left = offset.dx + size.width * translate.value;
    final right = offset.dy;

    final Rect src = Rect.fromLTWH(0, 0, sourceSize.width, sourceSize.height);
    final Rect dst = Rect.fromLTWH(left, right, size.width, size.height);

    final paint = Paint()..color = Colors.black;
    context.canvas.drawRect(dst, paint);
    paint.color = ui.Color.fromRGBO(0, 0, 0, alpha.value);
    context.canvas.drawImageRect(image, src, dst, paint);
  }

  @override
  bool shouldRepaint(_ExitPainter oldPainter) {
    return oldPainter.animation.value != animation.value;
  }
}
