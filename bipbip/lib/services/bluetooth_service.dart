import 'dart:async';
import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;

  final BluetoothClassic _bluetooth = BluetoothClassic();
  final StreamController<int> _statusController = StreamController<int>.broadcast();

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
        "00001101-0000-1000-8000-00805f9b34fb", // Standard SPP UUID
      );

  Future<void> sync24hSchedule(List<dynamic> events) async {
    // Logic to calculate 24h schedule and send as HH,mm,ss;HH,mm,ss...
    // This maintains the feature from our previous discussion
    // but using the Classic Bluetooth 'write' method.
    final now = DateTime.now();
    final endOfPeriod = now.add(const Duration(hours: 24));
    List<String> times = [];

    for (var event in events) {
      if (event.isActive && event.takePillDate != null) {
        DateTime next = event.takePillDate!;
        // Simple logic for Daily/Weekly
        while (next.isBefore(now)) {
          if (event.frequency == 'daily') next = next.add(const Duration(days: 1));
          else if (event.frequency == 'weekly') next = next.add(const Duration(days: 7));
          else break;
        }
        if (next.isBefore(endOfPeriod)) {
          final h = next.hour.toString().padLeft(2, '0');
          final m = next.minute.toString().padLeft(2, '0');
          times.add("$h,$m,00");
        }
      }
    }
    if (times.isNotEmpty) {
      await write(times.join(";"));
    }
  }
      
  Future<void> disconnect() => _bluetooth.disconnect();
  Future<void> write(String data) => _bluetooth.write(data);
}
