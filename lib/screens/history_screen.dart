import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/history_provider.dart';
import '../providers/user_provider.dart';
import '../providers/action_provider.dart';
import '../models/action_history.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedPeriod = 'week';
  int? _selectedActionId;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final user = context.read<UserProvider>().user;
    if (user == null) return;

    String? startDate;
    final now = DateTime.now();

    switch (_selectedPeriod) {
      case 'today':
        startDate = DateFormat('yyyy-MM-dd').format(now);
        startDate = '$startDate 00:00:00';
        break;
      case 'week':
        startDate = DateFormat('yyyy-MM-dd')
            .format(now.subtract(const Duration(days: 7)));
        startDate = '$startDate 00:00:00';
        break;
      case 'month':
        startDate = DateFormat('yyyy-MM-dd')
            .format(now.subtract(const Duration(days: 30)));
        startDate = '$startDate 00:00:00';
        break;
      case 'all':
        startDate = null;
        break;
    }

    await context
        .read<HistoryProvider>()
        .loadHistory(user.id!, startDate: startDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
      ),
      body: Column(
        children: [
          // Period filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildPeriodChip("Aujourd'hui", 'today'),
                const SizedBox(width: 8),
                _buildPeriodChip('7 jours', 'week'),
                const SizedBox(width: 8),
                _buildPeriodChip('30 jours', 'month'),
                const SizedBox(width: 8),
                _buildPeriodChip('Tout', 'all'),
              ],
            ),
          ),

          // Action filter
          Consumer<ActionProvider>(
            builder: (context, actionProvider, _) {
              if (actionProvider.actions.isEmpty) return const SizedBox();
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Toutes'),
                      selected: _selectedActionId == null,
                      onSelected: (_) {
                        setState(() => _selectedActionId = null);
                      },
                      selectedColor: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 6),
                    ...actionProvider.actions.map((a) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(a.name),
                            selected: _selectedActionId == a.id,
                            onSelected: (_) {
                              setState(() => _selectedActionId = a.id);
                            },
                            selectedColor: AppTheme.primaryColor,
                          ),
                        )),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),

          // History list
          Expanded(
            child: Consumer<HistoryProvider>(
              builder: (context, historyProvider, _) {
                if (historyProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                var history = historyProvider.history;
                if (_selectedActionId != null) {
                  history = history
                      .where((h) => h.actionId == _selectedActionId)
                      .toList();
                }

                if (history.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history,
                            size: 64, color: AppTheme.textMuted),
                        SizedBox(height: 16),
                        Text('Aucun historique',
                            style: AppTheme.headingSmall),
                        SizedBox(height: 4),
                        Text(
                          'Saisissez vos premières réalisations\npour voir l\'historique ici',
                          style: AppTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // Group by date
                final grouped = <String, List<ActionHistory>>{};
                for (var h in history) {
                  final day = h.date.length >= 10
                      ? h.date.substring(0, 10)
                      : h.date;
                  grouped.putIfAbsent(day, () => []).add(h);
                }
                final sortedDays = grouped.keys.toList()
                  ..sort((a, b) => b.compareTo(a));

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: sortedDays.length,
                  itemBuilder: (context, index) {
                    final day = sortedDays[index];
                    final entries = grouped[day]!;
                    final dayScore = entries.fold<int>(
                        0, (sum, e) => sum + e.scoreImpact);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(day, style: AppTheme.headingSmall),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: dayScore >= 0
                                      ? AppTheme.positiveColor
                                          .withValues(alpha: 0.2)
                                      : AppTheme.negativeColor
                                          .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${dayScore >= 0 ? "+" : ""}$dayScore pts',
                                  style: TextStyle(
                                    color: dayScore >= 0
                                        ? AppTheme.positiveColor
                                        : AppTheme.negativeColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...entries.map((h) => _buildHistoryTile(h)),
                        const Divider(),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedPeriod == value,
      onSelected: (_) {
        setState(() => _selectedPeriod = value);
        _loadHistory();
      },
      selectedColor: AppTheme.primaryColor,
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
        color = AppTheme.textMuted;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(h.actionName ?? 'Action', style: AppTheme.bodyLarge),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(h.statusLabel, style: AppTheme.bodySmall),
            if (h.userComment != null && h.userComment!.isNotEmpty)
              Text(h.userComment!,
                  style: AppTheme.bodySmall
                      .copyWith(fontStyle: FontStyle.italic)),
          ],
        ),
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
}
