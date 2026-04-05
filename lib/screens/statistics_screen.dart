import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/user_provider.dart';
import '../providers/action_provider.dart';
import '../providers/history_provider.dart';
import '../models/discipline_action.dart';
import '../theme/app_theme.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedDays = 7;
  Map<String, double> _scoreEvolution = {};
  Map<int, double> _successRates = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final user = context.read<UserProvider>().user;
    if (user == null) return;

    final historyProvider = context.read<HistoryProvider>();
    _scoreEvolution =
        await historyProvider.getScoreEvolution(user.id!, _selectedDays);

    // Load success rates for each action
    final actions = context.read<ActionProvider>().actions;
    _successRates = {};
    for (var action in actions) {
      _successRates[action.id!] =
          await historyProvider.getSuccessRate(action.id!);
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Score'),
            Tab(text: 'Actions'),
            Tab(text: 'Détails'),
          ],
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textMuted,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildScoreTab(),
                _buildActionsTab(),
                _buildDetailsTab(),
              ],
            ),
    );
  }

  Widget _buildScoreTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Period selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _periodButton('7J', 7),
              const SizedBox(width: 8),
              _periodButton('30J', 30),
              const SizedBox(width: 8),
              _periodButton('90J', 90),
              const SizedBox(width: 8),
              _periodButton('365J', 365),
            ],
          ),
          const SizedBox(height: 24),

          // Score evolution chart
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Évolution du score',
                    style: AppTheme.headingSmall),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: _buildScoreChart(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Score summary
          _buildScoreSummary(),
        ],
      ),
    );
  }

  Widget _periodButton(String label, int days) {
    final selected = _selectedDays == days;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedDays = days);
        _loadStats();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor : AppTheme.bgCardLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppTheme.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildScoreChart() {
    if (_scoreEvolution.isEmpty) {
      return const Center(
        child: Text('Pas de données pour cette période',
            style: AppTheme.bodyMedium),
      );
    }

    final entries = _scoreEvolution.entries.toList();
    // Calculate cumulative score
    double cumulative = 0;
    final spots = <FlSpot>[];
    for (int i = 0; i < entries.length; i++) {
      cumulative += entries[i].value;
      spots.add(FlSpot(i.toDouble(), cumulative));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppTheme.bgCardLight,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: AppTheme.bodySmall,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (entries.length / 5).ceilToDouble().clamp(1, 100),
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= entries.length) return const Text('');
                final date = entries[idx].key;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    date.length >= 10 ? date.substring(5) : date,
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.textMuted),
                  ),
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.primaryColor,
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryColor.withValues(alpha: 0.15),
            ),
            dotData: const FlDotData(show: false),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) {
              return spots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toInt()} pts',
                  const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildScoreSummary() {
    final user = context.watch<UserProvider>().user;
    final total = user?.totalScore ?? 0;
    final dayAvg = _scoreEvolution.isNotEmpty
        ? _scoreEvolution.values.reduce((a, b) => a + b) /
            _scoreEvolution.length
        : 0.0;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecoration,
            child: Column(
              children: [
                const Text('Score total', style: AppTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  '$total',
                  style: AppTheme.headingMedium
                      .copyWith(color: AppTheme.primaryColor),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecoration,
            child: Column(
              children: [
                const Text('Moy/jour', style: AppTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  dayAvg.toStringAsFixed(1),
                  style: AppTheme.headingMedium.copyWith(
                    color: dayAvg >= 0
                        ? AppTheme.positiveColor
                        : AppTheme.negativeColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionsTab() {
    final actions = context.watch<ActionProvider>().actions;

    if (actions.isEmpty) {
      return const Center(
        child: Text('Aucune action définie', style: AppTheme.bodyMedium),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Success rate bar chart
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Taux de réussite par action',
                    style: AppTheme.headingSmall),
                const SizedBox(height: 16),
                SizedBox(
                  height: (actions.length * 60.0).clamp(150, 400),
                  child: _buildSuccessRateChart(actions),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Streaks comparison
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Séries par action',
                    style: AppTheme.headingSmall),
                const SizedBox(height: 12),
                ...actions.map((a) => _buildStreakRow(a)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessRateChart(List<DisciplineAction> actions) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toInt()}%',
                const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()}%',
                style: AppTheme.bodySmall,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= actions.length) return const Text('');
                final name = actions[idx].name;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    name.length > 8 ? '${name.substring(0, 8)}...' : name,
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.textMuted),
                  ),
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppTheme.bgCardLight,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(actions.length, (i) {
          final rate = (_successRates[actions[i].id] ?? 0) * 100;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: rate,
                color: actions[i].isPositive
                    ? AppTheme.positiveColor
                    : AppTheme.negativeColor,
                width: 20,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStreakRow(DisciplineAction action) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(action.name, style: AppTheme.bodyLarge),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const Icon(Icons.local_fire_department,
                    size: 16, color: Colors.orange),
                const SizedBox(width: 4),
                Text('${action.currentStreak}',
                    style: AppTheme.bodyMedium),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text('${action.recordStreak}',
                    style: AppTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    final actions = context.watch<ActionProvider>().actions;
    final user = context.watch<UserProvider>().user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Pie chart: positive vs negative actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Répartition des actions',
                    style: AppTheme.headingSmall),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _buildPieChart(actions),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Discipline info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecoration,
            child: Column(
              children: [
                const Text('Niveau de discipline',
                    style: AppTheme.headingSmall),
                const SizedBox(height: 12),
                _buildLevelProgress(user?.currentDisciplineStreak ?? 0),
                const SizedBox(height: 12),
                Text(
                  user?.disciplineLevel ?? 'Débutant',
                  style: AppTheme.headingMedium
                      .copyWith(color: AppTheme.primaryColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Badges
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Badges', style: AppTheme.headingSmall),
                const SizedBox(height: 12),
                Consumer<UserProvider>(
                  builder: (context, userProvider, _) {
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: userProvider.badges.map((badge) {
                        final earned = (user?.currentDisciplineStreak ?? 0) >=
                            badge.minStreak;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: earned
                                ? AppTheme.primaryColor.withValues(alpha: 0.2)
                                : AppTheme.bgCardLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: earned
                                  ? AppTheme.primaryColor
                                  : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                earned ? Icons.emoji_events : Icons.lock,
                                color:
                                    earned ? Colors.amber : AppTheme.textMuted,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                badge.label,
                                style: TextStyle(
                                  color:
                                      earned ? Colors.white : AppTheme.textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${badge.minStreak}j)',
                                style: TextStyle(
                                  color:
                                      earned ? Colors.white70 : AppTheme.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(List<DisciplineAction> actions) {
    final positive = actions.where((a) => a.isPositive).length;
    final negative = actions.where((a) => !a.isPositive).length;
    final total = actions.length;

    if (total == 0) {
      return const Center(
        child: Text('Aucune donnée', style: AppTheme.bodyMedium),
      );
    }

    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: positive.toDouble(),
            title: '$positive',
            color: AppTheme.positiveColor,
            radius: 60,
            titleStyle: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          PieChartSectionData(
            value: negative.toDouble(),
            title: '$negative',
            color: AppTheme.negativeColor,
            radius: 60,
            titleStyle: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
        centerSpaceRadius: 30,
        sectionsSpace: 2,
      ),
    );
  }

  Widget _buildLevelProgress(int streak) {
    // Levels: 0-6 Débutant, 7-29 Régulier, 30-89 Discipliné, 90+ Exemplaire
    double progress;
    String nextLevel;
    int target;

    if (streak < 7) {
      progress = streak / 7;
      nextLevel = 'Régulier';
      target = 7;
    } else if (streak < 30) {
      progress = (streak - 7) / (30 - 7);
      nextLevel = 'Discipliné';
      target = 30;
    } else if (streak < 90) {
      progress = (streak - 30) / (90 - 30);
      nextLevel = 'Exemplaire';
      target = 90;
    } else {
      progress = 1.0;
      nextLevel = 'Max!';
      target = streak;
    }

    return Column(
      children: [
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: AppTheme.bgCardLight,
          valueColor:
              const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 6),
        Text(
          'Prochain niveau: $nextLevel ($streak/$target jours)',
          style: AppTheme.bodySmall,
        ),
      ],
    );
  }
}
