import 'package:bipbip/controllers/ble_sync_controller.dart';
import 'package:bipbip/services/medication.dart';
import 'package:bipbip/views/create_event.dart';
import 'package:bipbip/views/event_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:bipbip/models/event.dart';
import 'package:bipbip/controllers/event_controller.dart';
import 'package:bipbip/services/event.dart';

class EventListView extends StatefulWidget {
  final int userId;
  const EventListView({super.key, required this.userId});

  @override
  _EventListViewState createState() => _EventListViewState();
}

class _EventListViewState extends State<EventListView> with TickerProviderStateMixin {
  late Future<List<Event>> futureEvents;
  final EventController eventController =
      EventController(EventService(), MedicationService());
  final _bleService = BleService();

  final _searchController = TextEditingController();
  bool _showOnlyToday = false;
  bool _isSearching = false;
  bool _groupByMedication = false;

  final Set<int> _takenEventIds = {};

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _listFadeController;

  DateTime? _selectedCalendarDay;
  DateTime _calendarMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    futureEvents = eventController.getUserEvents(widget.userId);
    _searchController.addListener(_onSearchChanged);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _listFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _pulseController.dispose();
    _listFadeController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() => _isSearching = _searchController.text.isNotEmpty);
  }

  @override
  void didUpdateWidget(covariant EventListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      futureEvents = eventController.getUserEvents(widget.userId);
      _listFadeController.forward(from: 0);
    }
  }

  Future<void> _reloadEvents() async {
    setState(() {
      futureEvents = eventController.getUserEvents(widget.userId);
    });
    await futureEvents;
    if (mounted) {
      setState(() {});
      _listFadeController.forward(from: 0);
    }
  }

  Future<bool?> _confirmDelete(Event event) async {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer l\'événement ?'),
        content: Text('« ${event.name} » sera définitivement supprimé.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  List<Event> _filterEvents(List<Event> events) {
    var filtered = events.where((e) => e.isActive).toList();

    if (_selectedCalendarDay != null) {
      filtered = filtered.where((e) =>
        e.takePillDate != null &&
        e.takePillDate!.year == _selectedCalendarDay!.year &&
        e.takePillDate!.month == _selectedCalendarDay!.month &&
        e.takePillDate!.day == _selectedCalendarDay!.day
      ).toList();
    } else if (_showOnlyToday) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      filtered = filtered.where((e) =>
        e.takePillDate != null &&
        e.takePillDate!.year == today.year &&
        e.takePillDate!.month == today.month &&
        e.takePillDate!.day == today.day
      ).toList();
    }

    if (_isSearching) {
      final q = _searchController.text.toLowerCase();
      filtered = filtered.where((e) =>
        e.name.toLowerCase().contains(q) ||
        (e.medication?.name ?? '').toLowerCase().contains(q)
      ).toList();
    }

    filtered.sort((a, b) => a.takePillDate!.compareTo(b.takePillDate!));
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Event>>(
      future: futureEvents,
      builder: (context, snapshot) {
        final bool isLoading = snapshot.connectionState == ConnectionState.waiting;
        final bool hasError = snapshot.hasError;
        final bool isEmpty = !snapshot.hasData || snapshot.data!.isEmpty;

        List<Event> allEvents = [];
        List<Event> activeEvents = [];
        Event? nextEvent;
        List<Event> todayEvents = [];
        List<Event> displayedEvents = [];
        Map<String, List<Event>> medGrouped = {};

        if (!isLoading && !hasError && !isEmpty) {
          allEvents = snapshot.data!;
          activeEvents = allEvents.where((e) => e.isActive).toList();
          activeEvents.sort((a, b) => a.takePillDate!.compareTo(b.takePillDate!));

          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          todayEvents = activeEvents.where((e) =>
            e.takePillDate != null &&
            e.takePillDate!.year == today.year &&
            e.takePillDate!.month == today.month &&
            e.takePillDate!.day == today.day
          ).toList();

          final upcoming = activeEvents
              .where((e) => e.takePillDate != null && e.takePillDate!.isAfter(now))
              .toList()
            ..sort((a, b) => a.takePillDate!.compareTo(b.takePillDate!));
          nextEvent = upcoming.isNotEmpty ? upcoming.first : null;

          displayedEvents = _filterEvents(activeEvents);

          if (_groupByMedication) {
            for (final e in displayedEvents) {
              final key = e.medication?.name ?? 'Sans médicament';
              medGrouped.putIfAbsent(key, () => []).add(e);
            }
          }
        }

        return FadeTransition(
          opacity: _listFadeController,
          child: RefreshIndicator(
            onRefresh: _reloadEvents,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                if (isLoading)
                  _buildLoadingState()
                else if (hasError)
                  _buildErrorState(snapshot.error)
                else if (isEmpty)
                  _buildEmptyState()
                else ...[
                  _buildSearchBar(),
                  _buildHeader(DateTime.now(), allEvents),
                  _buildCalendarCard(activeEvents),
                  if (todayEvents.isNotEmpty) _buildTodayProgress(todayEvents),
                  _buildWeekSummary(activeEvents),
                  if (nextEvent != null) _buildNextEventCard(nextEvent),
                  if (_selectedCalendarDay != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Chip(
                        avatar: const Icon(Icons.calendar_today, size: 16),
                        label: Text(
                          DateFormat('d MMMM yyyy', 'fr').format(_selectedCalendarDay!),
                        ),
                        onDeleted: () => setState(() => _selectedCalendarDay = null),
                        backgroundColor: Colors.blue.shade50,
                        side: BorderSide.none,
                      ),
                    ),
                  if (_groupByMedication)
                    ...medGrouped.entries.map((entry) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              Icon(Icons.medication, size: 16, color: Colors.blue.shade700),
                              const SizedBox(width: 6),
                              Text(entry.key, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text(' (${entry.value.length})', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                        ...entry.value.map((e) => _buildEventCard(e)),
                      ],
                    ))
                  else ...[
                    if (!_showOnlyToday && _selectedCalendarDay == null) ...[
                      if (_hasDailyEvents(displayedEvents)) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text("Prises quotidiennes (${_dailyCount(displayedEvents)})",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        ..._dailyEvents(displayedEvents).map((e) => _buildEventCard(e)),
                      ],
                      if (_hasWeeklyEvents(displayedEvents)) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text("Prises hebdomadaires (${_weeklyCount(displayedEvents)})",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        ..._weeklyEvents(displayedEvents).map((e) => _buildEventCard(e)),
                      ],
                    ] else ...[
                      ...displayedEvents.map((e) => _buildEventCard(e)),
                    ],
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  bool _hasDailyEvents(List<Event> events) => events.any((e) => e.frequency == 'daily');
  bool _hasWeeklyEvents(List<Event> events) => events.any((e) => e.frequency == 'weekly');
  int _dailyCount(List<Event> events) => events.where((e) => e.frequency == 'daily').length;
  int _weeklyCount(List<Event> events) => events.where((e) => e.frequency == 'weekly').length;
  List<Event> _dailyEvents(List<Event> events) => events.where((e) => e.frequency == 'daily').toList();
  List<Event> _weeklyEvents(List<Event> events) => events.where((e) => e.frequency == 'weekly').toList();

  Widget _buildCalendarCard(List<Event> events) {
    final now = DateTime.now();
    final firstDay = DateTime(_calendarMonth.year, _calendarMonth.month, 1);
    final lastDay = DateTime(_calendarMonth.year, _calendarMonth.month + 1, 0);
    final startWeekday = firstDay.weekday % 7;

    final daysWithEvents = <int>{};
    for (final e in events) {
      if (e.takePillDate != null &&
          e.takePillDate!.year == _calendarMonth.year &&
          e.takePillDate!.month == _calendarMonth.month) {
        daysWithEvents.add(e.takePillDate!.day);
      }
    }

    final takenDays = <int>{};
    for (final e in events) {
      if (e.takePillDate != null &&
          e.takePillDate!.year == _calendarMonth.year &&
          e.takePillDate!.month == _calendarMonth.month &&
          _takenEventIds.contains(e.id)) {
        takenDays.add(e.takePillDate!.day);
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() => _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month - 1)),
                ),
                Text(
                  DateFormat('MMMM yyyy', 'fr').format(_calendarMonth).splitMapJoin(
                    RegExp(r'^\w'),
                    onMatch: (m) => m.group(0)!.toUpperCase(),
                  ),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => setState(() => _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month + 1)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM', 'DIM']
                  .map((d) => SizedBox(
                    width: 30,
                    child: Text(d, textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey.shade500)),
                  ))
                  .toList(),
            ),
            const SizedBox(height: 4),
            ...List.generate(6, (row) {
              final children = <Widget>[];
              for (int col = 0; col < 7; col++) {
                final dayNum = row * 7 + col - startWeekday + 1;
                if (dayNum < 1 || dayNum > lastDay.day) {
                  children.add(const SizedBox(width: 30, height: 30));
                } else {
                  final date = DateTime(_calendarMonth.year, _calendarMonth.month, dayNum);
                  final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
                  final hasEvent = daysWithEvents.contains(dayNum);
                  final isTaken = takenDays.contains(dayNum);
                  final isSelected = _selectedCalendarDay != null &&
                      _selectedCalendarDay!.year == date.year &&
                      _selectedCalendarDay!.month == date.month &&
                      _selectedCalendarDay!.day == date.day;

                  children.add(
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedCalendarDay = null;
                          } else {
                            _selectedCalendarDay = date;
                          }
                        });
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : (isToday ? Colors.blue.shade50 : null),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$dayNum',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isToday ? FontWeight.w700 : null,
                                color: isSelected ? Colors.white : null,
                              ),
                            ),
                            if (hasEvent)
                              Container(
                                width: 4,
                                height: 4,
                                margin: const EdgeInsets.only(top: 1),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isTaken ? Colors.green : Colors.blue.shade300,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: children,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekSummary(List<Event> activeEvents) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.calendar_view_week, size: 16, color: Colors.blue.shade700),
                  const SizedBox(width: 6),
                  Text('Résumé de la semaine',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.blue.shade700)),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (i) {
                final day = today.subtract(Duration(days: 6 - i));
                final abbrev = DateFormat('E', 'fr').format(day).substring(0, 3).toUpperCase();
                final dayEvents = activeEvents.where((e) =>
                  e.takePillDate != null &&
                  e.takePillDate!.year == day.year &&
                  e.takePillDate!.month == day.month &&
                  e.takePillDate!.day == day.day
                ).toList();
                final allTaken = dayEvents.isNotEmpty && dayEvents.every((e) => _takenEventIds.contains(e.id));
                final someTaken = dayEvents.isNotEmpty && dayEvents.any((e) => _takenEventIds.contains(e.id));
                final isToday = i == 6;

                Widget indicator;
                if (dayEvents.isEmpty) {
                  indicator = Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.grey));
                } else if (allTaken) {
                  indicator = const Icon(Icons.check_circle, size: 14, color: Colors.green);
                } else if (someTaken) {
                  indicator = const Icon(Icons.radio_button_checked, size: 14, color: Colors.orange);
                } else {
                  indicator = const Icon(Icons.cancel, size: 14, color: Colors.red);
                }

                return Column(
                  children: [
                    Text(abbrev, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey.shade500)),
                    const SizedBox(height: 4),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isToday ? Colors.blue.shade50 : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(child: indicator),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher un événement...',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _isSearching
              ? IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => _searchController.clear())
              : null,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildHeader(DateTime now, List<Event> allEvents) {
    final hour = now.hour;
    final greeting = hour < 12 ? 'Bonjour' : hour < 17 ? 'Bon après-midi' : 'Bonsoir';
    final formattedDate = DateFormat('EEEE d MMMM', 'fr').format(now).splitMapJoin(
      RegExp(r'^\w'),
      onMatch: (m) => m.group(0)!.toUpperCase(),
    );

    final isConnected = _bleService.getConnectedDevice() != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(formattedDate, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    FilterChip(
                      label: Text('Aujourd\'hui',
                          style: TextStyle(fontSize: 12, color: _showOnlyToday ? Colors.white : Colors.grey.shade700)),
                      selected: _showOnlyToday,
                      selectedColor: Colors.blue,
                      checkmarkColor: Colors.white,
                      backgroundColor: Colors.grey.shade100,
                      visualDensity: VisualDensity.compact,
                      onSelected: (v) {
                        setState(() {
                          _showOnlyToday = v;
                          if (v) _selectedCalendarDay = null;
                        });
                      },
                    ),
                    FilterChip(
                      label: Text('Par médicament',
                          style: TextStyle(fontSize: 12, color: _groupByMedication ? Colors.white : Colors.grey.shade700)),
                      selected: _groupByMedication,
                      selectedColor: Colors.green,
                      checkmarkColor: Colors.white,
                      backgroundColor: Colors.grey.shade100,
                      visualDensity: VisualDensity.compact,
                      onSelected: (v) => setState(() => _groupByMedication = v),
                    ),
                    _statChip(Icons.schedule, allEvents.length.toString(), Colors.grey),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) => Transform.scale(
              scale: isConnected ? _pulseAnimation.value : 1.0,
              child: child,
            ),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/bluetooth'),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isConnected ? Colors.green.shade50 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                      color: isConnected ? Colors.green.shade700 : Colors.grey.shade500,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isConnected ? 'Connecté' : 'Déconnecté',
                    style: TextStyle(fontSize: 11, color: isConnected ? Colors.green.shade700 : Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayProgress(List<Event> todayEvents) {
    final taken = todayEvents.where((e) => _takenEventIds.contains(e.id)).length;
    final total = todayEvents.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.today, size: 18, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text("Aujourd'hui — $taken/$total pris",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.blue.shade700)),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: total > 0 ? taken / total : 0,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(taken == total ? Colors.green : Colors.blue),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: todayEvents.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final e = todayEvents[i];
                    final isTaken = _takenEventIds.contains(e.id);
                    final time = e.takePillDate != null
                        ? DateFormat('HH:mm').format(e.takePillDate!)
                        : '--:--';
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isTaken ? Colors.green.shade50 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isTaken ? Colors.green : Colors.grey.shade300, width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(isTaken ? Icons.check_circle : Icons.circle_outlined, size: 14,
                              color: isTaken ? Colors.green : Colors.grey.shade500),
                          const SizedBox(width: 5),
                          Text(time, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                              color: isTaken ? Colors.green.shade700 : Colors.grey.shade700)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String label, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.shade50, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color.shade700),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color.shade700)),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState(Object? error) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text('Impossible de charger les événements', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              Text('${error ?? "Erreur inconnue"}', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _reloadEvents,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text("Aucun événement", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Text("Crée ton premier rappel avec le bouton +", style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Widget _buildNextEventCard(Event event) {
    final timeStr = event.takePillDate != null ? DateFormat.Hm().format(event.takePillDate!) : '--:--';
    final medName = event.medication?.name ?? '';
    final dosage = event.medication?.dosageSummary ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openEventDetail(event),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.notifications_active, color: Theme.of(context).colorScheme.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(timeStr, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary)),
                          const SizedBox(width: 10),
                          if (_takenEventIds.contains(event.id))
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6)),
                              child: Text('Pris', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.green.shade700)),
                            )
                          else
                            _timeRemainingBadge(event.takePillDate!),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(event.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      if (medName.isNotEmpty)
                        Padding(padding: const EdgeInsets.only(top: 2),
                            child: Text('$medName${dosage.isNotEmpty ? ' — $dosage' : ''}',
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade600))),
                    ],
                  ),
                ),
                if (!_takenEventIds.contains(event.id))
                  IconButton(
                    icon: Icon(Icons.check_circle_outline, size: 24, color: Colors.green.shade600),
                    tooltip: 'Marquer comme pris',
                    onPressed: () { HapticFeedback.lightImpact(); setState(() => _takenEventIds.add(event.id!)); },
                  )
                else
                  Icon(Icons.check_circle, color: Colors.green.shade600),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _timeRemainingBadge(DateTime date) {
    final diff = date.difference(DateTime.now());
    String label;
    Color bgColor;
    Color textColor;

    if (diff.isNegative) {
      label = 'En retard'; bgColor = Colors.red.shade50; textColor = Colors.red.shade700;
    } else if (diff.inDays > 0) {
      label = 'Dans ${diff.inDays} jour${diff.inDays > 1 ? 's' : ''}'; bgColor = Colors.blue.shade50; textColor = Colors.blue.shade700;
    } else if (diff.inHours > 0) {
      final minutes = diff.inMinutes % 60;
      label = 'Dans ${diff.inHours}h${minutes > 0 ? minutes.toString().padLeft(2, '0') : ''}';
      bgColor = diff.inHours < 6 ? Colors.orange.shade50 : Colors.green.shade50;
      textColor = diff.inHours < 6 ? Colors.orange.shade700 : Colors.green.shade700;
    } else if (diff.inMinutes > 0) {
      label = 'Dans ${diff.inMinutes} min'; bgColor = Colors.green.shade50; textColor = Colors.green.shade700;
    } else {
      label = 'Maintenant'; bgColor = Colors.red.shade50; textColor = Colors.red.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
    );
  }

  void _editEvent(Event event) async {
    final result = await Navigator.push(
      context, MaterialPageRoute(builder: (_) => CreateEventScreen(event: event)),
    );
    if (result == true) _reloadEvents();
  }

  void _openEventDetail(Event event) async {
    final result = await Navigator.push(
      context, MaterialPageRoute(builder: (_) => EventDetailPage(event: event)),
    );
    if (result is Map && result['taken'] == true && result['id'] != null) {
      setState(() => _takenEventIds.add(result['id'] as int));
    } else if (result == true) {
      _reloadEvents();
    }
  }

  Widget _buildEventCard(Event event) {
    final timeStr = event.takePillDate != null ? DateFormat.Hm().format(event.takePillDate!) : '--:--';
    final dateStr = event.takePillDate != null ? DateFormat.yMMMMd().format(event.takePillDate!) : '';
    final imageUrl = event.medication?.imageUrl;
    final medName = event.medication?.name ?? '';
    final dosage = event.medication?.dosageSummary ?? '';
    final isTaken = _takenEventIds.contains(event.id);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = event.takePillDate != null &&
        event.takePillDate!.year == today.year &&
        event.takePillDate!.month == today.month &&
        event.takePillDate!.day == today.day;

    final cardContent = Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: isToday
            ? BorderSide(color: Colors.blue.shade300, width: 1)
            : isTaken
                ? BorderSide(color: Colors.green.shade300, width: 1)
                : BorderSide.none,
      ),
      color: isTaken ? Colors.green.shade50 : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openEventDetail(event),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(timeStr, style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold,
                            decoration: isTaken ? TextDecoration.lineThrough : null,
                            color: isTaken ? Colors.grey : null)),
                        const SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            children: [
                              if (isToday)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  margin: const EdgeInsets.only(right: 4),
                                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
                                  child: Text('Aujourd\'hui', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.blue.shade700)),
                                ),
                              if (isTaken)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  margin: const EdgeInsets.only(right: 4),
                                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6)),
                                  child: Text('Pris', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.green.shade700)),
                                ),
                              if (!isTaken && event.takePillDate != null)
                                _timeRemainingBadge(event.takePillDate!),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (dateStr.isNotEmpty)
                      Padding(padding: const EdgeInsets.only(top: 2),
                          child: Text(dateStr, style: TextStyle(fontSize: 14, color: Colors.grey.shade600))),
                    const SizedBox(height: 8),
                    Text(event.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                    if (medName.isNotEmpty)
                      Padding(padding: const EdgeInsets.only(top: 4),
                          child: Text('$medName${dosage.isNotEmpty ? ' — $dosage' : ''}', style: const TextStyle(fontSize: 14))),
                    if (event.description.isNotEmpty)
                      Padding(padding: const EdgeInsets.only(top: 4),
                          child: Text(event.description, style: const TextStyle(fontSize: 13, color: Colors.grey))),
                  ],
                ),
              ),
              if (isToday && !isTaken)
                Column(children: [
                  IconButton(
                    icon: Icon(Icons.check_circle_outline, size: 28, color: Colors.green.shade600),
                    tooltip: 'Marquer comme pris',
                    onPressed: () { HapticFeedback.lightImpact(); setState(() => _takenEventIds.add(event.id!)); },
                  ),
                ]),
              if (imageUrl != null && imageUrl.isNotEmpty)
                Container(width: 44, height: 44, margin: const EdgeInsets.only(left: 8),
                    child: Image.network(imageUrl, fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.medication, size: 28, color: Colors.grey))),
              if (event.medication?.noticeUrl != null && event.medication!.noticeUrl!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: IconButton(
                    icon: Icon(Icons.description_outlined, size: 20, color: Colors.grey.shade500),
                    tooltip: 'Notice',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: event.medication!.noticeUrl!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Lien de la notice copié'), duration: Duration(seconds: 2), behavior: SnackBarBehavior.floating),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    return Dismissible(
      key: Key('event-${event.id}'),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe droite → marquer comme pris
          if (!isTaken) {
            HapticFeedback.lightImpact();
            setState(() => _takenEventIds.add(event.id!));
          }
          return false;
        } else {
          // Swipe gauche → supprimer
          final confirmed = await _confirmDelete(event);
          if (confirmed == true) {
            HapticFeedback.mediumImpact();
            _takenEventIds.remove(event.id);
            await eventController.deleteEvent(event.id!);
            await _reloadEvents();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Événement supprimé'), behavior: SnackBarBehavior.floating),
              );
            }
          }
          return confirmed ?? false;
        }
      },
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(14)),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.check_circle, color: Colors.white, size: 28),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(14)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      child: cardContent,
    );
  }
}
