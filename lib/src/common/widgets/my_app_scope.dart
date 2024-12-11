import 'package:flutter/material.dart';
import 'package:hangman/src/common/dependency/dependency.dart';

class MyAppScope extends StatefulWidget {
  const MyAppScope({
    super.key,
    required this.dependency,
    required this.child,
  });

  final AppDependency dependency;
  final Widget child;

  @override
  State<MyAppScope> createState() => MyAppScopeState();
}

class MyAppScopeState extends State<MyAppScope> {
  late final AppDependency dependency;

  @override
  void initState() {
    super.initState();
    dependency = widget.dependency;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
