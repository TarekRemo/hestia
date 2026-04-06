import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/discipline_action.dart';
import '../models/action_history.dart';
import '../models/action_notification.dart';
import '../providers/action_provider.dart';
import '../providers/history_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import 'action_form_screen.dart';
import 'log_action_screen.dart';

class ActionDetailScreen extends StatefulWidget {
  final DisciplineAction action;

  const ActionDetailScreen({super.key, required this.action});

  @override
  State<ActionDetailScreen> createState() => _ActionDetailScreenState();
}

class _ActionDetailScreenState extends State<ActionDetailScreen> {
  List<ActionHistory> _history = [];
  List<ActionNotification> _notifications = [];
  double _successRate = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final historyProvider = context.read<HistoryProvider>();
    final actionProvider = context.read<ActionProvider>();
    _history = await historyProvider.getActionHistory(widget.action.id!, limit: 30);
    _successRate = await historyProvider.getSuccessRate(widget.action.id!);
    _notifications = await actionProvider.getNotifications(widget.action.id!);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final action = widget.action;

    return Scaffold(
      appBar: AppBar(
        title: Text(action.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editAction,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
            onPressed: _deleteAction,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Action info card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.cardDecorationOf(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: action.isPositive
                                ? AppTheme.positiveColor
                                : AppTheme.negativeColor,
                            radius: 24,
                            child: Icon(
                              action.isPositive
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(action.name,
                                    style: AppTheme.headingSmallOf(context)),
                                const SizedBox(height: 4),
                                Text(
                                  action.isPositive
                                      ? 'Action positive'
                                      : 'Action négative',
                                  style: TextStyle(
                                    color: action.isPositive
                                        ? AppTheme.positiveColor
                                        : AppTheme.negativeColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (action.description != null &&
                          action.description!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(action.description!,
                            style: AppTheme.bodyMediumOf(context)),
                      ],
                      const Divider(height: 24),
                      _infoRow('Importance',
                          '${action.importanceLabel ?? "Moyen"} (${action.importancePoints ?? 10} pts)'),
                      _infoRow('Fréquence', action.frequencyLabel),
                      _infoRow('Points si réalisé',
                          '${action.pointsOnDone > 0 ? "+" : ""}${action.pointsOnDone}'),
                      _infoRow('Points si non réalisé',
                          '${action.pointsOnNotDone > 0 ? "+" : ""}${action.pointsOnNotDone}'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Stats row
                Row(
                  children: [
                    _buildStatCard(
                      'Série actuelle',
                      '${action.currentStreak}',
                      Icons.local_fire_department,
                      Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Record',
                      '${action.recordStreak}',
                      Icons.star,
                      Colors.amber,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Taux réussite',
                      '${(_successRate * 100).toInt()}%',
                      Icons.pie_chart,
                      AppTheme.accentColor,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Log button
                ElevatedButton.icon(
                  onPressed: () => _logAction(),
                  icon: const Icon(Icons.add_task),
                  label: const Text('Saisir une réalisation'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 24),

                // Notifications section
                if (_notifications.isNotEmpty) ...[
                  Text('Notifications personnalisées', style: AppTheme.headingSmallOf(context)),
                  const SizedBox(height: 12),
                  ..._notifications.map((notif) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    child: ListTile(
                      leading: Icon(
                        _notifIcon(notif.notificationType),
                        color: _notifColor(notif.notificationType),
                      ),
                      title: Text(notif.title, style: AppTheme.bodyLargeOf(context)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (notif.message != null && notif.message!.isNotEmpty)
                            Text(notif.message!, style: AppTheme.bodyMediumOf(context)),
                          Text(notif.typeLabel,
                              style: TextStyle(
                                color: _notifColor(notif.notificationType),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              )),
                        ],
                      ),
                      isThreeLine: notif.message != null && notif.message!.isNotEmpty,
                    ),
                  )),
                  const SizedBox(height: 24),
                ],

                // Recent history
                Text('Historique récent', style: AppTheme.headingSmallOf(context)),
                const SizedBox(height: 12),
                if (_history.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text('Aucun historique',
                          style: AppTheme.bodyMediumOf(context)),
                    ),
                  )
                else
                  ..._history.map((h) => _buildHistoryTile(h)),
              ],
            ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.bodyMediumOf(context)),
          Text(value, style: AppTheme.bodyLargeOf(context)),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: AppTheme.cardDecorationOf(context),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color)),
            Text(label,
                style: AppTheme.bodySmallOf(context),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTile(ActionHistory h) {
    IconData icon;
    Color color;
    switch (h.actionStatus) {
      case 1:
        icon = Icons.check_circle;
        color = AppTheme.positiveColor;
        break;
      case 0:
        icon = Icons.cancel;
        color = AppTheme.negativeColor;
        break;
      default:
        icon = Icons.help_outline;
        color = AppTheme.textMutedOf(context);
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(h.statusLabel, style: AppTheme.bodyLargeOf(context)),
        subtitle: Text(h.date, style: AppTheme.bodySmallOf(context)),
        trailing: Text(
          '${h.scoreImpact > 0 ? "+" : ""}${h.scoreImpact}',
          style: TextStyle(
            color: h.scoreImpact >= 0
                ? AppTheme.positiveColor
                : AppTheme.negativeColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _editAction() async {
    final userId = context.read<UserProvider>().user?.id;
    if (userId == null) return;
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            ActionFormScreen(userId: userId, action: widget.action),
      ),
    );
    if (result == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  void _deleteAction() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer l\'action ?'),
        content: const Text(
            'Cette action et tout son historique seront supprimés définitivement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<ActionProvider>().deleteAction(widget.action.id!);
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  void _logAction() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => LogActionScreen(action: widget.action),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }

  IconData _notifIcon(int type) {
    switch (type) {
      case 1: return Icons.emoji_events_outlined;
      case 2: return Icons.alarm;
      case 3: return Icons.celebration_outlined;
      case 4: return Icons.sentiment_dissatisfied_outlined;
      default: return Icons.notifications_outlined;
    }
  }

  Color _notifColor(int type) {
    switch (type) {
      case 1: return AppTheme.warningColor;
      case 2: return AppTheme.accentColor;
      case 3: return AppTheme.positiveColor;
      case 4: return AppTheme.negativeColor;
      default: return AppTheme.textMuted;
    }
  }
}
