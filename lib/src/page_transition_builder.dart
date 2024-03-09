import 'package:flutter/material.dart';
import 'package:hyper_transition/hyper_transition.dart';

class HyperSnapshotTransitionsBuilder extends PageTransitionsBuilder {
  const HyperSnapshotTransitionsBuilder({
    this.allowSnapshotting = true,
    this.allowEnterRouteSnapshotting = true,
  });

  final bool allowSnapshotting;
  final bool allowEnterRouteSnapshotting;

  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    return HyperSnapshotPageTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        allowSnapshotting: allowSnapshotting && route.allowSnapshotting,
        allowEnterRouteSnapshotting: allowEnterRouteSnapshotting,
        child: child);
  }
}

class HyperTransitionsBuilder extends PageTransitionsBuilder {
  const HyperTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    return HyperPageTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        child: child);
  }
}
