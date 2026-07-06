import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:bipbip/models/event.dart';

class BleService {
  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;
  BleService._internal();

  static const String _uartServiceUuid = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
  static const String _txCharacteristicUuid = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _txCharacteristic;

  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  Future<void> startScan() async {
    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 15),
      androidUsesFineLocation: true,
    );
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  Future<void> connect(BluetoothDevice device) async {
    await device.connect(license: License.nonprofit, timeout: const Duration(seconds: 30));
    await device.discoverServices();
    _connectedDevice = device;
    _txCharacteristic = _findTxCharacteristic(device);
  }

  Future<void> disconnect(BluetoothDevice device) async {
    await device.disconnect();
    if (_connectedDevice != null && _connectedDevice!.remoteId == device.remoteId) {
      _connectedDevice = null;
      _txCharacteristic = null;
    }
  }

  BluetoothDevice? getConnectedDevice() => _connectedDevice;

  Future<void> write(String data) async {
    if (_connectedDevice == null) {
      throw Exception("Aucun appareil connecté");
    }
    if (_txCharacteristic == null) {
      await _connectedDevice!.discoverServices();
      _txCharacteristic = _findTxCharacteristic(_connectedDevice!);
    }
    await _writeWithFallback(_txCharacteristic!, data);
  }

  Future<void> writeToDevice(BluetoothDevice device, String data) async {
    final services = await device.discoverServices();
    final uartService = services.firstWhere(
      (s) => s.uuid.toString().toLowerCase() == _uartServiceUuid,
      orElse: () => throw Exception("Service UART non trouvé sur l'appareil"),
    );
    final txChar = uartService.characteristics.firstWhere(
      (c) => c.uuid.toString().toLowerCase() == _txCharacteristicUuid,
      orElse: () => throw Exception("Caractéristique TX non trouvée"),
    );
    await _writeWithFallback(txChar, data);
  }

  Future<void> _writeWithFallback(BluetoothCharacteristic characteristic, String data) async {
    if (characteristic.properties.writeWithoutResponse) {
      await characteristic.write(data.codeUnits, withoutResponse: true);
    } else {
      await characteristic.write(data.codeUnits, withoutResponse: false);
    }
  }

  BluetoothCharacteristic? _findTxCharacteristic(BluetoothDevice device) {
    for (final service in device.servicesList) {
      if (service.uuid.toString().toLowerCase() == _uartServiceUuid) {
        for (final characteristic in service.characteristics) {
          if (characteristic.uuid.toString().toLowerCase() == _txCharacteristicUuid) {
            return characteristic;
          }
        }
      }
    }
    return null;
  }
}

class BleSyncController {
  final BleService _bleService = BleService();

  Future<void> syncToDevice(BluetoothDevice device, List<Event> events) async {
    final now = DateTime.now();
    final endOfPeriod = now.add(const Duration(hours: 24));
    final List<String> times = [];

    for (final event in events) {
      if (event.isActive && event.takePillDate != null) {
        DateTime next = event.takePillDate!;
        while (next.isBefore(now)) {
          if (event.frequency == 'daily') {
            next = next.add(const Duration(days: 1));
          } else if (event.frequency == 'weekly') {
            next = next.add(const Duration(days: 7));
          } else {
            break;
          }
        }
        if (next.isBefore(endOfPeriod)) {
          final h = next.hour.toString().padLeft(2, '0');
          final m = next.minute.toString().padLeft(2, '0');
          times.add("$h,$m,00");
        }
      }
    }

    if (times.isNotEmpty) {
      await _bleService.writeToDevice(device, times.join(";"));
    }
  }
}
