import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../common/model/bluetooth_model.dart';
import '../../../common/utils/context_extension.dart';
import 'widgets/info_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final StreamSubscription<bool> isScanningStream;
  late final StreamSubscription<BluetoothAdapterState> subscription;
  late final StreamSubscription<List<ScanResult>> scanner;
  List<BluetoothModel> devices = [];
  bool isScanning = false;

  Future<void> startMain() async {
    if (Platform.isAndroid) {
      await requestBluetooth();
    }
    isScanningStream = FlutterBluePlus.isScanning.listen((e) {
      isScanning = e;
      if (mounted) {
        setState(() {});
      }
    });
    subscription = FlutterBluePlus.adapterState.listen((event) async {
      if (event == BluetoothAdapterState.on) {
        log("Bluetooth is on");
        startScan();
      }
    });
  }

  Future<void> requestBluetooth() async {
    if (await Permission.bluetoothScan.isDenied) {
      await Permission.bluetoothScan.request();
    }
    if (await Permission.bluetoothConnect.isDenied) {
      await Permission.bluetoothConnect.request();
    }
    if (await Permission.location.isDenied) {
      await Permission.location.request();
    }
    await FlutterBluePlus.turnOn();
    await FlutterBluePlus.adapterState
        .where((val) => val == BluetoothAdapterState.on)
        .first;
  }

  Future<void> startScan() async {
    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 10),
      androidUsesFineLocation: true,
    );
    scanner = FlutterBluePlus.onScanResults.listen(
      sortDeviceList,
      onError: (e) => log('Error: $e'),
    );
    FlutterBluePlus.cancelWhenScanComplete(subscription);
  }

  void sortDeviceList(List<ScanResult> ev) {
    if (ev.isNotEmpty) {
      devices = ev
          .where(
            (e) => e.device.platformName != "",
          )
          .map((e) => BluetoothModel.toModel(e))
          .toList();
      devices.sort((a, b) => a.model.rssi > b.model.rssi ? 1 : -1);
      setState(() {});
    }
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    FlutterBluePlus.cancelWhenScanComplete(subscription);
  }

  void tryConnect(BuildContext context, int i) async {
    devices[i] = devices[i].copyWith(isConnecting: true);
    setState(() {});
    for (int j = 0; j < 3; j++) {
      try {
        await Future.delayed(
          const Duration(seconds: 1),
        );
        await devices[i].model.device.connect(autoConnect: false);
        devices[i] = devices[i].copyWith(isConnecting: false);
        setState(() {});
        break;
      } on Object catch (e) {
        log(e.toString());
        if (j == 2 && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Couldn't connect to ${devices[i].model.device.platformName}",
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }
      }
    }
    devices[i] = devices[i].copyWith(isConnecting: false);
    setState(() {});
  }

  void tryDisconnect(int i) async {
    devices[i] = devices[i].copyWith(isConnecting: true);
    setState(() {});
    await devices[i].model.device.disconnect();
    devices[i] = devices[i].copyWith(isConnecting: false);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    startMain();
  }

  @override
  void dispose() {
    subscription.cancel();
    isScanningStream.cancel();
    scanner.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Found Devices",
          style: context.textTheme.titleLarge,
        ),
        actions: [
          isScanning
              ? IconButton(
                  onPressed: stopScan,
                  icon: const FaIcon(FontAwesomeIcons.stop),
                )
              : IconButton(
                  onPressed: startScan,
                  icon: const FaIcon(FontAwesomeIcons.rotateLeft),
                ),
          const SizedBox(width: 20),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => await startScan(),
        child: ListView(
          children: [
            for (int i = 0; i < devices.length; i++)
              ListTile(
                visualDensity: const VisualDensity(vertical: 1),
                onTap: () async {
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (context) => InfoDialog(
                      device: devices[i].model,
                    ),
                  );
                  if (result == true && context.mounted) {
                    tryConnect(context, i);
                  } else if (result == false && context.mounted) {
                    tryDisconnect(i);
                  }
                },
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        devices[i].model.device.platformName,
                        style: context.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "${devices[i].model.rssi * -1}%",
                      style: context.textTheme.titleMedium,
                    ),
                  ],
                ),
                subtitle: Text(devices[i].model.device.remoteId.str),
                trailing: devices[i].isConnecting
                    ? OutlinedButton(
                        onPressed: () {},
                        child: const CircularProgressIndicator(),
                      )
                    : devices[i].model.device.isConnected
                        ? OutlinedButton(
                            onPressed: () => tryDisconnect(i),
                            child: const Text("Connected"),
                          )
                        : devices[i].model.advertisementData.connectable
                            ? FilledButton(
                                onPressed: () => tryConnect(context, i),
                                child: const Text("Connect"),
                              )
                            : FilledButton(
                                style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                    context.colors.primaryContainer,
                                  ),
                                  overlayColor: WidgetStateColor.transparent,
                                ),
                                onPressed: () {},
                                child: const Text("Connect"),
                              ),
              ),
            isScanning
                ? const Center(child: CircularProgressIndicator.adaptive())
                : const SizedBox()
          ],
        ),
      ),
    );
  }
}
