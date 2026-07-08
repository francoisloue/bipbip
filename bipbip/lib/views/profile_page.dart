import 'package:bipbip/config/app_config.dart';
import 'package:bipbip/services/user.dart';
import 'package:flutter/material.dart';
import 'package:bipbip/models/user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _config = AppConfig();
  final _userService = UserService();
  final _userIdController = TextEditingController();

  User? _user;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _userIdController.text = _config.userId.toString();
    _loadUser();
  }

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    setState(() => _isLoading = true);
    try {
      final user = await _userService.getUserById(_config.userId);
      if (mounted) setState(() => _user = user);
    } catch (_) {
      if (mounted) setState(() => _user = null);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _changeUserId() {
    showDialog(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController(text: _config.userId.toString());
        return AlertDialog(
          title: const Text("Changer d'utilisateur"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'ID utilisateur',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                final id = int.tryParse(controller.text);
                if (id != null && id > 0) {
                  _config.setUserId(id);
                  _userIdController.text = id.toString();
                  Navigator.pop(ctx);
                  _loadUser();
                }
              },
              child: const Text('Appliquer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(Icons.person, size: 40, color: Colors.blue.shade700),
                  ),
                  const SizedBox(height: 12),
                  Text(_user?.name ?? _user?.surname ?? "Utilisateur",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  if (_user != null) ...[
                    const SizedBox(height: 4),
                    Text("${_user!.surname} ${_user!.name}",
                        style: TextStyle(fontSize: 15, color: Colors.grey.shade600)),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Mon ID utilisateur'),
                  subtitle: Text('#${_config.userId}',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue.shade700)),
                  trailing: const Icon(Icons.edit),
                  onTap: _changeUserId,
                ),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_user != null) ...[
                  Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.cake),
                    title: const Text('Âge'),
                    trailing: Text("${_user!.age} ans"),
                  ),
                  Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.monitor_weight),
                    title: const Text('Poids'),
                    trailing: Text("${_user!.weight} kg"),
                  ),
                  Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.straighten),
                    title: const Text('Taille'),
                    trailing: Text("${_user!.height} cm"),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: SwitchListTile(
              secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
              title: Text(isDark ? 'Mode sombre' : 'Mode clair'),
              value: isDark,
              onChanged: (_) {
                _config.toggleTheme();
              },
            ),
          ),
        ],
      ),
    );
  }
}
