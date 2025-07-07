import 'dart:async';
import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;

  final BluetoothClassic _bluetooth = BluetoothClassic();
  final StreamController<int> _statusController =
      StreamController<int>.broadcast();

  int _deviceStatus = Device.disconnected;

  BluetoothService._internal() {
    _bluetooth.onDeviceStatusChanged().listen((status) {
      _deviceStatus = status;
      _statusController.add(status);
    });
  }

  Stream<int> get statusStream => _statusController.stream;
  int get currentStatus => _deviceStatus;

  Future<void> initPermissions() => _bluetooth.initPermissions();
  Future<List<Device>> getPairedDevices() => _bluetooth.getPairedDevices();
  Future<void> connect(String address) => _bluetooth.connect(
        address,
        "00001101-0000-1000-8000-00805f9b34fb",
      );
  Future<void> disconnect() => _bluetooth.disconnect();
  Future<void> write(String data) => _bluetooth.write(data);
}
