import 'dart:async';
import 'package:bipbip/config/app_config.dart';
import 'package:bipbip/models/event.dart';
import 'package:bipbip/models/newEvent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:bipbip/models/medication.dart';
import 'package:bipbip/services/event.dart';
import 'package:bipbip/services/medication.dart';
import 'package:bipbip/controllers/ble_sync_controller.dart';

class CreateEventScreen extends StatefulWidget {
  final Event? event;

  const CreateEventScreen({super.key, this.event});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _eventService = EventService();
  final _medicationService = MedicationService();
  final _bleService = BleService();
  final _medicationSearchController = TextEditingController();

  late final bool _isEditing;

  String _name = '';
  String? _description;
  DateTime? _takePillDate;
  Medication? _selectedMedication;
  String _selectedFrequency = 'daily';
  Timer? _debounce;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.event != null;
    if (_isEditing) {
      final e = widget.event!;
      _name = e.name;
      _description = e.description;
      _takePillDate = e.takePillDate;
      _selectedFrequency = e.frequency;
      _selectedMedication = e.medication;
      if (_selectedMedication != null) {
        _medicationSearchController.text = _selectedMedication!.name;
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _medicationSearchController.dispose();
    super.dispose();
  }

  bool get _canSubmit => _name.isNotEmpty && _takePillDate != null && _selectedMedication != null;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _canSubmit) {
      _formKey.currentState!.save();

      final config = AppConfig();
      NewEvent newEvent = NewEvent(
        id: _isEditing ? widget.event!.id : null,
        userId: config.userId,
        name: _name,
        description: _description ?? '',
        frequency: _selectedFrequency,
        isActive: true,
        medicationId: _selectedMedication!.id,
        takePillDate: _takePillDate!,
      );

      try {
        if (_isEditing) {
          await _eventService.updateEvent(newEvent);
        } else {
          await _eventService.createEvent(newEvent);
        }

        final connectedDevice = _bleService.getConnectedDevice();
        if (connectedDevice != null) {
          final hour = newEvent.takePillDate?.hour.toString().padLeft(2, '0');
          final minute = newEvent.takePillDate?.minute.toString().padLeft(2, '0');
          try {
            await _bleService.write("$hour,$minute,00");
          } catch (e) {
            // silent
          }
        }

        HapticFeedback.lightImpact();
        if (!context.mounted) return;
        Navigator.pop(context, true);
      } catch (error) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $error'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier l\'événement' : 'Nouvel événement'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(Icons.info_outline, 'Informations'),
                const SizedBox(height: 8),
                _buildCard(
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _isEditing ? widget.event!.name : null,
                        decoration: const InputDecoration(
                          labelText: "Nom de l'événement",
                          hintText: 'ex: Anti-inflammatoire matin',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.event),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Nom requis' : null,
                        onChanged: (value) => setState(() => _name = value),
                        onSaved: (value) => _name = value!,
                        textInputAction: TextInputAction.next,
                      ),
                      Divider(height: 1, color: Colors.grey.shade200),
                      TextFormField(
                        initialValue: _isEditing ? widget.event!.description : null,
                        decoration: const InputDecoration(
                          labelText: 'Description (facultatif)',
                          hintText: 'Notes supplémentaires...',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                        onSaved: (value) => _description = value,
                        textInputAction: TextInputAction.next,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(Icons.schedule, 'Programmation'),
                const SizedBox(height: 8),
                _buildCard(
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Fréquence',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.repeat),
                        ),
                        value: _selectedFrequency,
                        items: const [
                          DropdownMenuItem(value: 'daily', child: Text('Quotidien')),
                          DropdownMenuItem(value: 'weekly', child: Text('Hebdomadaire')),
                        ],
                        onChanged: (value) => setState(() => _selectedFrequency = value!),
                      ),
                      Divider(height: 1, color: Colors.grey.shade200),
                      InkWell(
                        onTap: _pickDateTime,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 12),
                                child: Icon(Icons.access_time),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Date et heure de prise',
                                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _takePillDate == null
                                          ? 'Appuyer pour choisir'
                                          : DateFormat('EEEE d MMMM yyyy – HH:mm', 'fr')
                                              .format(_takePillDate!).splitMapJoin(
                                                  RegExp(r'^\w'),
                                                  onMatch: (m) => m.group(0)!.toUpperCase()),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: _takePillDate != null
                                            ? Colors.blue.shade700
                                            : Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_takePillDate != null)
                                Icon(Icons.edit_calendar, color: Colors.blue.shade400, size: 20)
                              else
                                Icon(Icons.chevron_right, color: Colors.grey.shade400),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_takePillDate != null) ...[
                  const SizedBox(height: 10),
                  Center(
                    child: Chip(
                      avatar: Icon(Icons.notifications_active, size: 18, color: Colors.blue.shade700),
                      label: Text(
                        'Première prise : ${DateFormat('HH:mm').format(_takePillDate!)}',
                        style: TextStyle(fontSize: 13, color: Colors.blue.shade700),
                      ),
                      backgroundColor: Colors.blue.shade50,
                      side: BorderSide.none,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                _buildSectionHeader(Icons.medical_services_outlined, 'Médicament'),
                const SizedBox(height: 8),
                _buildCard(
                  child: Column(
                    children: [
                      _buildMedicationSearch(),
                      if (_selectedMedication != null) ...[
                        Divider(height: 1, color: Colors.grey.shade200),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(opacity: animation, child: SizeTransition(
                                sizeFactor: animation,
                                axisAlignment: -1.0,
                                child: child,
                              )),
                          child: Padding(
                            key: ValueKey(_selectedMedication!.id),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.check_circle, color: Colors.green.shade600, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedMedication!.name,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                      ),
                                      if (_selectedMedication!.dosageSummary.isNotEmpty)
                                        Text(
                                          _selectedMedication!.dosageSummary,
                                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                        ),
                                      Text(
                                        _selectedMedication!.formePharmaceutique,
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _canSubmit ? _submitForm : null,
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(
                      _isEditing ? "Enregistrer les modifications" : "Créer l'événement",
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      disabledForegroundColor: Colors.grey.shade500,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: _canSubmit ? 2 : 0,
                    ),
                  ),
                ),
                if (!_canSubmit) ...[
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      _buildMissingFieldsHint(),
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue.shade700),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.blue.shade700,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: child,
      ),
    );
  }

  Widget _buildMedicationSearch() {
    return Autocomplete<Medication>(
      displayStringForOption: (Medication m) => m.name,
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<Medication>.empty();
        }
        final completer = Completer<Iterable<Medication>>();
        _debounce?.cancel();
        setState(() => _isSearching = true);
        _debounce = Timer(const Duration(milliseconds: 600), () async {
          try {
            final results = await _medicationService.searchMedications(textEditingValue.text);
            completer.complete(results);
          } catch (e) {
            completer.complete(const Iterable<Medication>.empty());
          } finally {
            if (mounted) setState(() => _isSearching = false);
          }
        });
        return completer.future;
      },
      onSelected: (Medication selection) {
        setState(() {
          _selectedMedication = selection;
          _medicationSearchController.text = selection.name;
        });
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Rechercher un médicament',
            hintText: 'Taper le nom du médicament...',
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _isSearching
                ? Padding(
                    padding: const EdgeInsets.all(14),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue.shade400),
                    ),
                  )
                : controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          controller.clear();
                          setState(() => _selectedMedication = null);
                        },
                      )
                    : null,
          ),
          onChanged: (_) {
            if (_selectedMedication != null) {
              setState(() => _selectedMedication = null);
            }
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 300,
                maxWidth: MediaQuery.of(context).size.width - 40,
              ),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 4),
                shrinkWrap: true,
                children: [
                  ...options.map((med) => InkWell(
                    onTap: () => onSelected(med),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.medication, size: 18, color: Colors.blue.shade600),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(med.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                if (med.dosageSummary.isNotEmpty)
                                  Text(med.dosageSummary, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                Text(med.formePharmaceutique, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
                  if (options.isEmpty && !_isSearching) ...[
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.medication, size: 32, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text("Aucun médicament trouvé",
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.pushNamed(context, '/create-medication');
                              if (result == true && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Médicament créé !')),
                                );
                              }
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Créer un nouveau médicament'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDateTime() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: _takePillDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      helpText: 'Choisir la date',
      cancelText: 'Annuler',
      confirmText: 'Suivant',
    );
    if (date == null || !context.mounted) return;

    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_takePillDate ?? DateTime.now()),
      helpText: "Choisir l'heure",
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
    );
    if (time == null) return;

    setState(() {
      _takePillDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  String _buildMissingFieldsHint() {
    final missing = <String>[];
    if (_name.isEmpty) missing.add("nom");
    if (_takePillDate == null) missing.add("date");
    if (_selectedMedication == null) missing.add("médicament");
    return "Renseigne ${missing.join(', ')} pour activer la création";
  }
}
