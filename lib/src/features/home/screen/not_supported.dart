import 'package:flutter/material.dart';

class NotSupported extends StatelessWidget {
  const NotSupported({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Your device is not supported for bluetooth service"),
      ),
    );
  }
}
