import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/discipline_action.dart';
import '../models/action_history.dart';
import '../providers/history_provider.dart';
import '../providers/user_provider.dart';
import '../providers/action_provider.dart';
import '../theme/app_theme.dart';

class LogActionScreen extends StatefulWidget {
  final DisciplineAction action;
  final int? initialStatus;

  const LogActionScreen({
    super.key,
    required this.action,
    this.initialStatus,
  });

  @override
  State<LogActionScreen> createState() => _LogActionScreenState();
}

class _LogActionScreenState extends State<LogActionScreen> {
  late int _status;
  final _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus ?? -1;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_status == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un statut')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final entry = ActionHistory(
      actionId: widget.action.id,
      date: DateTime.now().toIso8601String(),
      actionStatus: _status,
      userComment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
    );

    try {
      final historyProvider = context.read<HistoryProvider>();
      await historyProvider.logAction(entry);

      // Update streaks
      final actionProvider = context.read<ActionProvider>();
      final action = widget.action;
      int newStreak = action.currentStreak;
      int newRecord = action.recordStreak;

      final bool isSuccess = (action.isPositive && _status == 1) ||
          (!action.isPositive && _status == 0);

      if (isSuccess) {
        newStreak++;
        if (newStreak > newRecord) newRecord = newStreak;
      } else {
        newStreak = 0;
      }

      await actionProvider.updateActionStreak(action.id!, newStreak, newRecord);

      // Update user score
      final userProvider = context.read<UserProvider>();
      await userProvider.refreshScore();

      // Reload today history
      final user = userProvider.user;
      if (user != null) {
        await historyProvider.loadTodayHistory(user.id!);
      }

      if (mounted) {
        _showResultFeedback(isSuccess);
        Navigator.of(context).pop(true);
      }
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

  void _showResultFeedback(bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.info_outline,
              color: isSuccess ? AppTheme.positiveColor : Colors.orange,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isSuccess
                    ? 'Bien joué ! Continue comme ça !'
                    : 'Chaque jour est une nouvelle chance de progresser.',
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final action = widget.action;
    final pts = action.importancePoints ?? 10;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saisir une réalisation'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Action info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecorationOf(context),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: action.isPositive
                      ? AppTheme.positiveColor
                      : AppTheme.negativeColor,
                  child: Icon(
                    action.isPositive
                        ? Icons.trending_up
                        : Icons.trending_down,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(action.name, style: AppTheme.headingSmallOf(context)),
                      Text(
                        '${action.importanceLabel ?? "Moyen"} · ${action.frequencyLabel}',
                        style: AppTheme.bodySmallOf(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Status selection
          Text('Statut', style: AppTheme.headingSmallOf(context)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatusOption(
                  1,
                  'Réalisé',
                  Icons.check_circle,
                  AppTheme.positiveColor,
                  '${action.isPositive ? "+" : "-"}$pts pts',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusOption(
                  0,
                  'Non réalisé',
                  Icons.cancel,
                  AppTheme.negativeColor,
                  '${action.isPositive ? "-" : "+"}$pts pts',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Comment
          TextFormField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: 'Commentaire (optionnel)',
              prefixIcon: Icon(Icons.comment_outlined),
            ),
            maxLines: 3,
          ),
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
                : const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOption(
      int status, String label, IconData icon, Color color, String points) {
    final selected = _status == status;
    return GestureDetector(
      onTap: () => setState(() => _status = status),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.2) : AppTheme.bgCardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? color : AppTheme.textMuted, size: 40),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? color : AppTheme.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              points,
              style: TextStyle(
                color: selected ? color : AppTheme.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
