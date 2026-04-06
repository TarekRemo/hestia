import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/discipline_action.dart';
import '../models/action_time_slot.dart';
import '../models/action_importance.dart';
import '../models/action_notification.dart';
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
  final List<ActionNotification> _notifications = [];
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
      final notifs = await provider.getNotifications(widget.action!.id!);
      setState(() {
        _timeSlots.addAll(slots);
        _notifications.addAll(notifs);
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
        await provider.addAction(action, _timeSlots, notifications: _notifications);
      } else {
        await provider.updateAction(action, _timeSlots, notifications: _notifications);
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
            Text('Type d\'action', style: AppTheme.bodyLargeOf(context)),
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
                            : AppTheme.bgCardLightOf(context),
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
                            : AppTheme.bgCardLightOf(context),
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
            Text('Niveau d\'importance', style: AppTheme.bodyLargeOf(context)),
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
            Text('Fréquence', style: AppTheme.bodyLargeOf(context)),
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
                  style: AppTheme.bodyMediumOf(context),
                ),
              ),
            const SizedBox(height: 20),

            // Time slots
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Plages horaires', style: AppTheme.bodyLargeOf(context)),
                TextButton.icon(
                  onPressed: _addTimeSlot,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Ajouter'),
                ),
              ],
            ),
            if (_timeSlots.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('Aucune plage horaire définie',
                    style: AppTheme.bodySmallOf(context)),
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
            const SizedBox(height: 20),

            // Notifications
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Notifications', style: AppTheme.bodyLargeOf(context)),
                TextButton.icon(
                  onPressed: _addNotification,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Ajouter'),
                ),
              ],
            ),
            if (_notifications.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('Aucune notification personnalisée',
                    style: AppTheme.bodySmallOf(context)),
              )
            else
              ...List.generate(_notifications.length, (i) {
                final notif = _notifications[i];
                return Card(
                  child: ListTile(
                    leading: Icon(
                      _notificationIcon(notif.notificationType),
                      color: _notificationColor(notif.notificationType),
                    ),
                    title: Text(notif.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (notif.message != null && notif.message!.isNotEmpty)
                          Text(notif.message!,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(notif.typeLabel,
                            style: TextStyle(
                              color: _notificationColor(notif.notificationType),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            )),
                      ],
                    ),
                    isThreeLine: notif.message != null && notif.message!.isNotEmpty,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined,
                              color: AppTheme.accentColor, size: 20),
                          onPressed: () => _editNotification(i),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppTheme.errorColor, size: 20),
                          onPressed: () {
                            setState(() => _notifications.removeAt(i));
                          },
                        ),
                      ],
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

  IconData _notificationIcon(int type) {
    switch (type) {
      case 1: return Icons.emoji_events_outlined;
      case 2: return Icons.alarm;
      case 3: return Icons.celebration_outlined;
      case 4: return Icons.sentiment_dissatisfied_outlined;
      default: return Icons.notifications_outlined;
    }
  }

  Color _notificationColor(int type) {
    switch (type) {
      case 1: return AppTheme.warningColor;
      case 2: return AppTheme.accentColor;
      case 3: return AppTheme.positiveColor;
      case 4: return AppTheme.negativeColor;
      default: return AppTheme.textMuted;
    }
  }

  void _addNotification() {
    _showNotificationDialog();
  }

  void _editNotification(int index) {
    _showNotificationDialog(existingIndex: index);
  }

  void _showNotificationDialog({int? existingIndex}) {
    final isEditing = existingIndex != null;
    final existing = isEditing ? _notifications[existingIndex] : null;

    final titleController = TextEditingController(text: existing?.title ?? '');
    final messageController = TextEditingController(text: existing?.message ?? '');
    int selectedType = existing?.notificationType ?? 1;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Modifier la notification' : 'Nouvelle notification'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type', style: AppTheme.bodyLargeOf(ctx)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildTypeChip(1, 'Motivation', selectedType, (t) {
                      setDialogState(() => selectedType = t);
                    }),
                    _buildTypeChip(2, 'Rappel', selectedType, (t) {
                      setDialogState(() => selectedType = t);
                    }),
                    _buildTypeChip(3, 'Succès', selectedType, (t) {
                      setDialogState(() => selectedType = t);
                    }),
                    _buildTypeChip(4, 'Échec', selectedType, (t) {
                      setDialogState(() => selectedType = t);
                    }),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titre *',
                    hintText: 'Ex: C\'est l\'heure !',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message (optionnel)',
                    hintText: 'Ex: Tu peux le faire, reste motivé !',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isEmpty) return;

                final notif = ActionNotification(
                  title: title,
                  message: messageController.text.trim().isEmpty
                      ? null
                      : messageController.text.trim(),
                  notificationType: selectedType,
                );

                setState(() {
                  if (isEditing) {
                    _notifications[existingIndex] = notif;
                  } else {
                    _notifications.add(notif);
                  }
                });
                Navigator.pop(ctx);
              },
              child: Text(isEditing ? 'Modifier' : 'Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(int type, String label, int selectedType, ValueChanged<int> onSelected) {
    final isSelected = selectedType == type;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_notificationIcon(type), size: 16,
              color: isSelected ? Colors.white : _notificationColor(type)),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(type),
      selectedColor: _notificationColor(type),
    );
  }
}
