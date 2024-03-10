# [hyper_transition](https://pub.dev/packages/hyper_transition)

![Pub Version](https://img.shields.io/pub/v/hyper_transition)

HyperOS/MIUI Like PageTransitions

## Getting started


```yaml
dependencies:
  flutter:
    sdk: flutter
  # add window_rounded_corners
  window_rounded_corners: ^{latest version}
  # add hyper_transition
  hyper_transition: ^{latest version}
```

## Usage


```dart
class HyperApp extends StatelessWidget {
  const HyperApp({super.key});

  @override
  Widget build(BuildContext context) {
    // required !
    WindowCorners.init();

    return MaterialApp.router(
        title: 'Hyper Transition',
        theme: ThemeData(
          colorScheme:
              ColorScheme.fromSeed(seedColor: Colors.blueGrey.shade100),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: true),
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.android: HyperSnapshotTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        routerConfig: appRouter);
  }
}
```



### HyperSnapshotPageTransition


Using SnapshotWidget to improve smoothness. But during the transition, the animation in the screen will be frozen.  refer to [ZoomPageTransitionsBuilder](https://api.flutter.dev/flutter/material/ZoomPageTransitionsBuilder-class.html)


```dart
HyperSnapshotTransitionsBuilder(allowSnapshotting: true,allowEnterRouteSnapshotting: true)

HyperSnapshotPageTransition(
  animation: animation,
  secondaryAnimation: secondaryAnimation,
  allowSnapshotting: true,
  allowEnterRouteSnapshotting: true,
  child: child
)
```



### HyperPageTransition
 

Using Animation Widgets to achieve effects


```dart
HyperTransitionsBuilder()

HyperPageTransition(
  animation: animation,
  secondaryAnimation: secondaryAnimation,
  child: child
)
```



## Screenshot

## HyperSnapshotPageTransition 
* allowSnapshotting: true
* allowEnterRouteSnapshotting: true

![img](https://raw.githubusercontent.com/ongakuer/hyper_transition/main/screenshot/flutter-snapshot.gif)


## HyperPageTransition 

![img](https://raw.githubusercontent.com/ongakuer/hyper_transition/main/screenshot/flutter.gif)


## Android - HyperOS

![img](https://raw.githubusercontent.com/ongakuer/hyper_transition/main/screenshot/native.gif)


