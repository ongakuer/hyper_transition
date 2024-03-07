# hyper_transition

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
  hyper_transition：^{latest version}
```

## Usage

```dart
void main() {
  runApp(const HyperApp());
}

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
              TargetPlatform.android: HyperTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        routerConfig: appRouter);
  }
}
```


## Screenshot

## Flutter 


![img](https://raw.githubusercontent.com/ongakuer/hyper_transition/main/screenshot/flutter.gif)


## Android - HyperOS

![img](https://raw.githubusercontent.com/ongakuer/hyper_transition/main/screenshot/native.gif)


