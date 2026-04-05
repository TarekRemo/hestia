import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/action_provider.dart';
import '../providers/user_provider.dart';
import '../models/discipline_action.dart';
import '../theme/app_theme.dart';
import 'action_form_screen.dart';
import 'action_detail_screen.dart';

class ActionsScreen extends StatelessWidget {
  const ActionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Actions'),
      ),
      body: Consumer<ActionProvider>(
        builder: (context, actionProvider, _) {
          if (actionProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final positive = actionProvider.positiveActions;
          final negative = actionProvider.negativeActions;

          if (positive.isEmpty && negative.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.list_alt,
                      size: 80, color: AppTheme.textMuted),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune action définie',
                    style: AppTheme.headingSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ajoutez des actions pour commencer\nvotre parcours de discipline',
                    style: AppTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _addAction(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter une action'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (positive.isNotEmpty) ...[
                _buildSectionHeader(
                    'Actions positives', positive.length, AppTheme.positiveColor),
                const SizedBox(height: 8),
                ...positive.map((a) => _buildActionCard(context, a)),
                const SizedBox(height: 24),
              ],
              if (negative.isNotEmpty) ...[
                _buildSectionHeader(
                    'Actions négatives', negative.length, AppTheme.negativeColor),
                const SizedBox(height: 8),
                ...negative.map((a) => _buildActionCard(context, a)),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addAction(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(title, style: AppTheme.headingSmall),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, DisciplineAction action) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: action.isPositive
              ? AppTheme.positiveColor.withValues(alpha: 0.2)
              : AppTheme.negativeColor.withValues(alpha: 0.2),
          child: Icon(
            action.isPositive ? Icons.trending_up : Icons.trending_down,
            color: action.isPositive
                ? AppTheme.positiveColor
                : AppTheme.negativeColor,
          ),
        ),
        title: Text(action.name, style: AppTheme.bodyLarge),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                _buildTag(action.importanceLabel ?? 'Moyen',
                    AppTheme.accentColor),
                const SizedBox(width: 6),
                _buildTag(action.frequencyLabel, AppTheme.primaryLight),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.local_fire_department,
                    size: 14, color: Colors.orange),
                const SizedBox(width: 4),
                Text('Série: ${action.currentStreak}',
                    style: AppTheme.bodySmall),
                const SizedBox(width: 12),
                const Icon(Icons.star, size: 14, color: Colors.amber),
                const SizedBox(width: 4),
                Text('Record: ${action.recordStreak}',
                    style: AppTheme.bodySmall),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ActionDetailScreen(action: action),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }

  void _addAction(BuildContext context) async {
    final userId = context.read<UserProvider>().user?.id;
    if (userId == null) return;
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ActionFormScreen(userId: userId),
      ),
    );
    if (result == true) {
      // Refresh done via provider
    }
  }
}
