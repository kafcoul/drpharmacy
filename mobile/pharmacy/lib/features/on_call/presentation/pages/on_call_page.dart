import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/presentation/widgets/error_display.dart';
import '../../../../core/utils/error_messages.dart';
import '../../data/models/on_call_model.dart';
import '../providers/on_call_provider.dart';

class OnCallPage extends ConsumerStatefulWidget {
  const OnCallPage({super.key});

  @override
  ConsumerState<OnCallPage> createState() => _OnCallPageState();
}

class _OnCallPageState extends ConsumerState<OnCallPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection.name == 'reverse') {
        if (_isFabVisible) setState(() => _isFabVisible = false);
      } else {
        if (!_isFabVisible) setState(() => _isFabVisible = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  OnCallModel? _getActiveShift(List<OnCallModel> onCalls) {
    final now = DateTime.now();
    try {
      // Find a shift that is either active now OR starts very soon (e.g. within 5 mins)
      // This handles the case where we create a shift "starting in 1 min" to satisfy backend
      // but want it to appear active immediately.
      return onCalls.firstWhere(
        (shift) {
          final isEffectivelyActive = shift.isActive && 
             shift.startAt.isBefore(now.add(const Duration(minutes: 5))) && 
             shift.endAt.isAfter(now);
          return isEffectivelyActive;
        }
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleToggle(bool value, OnCallModel? activeShift) async {
    if (value) {
      // Turn ON -> Create Shift
      final type = await showDialog<String>(
        context: context,
        builder: (context) => const _QuickStartShiftDialog(),
      );
      
      if (type != null) {
        // Default: Now to Tomorrow 8am
        final now = DateTime.now();
        // Add 2 minutes to satisfy backend "after:now" if strictly checked, 
        // or rely on backend tolerance. Safe bet: ensure start is valid.
        // Actually, if I want to be "On Call Now", I want it effective immediately.
        // Let's try sending now().add(Duration(minutes: 1))
        final start = now.add(const Duration(minutes: 1)); 
        
        // Define end based on type? Or default 24h?
        // Let's assume default is Next Day 8:00 AM for Night/Holiday
        DateTime end = DateTime(now.year, now.month, now.day + 1, 8, 0);
        if (end.isBefore(start)) {
          end = end.add(const Duration(days: 1));
        }

        final success = await ref.read(onCallProvider.notifier).createOnCall(
          start, 
          end, 
          type
        );
        
        if (success && mounted) {
           ErrorSnackBar.showSuccess(context, 'Mode garde activé avec succès !');
        }
      }
    } else {
      // Turn OFF -> Delete/Stop Shift
      if (activeShift == null) return;
      
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Terminer la garde ?'),
          content: const Text('Voulez-vous vraiment désactiver le mode garde maintenant ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Désactiver'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        final success = await ref.read(onCallProvider.notifier).deleteOnCall(activeShift.id);
         if (success && mounted) {
           ErrorSnackBar.showInfo(context, 'Mode garde désactivé');
        }
      }
    }
  }

  Widget _buildStatusToggle(OnCallModel? activeShift) {
    final isOn = activeShift != null;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isOn ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOn ? const Color(0xFF1B8F6F) : Colors.grey.shade200,
            width: isOn ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isOn ? const Color(0xFF1B8F6F) : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isOn ? Icons.local_pharmacy : Icons.local_pharmacy_outlined,
                color: isOn ? Colors.white : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOn ? 'Vous êtes de garde' : 'Mode garde inactif',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isOn ? const Color(0xFF1B8F6F) : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isOn 
                      ? 'Fin prévue : ${DateFormat('HH:mm').format(activeShift.endAt)}' 
                      : 'Activez pour recevoir des commandes d\'urgence',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: isOn,
                activeColor: const Color(0xFF1B8F6F),
                onChanged: (val) => _handleToggle(val, activeShift),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onCallProvider);
    final activeShift = _getActiveShift(state.onCalls);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          'Gestion des gardes',
          style: TextStyle(
            fontSize: 17, 
            fontWeight: FontWeight.w600,
            color: Colors.black87
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: _isFabVisible ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _isFabVisible ? 1 : 0,
          child: FloatingActionButton.extended(
            onPressed: () => _showAddOnCallSheet(context),
            label: const Text(
              'Planifier', 
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)
            ),
            icon: const Icon(Icons.calendar_today, size: 20),
            backgroundColor: const Color(0xFF1B8F6F),
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildStatusToggle(activeShift),
          Expanded(
            child: Column(
              children: [
                if (state.onCalls.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Text(
                          'Gardes programmées',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${state.onCalls.length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: state.isLoading && state.onCalls.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : state.onCalls.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: () => ref.read(onCallProvider.notifier).getOnCalls(),
                            child: ListView.separated(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                              itemCount: state.onCalls.length,
                              separatorBuilder: (c, i) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final onCall = state.onCalls[index];
                                // Highlight active shift in list too if needed, but toggle handles it.
                                return _buildOnCallCard(onCall);
                              },
                            ),
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnCallCard(OnCallModel onCall) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {}, // Details if needed
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStatusBadge(onCall),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDateRange(onCall.startAt, onCall.endAt),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            '${DateFormat('HH:mm').format(onCall.startAt)} - ${DateFormat('HH:mm').format(onCall.endAt)}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _confirmDelete(onCall),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(OnCallModel onCall) async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Supprimer'),
          content: const Text('Voulez-vous supprimer cette période de garde ?'),
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

      if (confirm == true) {
        ref.read(onCallProvider.notifier).deleteOnCall(onCall.id);
      }
  }
  Widget _buildStatusBadge(OnCallModel onCall) {
    final isActive = onCall.isActive;
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFE8F5E9) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getIconForType(onCall.type),
            color: isActive ? const Color(0xFF1B8F6F) : Colors.grey.shade400,
            size: 24,
          ),
        ),
        if (isActive)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'night': return Icons.nights_stay;
      case 'weekend': return Icons.weekend;
      case 'holiday': return Icons.celebration;
      case 'emergency': return Icons.local_hospital;
      default: return Icons.calendar_today;
    }
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final startStr = DateFormat('dd MMM').format(start);
    final endStr = DateFormat('dd MMM').format(end);
    if (start.day == end.day && start.month == end.month && start.year == end.year) {
      return '$startStr ${DateFormat('yyyy').format(start)}';
    }
    return '$startStr - $endStr ${DateFormat('yyyy').format(end)}';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Icon(Icons.calendar_today_outlined, size: 40, color: Colors.grey.shade300),
            ),
            const SizedBox(height: 24),
            Text(
              "Aucune garde programmée",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Ajoutez vos créneaux de garde pour informer les patients de votre disponibilité.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatType(String type) {
    switch (type) {
      case 'night': return 'Garde de Nuit';
      case 'weekend': return 'Garde Week-end';
      case 'holiday': return 'Jours Fériés';
      case 'emergency': return 'Urgence';
      default: return type;
    }
  }

  void _showAddOnCallSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddOnCallSheet(),
    );
  }
}

class AddOnCallSheet extends ConsumerStatefulWidget {
  const AddOnCallSheet({super.key});

  @override
  ConsumerState<AddOnCallSheet> createState() => _AddOnCallSheetState();
}

class _AddOnCallSheetState extends ConsumerState<AddOnCallSheet> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedType = 'night';
  TimeOfDay _startTime = const TimeOfDay(hour: 20, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 8, minute: 0);

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    _endDate = DateTime.now().add(const Duration(days: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nouvelle Période de Garde',
              style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.bold,
                fontFamily: 'Muli', // Ensure nice font if available
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Définissez vos horaires d'ouverture exceptionnelle",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
            const SizedBox(height: 24),
            
            _buildTypeSelector(), // Custom built selector instead of basic Dropdown
            const SizedBox(height: 20),
            
            const Text(
              "Raccourcis rapides",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                letterSpacing: 0.5,
              )
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  _buildQuickActionChip('Ce soir', true, () {
                      final now = DateTime.now();
                      setState(() {
                         _selectedType = 'night';
                         _startDate = now;
                         _startTime = const TimeOfDay(hour: 20, minute: 0);
                         _endDate = now.add(const Duration(days: 1));
                         _endTime = const TimeOfDay(hour: 8, minute: 0);
                      });
                  }),
                  _buildQuickActionChip('Demain soir', false, () {
                      final tomorrow = DateTime.now().add(const Duration(days: 1));
                      setState(() {
                         _selectedType = 'night';
                         _startDate = tomorrow;
                         _startTime = const TimeOfDay(hour: 20, minute: 0);
                         _endDate = tomorrow.add(const Duration(days: 1));
                         _endTime = const TimeOfDay(hour: 8, minute: 0);
                      });
                  }),
                  _buildQuickActionChip('Ce Week-end', false, () {
                      var d = DateTime.now();
                      while (d.weekday != 5) { d = d.add(const Duration(days: 1)); }
                      setState(() {
                         _selectedType = 'weekend';
                         _startDate = d;
                         _startTime = const TimeOfDay(hour: 20, minute: 0);
                         _endDate = d.add(const Duration(days: 3));
                         _endTime = const TimeOfDay(hour: 8, minute: 0);
                      });
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _buildDateTimePicker(
                    label: 'DÉBUT',
                    date: _startDate,
                    time: _startTime,
                    onDatePick: () => _pickDate(true),
                    onTimePick: () => _pickTime(true),
                  ),
                ),
                Container(
                  height: 40, 
                  width: 1, 
                  color: Colors.grey.shade200, 
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20)
                ),
                Expanded(
                  child: _buildDateTimePicker(
                    label: 'FIN',
                    date: _endDate,
                    time: _endTime,
                    onDatePick: () => _pickDate(false),
                    onTimePick: () => _pickTime(false),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'Confirmer la période',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedType,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          borderRadius: BorderRadius.circular(16),
          items: const [
            DropdownMenuItem(value: 'night', child: _TypeItem(type: 'night', label: 'Garde de Nuit')),
            DropdownMenuItem(value: 'weekend', child: _TypeItem(type: 'weekend', label: 'Garde Week-end')),
            DropdownMenuItem(value: 'holiday', child: _TypeItem(type: 'holiday', label: 'Garde Jours Fériés')),
            DropdownMenuItem(value: 'emergency', child: _TypeItem(type: 'emergency', label: 'Urgence')),
          ],
          onChanged: (v) => setState(() => _selectedType = v!),
        ),
      ),
    );
  }

  Widget _buildQuickActionChip(String label, bool isPrimary, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isPrimary ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isPrimary ? Theme.of(context).colorScheme.primary.withOpacity(0.3) : Colors.grey.shade200
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isPrimary ? Theme.of(context).colorScheme.primary : Colors.grey.shade700,
              fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker({
    required String label,
    required DateTime? date,
    required TimeOfDay time,
    required VoidCallback onDatePick,
    required VoidCallback onTimePick,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: TextStyle(
            fontSize: 11, 
            fontWeight: FontWeight.bold, 
            color: Colors.grey.shade400,
            letterSpacing: 0.5
          )
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: onDatePick,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date != null ? DateFormat('dd MMM', 'fr').format(date) : '-',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTimePick,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    time.format(context),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate! : _endDate!,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) _startDate = picked; else _endDate = picked;
      });
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) _startTime = picked; else _endTime = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (_startDate == null || _endDate == null) return;

    final start = DateTime(
      _startDate!.year, _startDate!.month, _startDate!.day,
      _startTime.hour, _startTime.minute
    );
    
    final end = DateTime(
      _endDate!.year, _endDate!.month, _endDate!.day,
      _endTime.hour, _endTime.minute
    );

    if (end.isBefore(start)) {
      ErrorSnackBar.showWarning(
        context,
        'La date de fin doit être après la date de début',
      );
      return;
    }

    final success = await ref.read(onCallProvider.notifier).createOnCall(
      start, end, _selectedType
    );

    if (success && mounted) {
      Navigator.pop(context);
      ErrorSnackBar.showSuccess(context, 'Garde ajoutée avec succès !');
    } else if (mounted) {
       final error = ref.read(onCallProvider).error;
       ErrorSnackBar.showError(
         context,
         ErrorMessages.getReadableMessage(error ?? 'Erreur lors de l\'ajout'),
       );
    }
  }
}

class _QuickStartShiftDialog extends StatefulWidget {
  const _QuickStartShiftDialog();

  @override
  State<_QuickStartShiftDialog> createState() => _QuickStartShiftDialogState();
}

class _QuickStartShiftDialogState extends State<_QuickStartShiftDialog> {
  String _selectedType = 'night'; // Default type

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Démarrer une garde'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sélectionnez le type de garde pour aujourd\'hui :'),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedType,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            items: const [
              DropdownMenuItem(value: 'night', child: Text('Garde de Nuit')),
              DropdownMenuItem(value: 'weekend', child: Text('Garde Week-end')),
              DropdownMenuItem(value: 'holiday', child: Text('Garde Jours Fériés')),
              DropdownMenuItem(value: 'emergency', child: Text('Urgence')),
            ],
            onChanged: (val) => setState(() => _selectedType = val!),
          ),
          const SizedBox(height: 8),
          Text(
            'La garde commencera maintenant et se terminera demain à 08:00.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _selectedType),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B8F6F),
            foregroundColor: Colors.white,
          ),
          child: const Text('Activer'),
        ),
      ],
    );
  }
}

class _TypeItem extends StatelessWidget {
  final String type;
  final String label;

  const _TypeItem({required this.type, required this.label});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    
    switch (type) {
      case 'night': icon = Icons.nights_stay; color = Colors.indigo; break;
      case 'weekend': icon = Icons.weekend; color = Colors.orange; break;
      case 'holiday': icon = Icons.celebration; color = Colors.purple; break;
      case 'emergency': icon = Icons.local_hospital; color = Colors.red; break;
      default: icon = Icons.calendar_today; color = Colors.grey;
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
