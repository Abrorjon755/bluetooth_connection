import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothModel {
  final ScanResult model;
  final bool isConnecting;
  final bool isConnected;

  const BluetoothModel({
    required this.model,
    this.isConnecting = false,
    this.isConnected = false,
  });

  static BluetoothModel toModel(ScanResult model) =>
      BluetoothModel(model: model);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BluetoothModel &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          isConnecting == other.isConnecting &&
          isConnected == other.isConnected;

  BluetoothModel copyWith({
    ScanResult? model,
    bool? isConnecting,
    bool? isConnected,
  }) {
    return BluetoothModel(
      model: model ?? this.model,
      isConnecting: isConnecting ?? this.isConnecting,
      isConnected: isConnected ?? this.isConnected,
    );
  }

  @override
  int get hashCode => Object.hash(
        model,
        isConnected,
        isConnecting,
      );
}
