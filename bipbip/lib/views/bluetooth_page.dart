import 'package:flutter/material.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:bipbip/services/bluetooth_service.dart';
import 'dart:async';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  @override
  _BluetoothPageState createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  final BluetoothService _bt = BluetoothService();
  late StreamSubscription<int> _statusSub;

  List<Device> _devices = [];
  int _deviceStatus = Device.disconnected;

  @override
  void initState() {
    super.initState();
    _statusSub = _bt.statusStream.listen((status) {
      setState(() => _deviceStatus = status);
    });
  }

  @override
  void dispose() {
    _statusSub.cancel();
    super.dispose();
  }

  Future<void> _getDevices() async {
    final res = await _bt.getPairedDevices();
    setState(() => _devices = res);
  }

  Future<void> _resetAlarms() async {
    try {
      await _bt.write("reset");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Alarmes réinitialisées.")),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur Bluetooth.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = _deviceStatus == Device.connected;

    return Scaffold(
      appBar: AppBar(title: const Text('Gestion du Bluetooth')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isConnected ? "✅ Appareil connecté" : "❌ Aucun appareil connecté",
              style: TextStyle(
                fontSize: 18,
                color: isConnected ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _bt.initPermissions,
              icon: const Icon(Icons.lock_open),
              label: const Text("Autoriser le Bluetooth"),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _getDevices,
              icon: const Icon(Icons.devices),
              label: const Text("Afficher les appareils appairés"),
            ),
            const SizedBox(height: 10),
            if (isConnected)
              ElevatedButton.icon(
                onPressed: _resetAlarms,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                icon: const Icon(Icons.restart_alt),
                label: const Text("Réinitialiser les alarmes"),
              ),
            const SizedBox(height: 10),
            if (isConnected)
              ElevatedButton.icon(
                onPressed: _bt.disconnect,
                icon: const Icon(Icons.link_off),
                label: const Text("Déconnecter l’appareil"),
              ),
            const SizedBox(height: 20),
            const Text("Appareils disponibles :", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _devices.length,
                itemBuilder: (_, i) {
                  final d = _devices[i];
                  return Card(
                    child: ListTile(
                      title: Text(d.name ?? 'Sans nom'),
                      subtitle: Text(d.address),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          await _bt.connect(d.address);
                          setState(() => _devices.clear());
                        },
                        child: const Text("Se connecter"),
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
