import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/discipline_action.dart';
import '../models/action_time_slot.dart';
import '../models/action_importance.dart';
import '../providers/action_provider.dart';
import '../theme/app_theme.dart';

class ActionFormScreen extends StatefulWidget {
  final int userId;
  final DisciplineAction? action; // null for create, non-null for edit

  const ActionFormScreen({
    super.key,
    required this.userId,
    this.action,
  });

  @override
  State<ActionFormScreen> createState() => _ActionFormScreenState();
}

class _ActionFormScreenState extends State<ActionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late bool _isPositive;
  ActionImportance? _selectedImportance;
  int? _frequency;
  final List<ActionTimeSlot> _timeSlots = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.action?.name ?? '');
    _descController =
        TextEditingController(text: widget.action?.description ?? '');
    _isPositive = widget.action?.isPositive ?? true;
    _frequency = widget.action?.frequency;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = context.read<ActionProvider>();
    await provider.loadImportanceLevels();

    if (widget.action != null) {
      final slots = await provider.getTimeSlots(widget.action!.id!);
      setState(() {
        _timeSlots.addAll(slots);
      });
      // Set selected importance
      final levels = provider.importanceLevels;
      for (var l in levels) {
        if (l.id == widget.action!.actionImportanceId) {
          setState(() {
            _selectedImportance = l;
          });
          break;
        }
      }
    } else {
      // Default to medium
      final levels = provider.importanceLevels;
      if (levels.isNotEmpty) {
        setState(() {
          _selectedImportance = levels.length > 1 ? levels[1] : levels[0];
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImportance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un niveau d\'importance')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final action = DisciplineAction(
      id: widget.action?.id,
      userId: widget.userId,
      actionImportanceId: _selectedImportance!.id,
      name: _nameController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      frequency: _frequency,
      isPositive: _isPositive,
      currentStreak: widget.action?.currentStreak ?? 0,
      recordStreak: widget.action?.recordStreak ?? 0,
    );

    try {
      final provider = context.read<ActionProvider>();
      if (widget.action == null) {
        await provider.addAction(action, _timeSlots);
      } else {
        await provider.updateAction(action, _timeSlots);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addTimeSlot() async {
    final startTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
      helpText: 'Heure de début',
    );
    if (startTime == null || !mounted) return;

    final endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: startTime.hour + 1, minute: startTime.minute),
      helpText: 'Heure de fin',
    );
    if (endTime == null || !mounted) return;

    setState(() {
      _timeSlots.add(ActionTimeSlot(
        startTime:
            '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
        endTime:
            '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.action != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier l\'action' : 'Nouvelle action'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom de l\'action *',
                prefixIcon: Icon(Icons.label_outline),
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Le nom est requis'
                  : null,
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description (optionnelle)',
                prefixIcon: Icon(Icons.description_outlined),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // Positive/Negative toggle
            const Text('Type d\'action', style: AppTheme.bodyLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isPositive = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _isPositive
                            ? AppTheme.positiveColor
                            : AppTheme.bgCardLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isPositive
                              ? AppTheme.positiveColor
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.trending_up,
                              color: _isPositive
                                  ? Colors.white
                                  : AppTheme.textMuted),
                          const SizedBox(width: 8),
                          Text(
                            'Positive',
                            style: TextStyle(
                              color: _isPositive
                                  ? Colors.white
                                  : AppTheme.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isPositive = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: !_isPositive
                            ? AppTheme.negativeColor
                            : AppTheme.bgCardLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: !_isPositive
                              ? AppTheme.negativeColor
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.trending_down,
                              color: !_isPositive
                                  ? Colors.white
                                  : AppTheme.textMuted),
                          const SizedBox(width: 8),
                          Text(
                            'Négative',
                            style: TextStyle(
                              color: !_isPositive
                                  ? Colors.white
                                  : AppTheme.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Importance level
            const Text('Niveau d\'importance', style: AppTheme.bodyLarge),
            const SizedBox(height: 8),
            Consumer<ActionProvider>(
              builder: (context, provider, _) {
                return Wrap(
                  spacing: 8,
                  children: provider.importanceLevels.map((level) {
                    final selected = _selectedImportance?.id == level.id;
                    return ChoiceChip(
                      label: Text('${level.label} (${level.points} pts)'),
                      selected: selected,
                      onSelected: (_) =>
                          setState(() => _selectedImportance = level),
                      selectedColor: AppTheme.primaryColor,
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 20),

            // Frequency
            const Text('Fréquence', style: AppTheme.bodyLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Quotidienne'),
                  selected: _frequency == 1,
                  onSelected: (_) => setState(() => _frequency = 1),
                  selectedColor: AppTheme.primaryColor,
                ),
                ChoiceChip(
                  label: const Text('Hebdomadaire'),
                  selected: _frequency == 7,
                  onSelected: (_) => setState(() => _frequency = 7),
                  selectedColor: AppTheme.primaryColor,
                ),
                ChoiceChip(
                  label: const Text('Personnalisée'),
                  selected:
                      _frequency != null && _frequency != 1 && _frequency != 7,
                  onSelected: (_) => _showCustomFrequency(),
                  selectedColor: AppTheme.primaryColor,
                ),
                ChoiceChip(
                  label: const Text('Non définie'),
                  selected: _frequency == null,
                  onSelected: (_) => setState(() => _frequency = null),
                  selectedColor: AppTheme.primaryColor,
                ),
              ],
            ),
            if (_frequency != null && _frequency != 1 && _frequency != 7)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Tous les $_frequency jours',
                  style: AppTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 20),

            // Time slots
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Plages horaires', style: AppTheme.bodyLarge),
                TextButton.icon(
                  onPressed: _addTimeSlot,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Ajouter'),
                ),
              ],
            ),
            if (_timeSlots.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Aucune plage horaire définie',
                    style: AppTheme.bodySmall),
              )
            else
              ...List.generate(_timeSlots.length, (i) {
                final slot = _timeSlots[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.access_time,
                        color: AppTheme.accentColor),
                    title:
                        Text('${slot.startTime} - ${slot.endTime}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: AppTheme.errorColor),
                      onPressed: () {
                        setState(() => _timeSlots.removeAt(i));
                      },
                    ),
                  ),
                );
              }),
            const SizedBox(height: 32),

            // Save button
            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEditing ? 'Modifier' : 'Créer l\'action'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomFrequency() {
    final controller = TextEditingController(
      text: (_frequency != null && _frequency != 1 && _frequency != 7)
          ? '$_frequency'
          : '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Fréquence personnalisée'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Nombre de jours',
            hintText: 'Ex: 3',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val > 0) {
                setState(() => _frequency = val);
              }
              Navigator.pop(ctx);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
