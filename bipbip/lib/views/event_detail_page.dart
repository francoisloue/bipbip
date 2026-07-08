import 'package:bipbip/views/create_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:bipbip/models/event.dart';
import 'package:bipbip/controllers/event_controller.dart';
import 'package:bipbip/services/medication.dart';
import 'package:bipbip/services/event.dart';

class EventDetailPage extends StatefulWidget {
  final Event event;
  const EventDetailPage({super.key, required this.event});

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late Event _event;
  final EventController _eventController =
      EventController(EventService(), MedicationService());

  @override
  void initState() {
    super.initState();
    _event = widget.event;
  }

  void _edit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateEventScreen(event: _event)),
    );
    if (result == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  void _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer l\'événement ?'),
        content: Text('« ${_event.name} » sera définitivement supprimé.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _eventController.deleteEvent(_event.id!);
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = _event.takePillDate != null
        ? DateFormat('EEEE d MMMM yyyy – HH:mm', 'fr').format(_event.takePillDate!)
        : 'Date non définie';
    final med = _event.medication;

    return Scaffold(
      appBar: AppBar(
        title: Text(_event.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Modifier',
            onPressed: _edit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Supprimer',
            onPressed: _delete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Carte heure
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.access_time, size: 40, color: Colors.blue.shade700),
                  const SizedBox(height: 12),
                  Text(
                    _event.takePillDate != null
                        ? DateFormat('HH:mm').format(_event.takePillDate!)
                        : '--:--',
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                  ),
                  const SizedBox(height: 4),
                  Text(timeStr, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  Chip(
                    avatar: Icon(_event.frequency == 'daily' ? Icons.repeat : Icons.repeat_one,
                        size: 16, color: Colors.blue.shade700),
                    label: Text(_event.frequency == 'daily' ? 'Quotidien' : 'Hebdomadaire',
                        style: TextStyle(color: Colors.blue.shade700)),
                    backgroundColor: Colors.blue.shade50,
                    side: BorderSide.none,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context, {'taken': true, 'id': _event.id});
                      },
                      icon: const Icon(Icons.check_circle, size: 20),
                      label: const Text('Marquer comme pris',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Carte médicament
          if (med != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.medication, size: 28, color: Colors.green.shade700),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(med.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                          if (med.dosageSummary.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(med.dosageSummary, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                            ),
                          Text(med.formePharmaceutique,
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                    if (med.noticeUrl != null && med.noticeUrl!.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.description_outlined),
                        tooltip: 'Copier le lien de la notice',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: med.noticeUrl!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Lien de la notice copié'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          if (med == null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    Text('Médicament non disponible', style: TextStyle(color: Colors.orange.shade700)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Description
          if (_event.description.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.description_outlined, size: 18, color: Colors.grey.shade700),
                        const SizedBox(width: 8),
                        Text('Description', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_event.description, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                  ],
                ),
              ),
            ),

          // Image
          if (med?.imageUrl != null && med!.imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.image_outlined, size: 18, color: Colors.grey.shade700),
                        const SizedBox(width: 8),
                        Text('Image', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        med.imageUrl!,
                        height: 120,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          height: 120,
                          color: Colors.grey.shade100,
                          child: const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
