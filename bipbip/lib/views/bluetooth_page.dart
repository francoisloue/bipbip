import 'package:bipbip/controllers/ble_sync_controller.dart';
import 'package:bipbip/services/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  @override
  _BluetoothPageState createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  final BleService _bleService = BleService();
  final BleSyncController _syncController = BleSyncController();
  final EventService _eventService = EventService();

  List<ScanResult> _scanResults = [];
  late StreamSubscription<List<ScanResult>> _scanSubscription;
  bool _isScanning = false;
  BluetoothDevice? _connectedDevice;

  @override
  void initState() {
    super.initState();
    _scanSubscription = _bleService.scanResults.listen((results) {
      setState(() => _scanResults = results);
    });

    FlutterBluePlus.isScanning.listen((scanning) {
      setState(() => _isScanning = scanning);
    });

    final connectedDevices = FlutterBluePlus.connectedDevices;
    if (connectedDevices.isNotEmpty) {
      setState(() => _connectedDevice = connectedDevices.first);
    }
  }

  @override
  void dispose() {
    _scanSubscription.cancel();
    super.dispose();
  }

  Future<void> _startScan() async {
    setState(() => _scanResults.clear());
    await _bleService.startScan();
  }

  Future<void> _connect(BluetoothDevice device) async {
    try {
      await _bleService.connect(device);
      setState(() => _connectedDevice = device);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connecté à ${device.platformName}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de connexion : $e")),
      );
    }
  }

  Future<void> _syncEvents() async {
    if (_connectedDevice == null) return;

    try {
      final events = await _eventService.fetchUserEvents(2);
      await _syncController.syncToDevice(_connectedDevice!, events);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Synchronisation réussie !")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de synchronisation : $e")),
      );
    }
  }

  Future<void> _testBeep() async {
    if (_connectedDevice == null) return;
    try {
      await _bleService.write("on");
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bip dans 5s envoyé !")),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }
  }

  Widget _rssiIndicator(int rssi) {
    final bars = rssi >= -50 ? 4 : rssi >= -65 ? 3 : rssi >= -80 ? 2 : rssi >= -90 ? 1 : 0;
    final color = bars >= 3 ? Colors.green : bars >= 2 ? Colors.orange : Colors.red;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (i) {
        return Container(
          width: 4,
          height: 6 + i * 3,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: i < bars ? color : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion du Bluetooth (BLE)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_connectedDevice != null) ...[
              Text(
                "✅ Connecté à : ${_connectedDevice!.platformName}",
                style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _syncEvents,
                icon: const Icon(Icons.sync),
                label: const Text("Synchroniser les alarmes (24h)"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade100),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _testBeep,
                icon: const Icon(Icons.notifications_active),
                label: const Text("TEST +5s"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade100),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  await _bleService.disconnect(_connectedDevice!);
                  setState(() => _connectedDevice = null);
                },
                icon: const Icon(Icons.link_off),
                label: const Text("Déconnecter"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade100),
              ),
            ] else ...[
              const Text("❌ Aucun appareil connecté", style: TextStyle(fontSize: 18, color: Colors.red)),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Appareils BLE à proximité :", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (_isScanning)
                  const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                else
                  IconButton(onPressed: _startScan, icon: const Icon(Icons.refresh)),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _scanResults.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bluetooth_searching, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text("Aucun appareil trouvé",
                              style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                          const SizedBox(height: 4),
                          Text("Appuie sur Actualiser pour lancer un scan",
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                        ],
                      ),
                    )
                  : ListView.builder(
                itemCount: _scanResults.length,
                itemBuilder: (_, i) {
                  final r = _scanResults[i];
                  final name = r.device.platformName.isEmpty ? "Inconnu" : r.device.platformName;
                  final isConnected = _connectedDevice?.remoteId == r.device.remoteId;
                  return Card(
                    child: ListTile(
                      leading: isConnected
                          ? const Icon(Icons.link, color: Colors.green)
                          : null,
                      title: Text(name),
                      subtitle: Row(
                        children: [
                          _rssiIndicator(r.rssi),
                          const SizedBox(width: 6),
                          Text('${r.rssi} dBm', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                        ],
                      ),
                      trailing: isConnected
                          ? const Icon(Icons.check, color: Colors.green)
                          : ElevatedButton(
                            onPressed: () => _connect(r.device),
                            child: const Text("Connecter"),
                          ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
