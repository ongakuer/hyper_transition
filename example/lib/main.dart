import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hyper_transition/hyper_transition.dart';
import 'package:window_rounded_corners/window_rounded_corners.dart';

void main() {
  runApp(const HyperApp());
}

final appRouter = GoRouter(initialLocation: "/a", routes: [
  GoRoute(path: "/a", builder: (context, state) => const ScreenA()),
  GoRoute(path: "/b", builder: (context, state) => const ScreenB())
]);

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

class ScreenA extends StatelessWidget {
  const ScreenA({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Screen A")),
        body: Center(
            child: FilledButton(
                onPressed: () {
                  context.push("/b");
                },
                child: const Text("Next Page"))));
  }
}

class ScreenB extends StatelessWidget {
  const ScreenB({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Screen B")),
        body: SafeArea(
          child: Column(
            children: [
              const Expanded(
                  child: Center(
                child: RotateEndlessBox(),
              )),
              Align(
                  alignment: Alignment.center,
                  child: FilledButton(
                      onPressed: () {
                        context.push("/a");
                      },
                      child: const Text("Next Page"))),
            ],
          ),
        ));
  }
}

class RotateEndlessBox extends StatefulWidget {
  const RotateEndlessBox({super.key});

  @override
  State<StatefulWidget> createState() => _RotateEndlessBoxState();
}

class _RotateEndlessBoxState extends State<RotateEndlessBox>
    with SingleTickerProviderStateMixin {
  static final Tween<double> degreesTween = Tween(begin: 0, end: 360);
  late AnimationController controller;

  @override
  void initState() {
    controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    controller.repeat();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Transform.rotate(
              angle: (degreesTween.evaluate(controller)) * pi / 180,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.amberAccent,
                child: const Center(
                    child: Text("A", style: TextStyle(fontSize: 20))),
              ));
        });
  }
}
