import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../providers/user_provider.dart';
import '../providers/action_provider.dart';
import '../providers/history_provider.dart';
import '../models/discipline_action.dart';
import '../theme/app_theme.dart';
import 'log_action_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    final user = context.read<UserProvider>().user;
    if (user != null) {
      await context.read<HistoryProvider>().loadTodayHistory(user.id!);
      await context.read<UserProvider>().refreshScore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discipline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildGreeting(),
              const SizedBox(height: 16),
              _buildScoreCard(),
              const SizedBox(height: 16),
              _buildStreakCard(),
              const SizedBox(height: 16),
              _buildTodayProgress(),
              const SizedBox(height: 16),
              _buildQuickActions(),
              const SizedBox(height: 16),
              _buildMotivationCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    final user = context.watch<UserProvider>().user;
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Bonjour';
    } else if (hour < 18) {
      greeting = 'Bon après-midi';
    } else {
      greeting = 'Bonsoir';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, ${user?.firstname ?? ''}!',
          style: AppTheme.headingLargeOf(context),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(DateTime.now()),
          style: AppTheme.bodyMediumOf(context),
        ),
      ],
    );
  }

  Widget _buildScoreCard() {
    final user = context.watch<UserProvider>().user;
    final badge = context.watch<UserProvider>().currentBadge;
    final score = user?.totalScore ?? 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.gradientCardDecoration,
      child: Column(
        children: [
          const Text(
            'Score de discipline',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$score',
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    badge.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Text(
            'Niveau: ${user?.disciplineLevel ?? "Débutant"}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    final user = context.watch<UserProvider>().user;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecorationOf(context),
            child: Column(
              children: [
                const Icon(Icons.local_fire_department,
                    color: Colors.orange, size: 32),
                const SizedBox(height: 8),
                Text(
                  '${user?.currentDisciplineStreak ?? 0}',
                  style: AppTheme.headingMediumOf(context),
                ),
                Text('Série actuelle', style: AppTheme.bodySmallOf(context)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecorationOf(context),
            child: Column(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 32),
                const SizedBox(height: 8),
                Text(
                  '${user?.maxDisciplineStreak ?? 0}',
                  style: AppTheme.headingMediumOf(context),
                ),
                Text('Record', style: AppTheme.bodySmallOf(context)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayProgress() {
    final actions = context.watch<ActionProvider>().actions;
    final todayHistory = context.watch<HistoryProvider>().todayHistory;

    final totalActions = actions.length;
    final loggedToday = todayHistory.where((h) => h.actionStatus != -1).length;
    final doneToday = todayHistory.where((h) => h.actionStatus == 1).length;
    final progress = totalActions > 0 ? loggedToday / totalActions : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecorationOf(context),
      child: Column(
        children: [
          Text("Progression d'aujourd'hui", style: AppTheme.headingSmallOf(context)),
          const SizedBox(height: 16),
          CircularPercentIndicator(
            radius: 60,
            lineWidth: 10,
            percent: progress.clamp(0.0, 1.0),
            center: Text(
              '${(progress * 100).toInt()}%',
              style: AppTheme.headingMediumOf(context),
            ),
            progressColor: AppTheme.primaryColor,
            backgroundColor: AppTheme.bgCardLightOf(context),
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMiniStat('Total', '$totalActions', AppTheme.textSecondary),
              _buildMiniStat('Réalisées', '$doneToday', AppTheme.positiveColor),
              _buildMiniStat('Saisies', '$loggedToday', AppTheme.accentColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: AppTheme.bodySmallOf(context)),
      ],
    );
  }

  Widget _buildQuickActions() {
    final actions = context.watch<ActionProvider>().actions;
    final todayHistory = context.watch<HistoryProvider>().todayHistory;

    // Actions not logged today
    final loggedActionIds =
        todayHistory.map((h) => h.actionId).toSet();
    final pendingActions =
        actions.where((a) => !loggedActionIds.contains(a.id)).toList();

    if (pendingActions.isEmpty && actions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.cardDecorationOf(context),
        child: Column(
          children: [
            Icon(Icons.add_circle_outline, size: 48, color: AppTheme.textMutedOf(context)),
            const SizedBox(height: 8),
            Text(
              'Aucune action définie',
              style: AppTheme.bodyMediumOf(context),
            ),
            const SizedBox(height: 4),
            Text(
              'Créez votre première action dans l\'onglet Actions',
              style: AppTheme.bodySmallOf(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecorationOf(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Actions en attente', style: AppTheme.headingSmallOf(context)),
              Text('${pendingActions.length}',
                  style: const TextStyle(
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          if (pendingActions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Toutes les actions ont été saisies ! 🎉',
                style: AppTheme.bodyMediumOf(context),
                textAlign: TextAlign.center,
              ),
            )
          else
            ...pendingActions.take(5).map(
                  (action) => _buildPendingActionTile(action),
                ),
        ],
      ),
    );
  }

  Widget _buildPendingActionTile(DisciplineAction action) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor:
            action.isPositive ? AppTheme.positiveColor : AppTheme.negativeColor,
        radius: 20,
        child: Icon(
          action.isPositive ? Icons.add : Icons.remove,
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(action.name, style: AppTheme.bodyLargeOf(context)),
      subtitle: Text(
        '${action.importanceLabel ?? ''} · ${action.frequencyLabel}',
        style: AppTheme.bodySmallOf(context),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check_circle, color: AppTheme.positiveColor),
            onPressed: () => _logAction(action, 1),
            tooltip: 'Réalisé',
          ),
          IconButton(
            icon: const Icon(Icons.cancel, color: AppTheme.negativeColor),
            onPressed: () => _logAction(action, 0),
            tooltip: 'Non réalisé',
          ),
        ],
      ),
    );
  }

  Future<void> _logAction(DisciplineAction action, int status) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            LogActionScreen(action: action, initialStatus: status),
      ),
    );
    if (result == true) {
      _refreshData();
    }
  }

  Widget _buildMotivationCard() {
    final messages = [
      'Chaque effort compte, même petit.',
      'La discipline est le pont entre les objectifs et les réalisations.',
      'Tu n\'as pas échoué, tu as juste appris.',
      'Le succès est la somme de petits efforts répétés jour après jour.',
      'La constance bat le talent quand le talent n\'est pas constant.',
      'Chaque jour est une nouvelle chance de progresser.',
    ];
    final today = DateTime.now().day;
    final message = messages[today % messages.length];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.3),
            AppTheme.accentColor.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.format_quote, color: AppTheme.accentColor, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppTheme.textPrimaryOf(context),
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
