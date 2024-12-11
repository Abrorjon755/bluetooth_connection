import 'package:flutter/material.dart';
import 'package:hangman/src/common/widgets/initialize_app.dart';
import 'package:hangman/src/common/widgets/my_app.dart';
import 'package:hangman/src/common/widgets/my_app_scope.dart';

Future<void> main() async {
  final dependency = await InitializeApp.initialize();

  runApp(
    MyAppScope(
      dependency: dependency,
      child: const MyApp(),
    ),
  );
}
