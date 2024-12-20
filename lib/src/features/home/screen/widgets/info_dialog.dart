import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/utils/context_extension.dart';

class InfoDialog extends StatelessWidget {
  const InfoDialog({super.key, required this.device});

  final ScanResult device;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text(
          device.device.advName,
          style: context.textTheme.titleLarge,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text("Mac Address: ", style: context.textTheme.titleMedium),
              Text(device.device.remoteId.str),
            ],
          ),
          Row(
            children: [
              Text("Signal Power: ", style: context.textTheme.titleMedium),
              Text("${device.rssi * -1}%"),
            ],
          ),
          Row(
            children: [
              Text("Connected: ", style: context.textTheme.titleMedium),
              Text(device.device.isConnected.toString()),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text("Cancel"),
        ),
        device.device.isConnected
            ? TextButton(
                onPressed: () => context.pop(false),
                child: const Text("Disconnect"),
              )
            : TextButton(
                onPressed: () {
                  if (device.advertisementData.connectable) {
                    context.pop(true);
                  } else {
                    context.pop();
                  }
                },
                child: const Text("Connect"),
              ),
      ],
    );
  }
}
