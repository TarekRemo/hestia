import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/partner_store.dart';
import '../models/gift_card_redemption.dart';
import '../providers/gift_card_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';

class GiftCardStoreScreen extends StatefulWidget {
  const GiftCardStoreScreen({super.key});

  @override
  State<GiftCardStoreScreen> createState() => _GiftCardStoreScreenState();
}

class _GiftCardStoreScreenState extends State<GiftCardStoreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _availablePoints;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final user = context.read<UserProvider>().user;
    if (user == null) return;
    final provider = context.read<GiftCardProvider>();
    await provider.loadRedemptions(user.id!);
    final available =
        await provider.getAvailablePoints(user.id!, user.totalScore);
    if (mounted) setState(() => _availablePoints = available);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boutique cadeaux'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textMutedOf(context),
          tabs: const [
            Tab(text: 'Boutique', icon: Icon(Icons.storefront)),
            Tab(text: 'Mes cartes', icon: Icon(Icons.card_giftcard)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStoreTab(),
          _buildRedemptionsTab(),
        ],
      ),
    );
  }

  // ─── STORE TAB ───
  Widget _buildStoreTab() {
    final user = context.watch<UserProvider>().user;
    if (user == null) return const SizedBox();

    final level = user.disciplineLevel;
    final availableStores = PartnerStore.getStoresForLevel(level);
    final lockedStores = PartnerStore.stores
        .where((s) => !availableStores.contains(s))
        .toList();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPointsBanner(user.totalScore),
            const SizedBox(height: 16),
            _buildConversionInfo(),
            const SizedBox(height: 20),
            Text('Enseignes disponibles', style: AppTheme.headingSmallOf(context)),
            const SizedBox(height: 12),
            ...availableStores.map((store) => _buildStoreCard(store, true)),
            if (lockedStores.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('Enseignes à débloquer', style: AppTheme.headingSmallOf(context)),
              const SizedBox(height: 4),
              Text(
                'Augmentez votre série pour accéder à plus d\'enseignes',
                style: AppTheme.bodySmallOf(context),
              ),
              const SizedBox(height: 12),
              ...lockedStores.map((store) => _buildStoreCard(store, false)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPointsBanner(int totalScore) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.gradientCardDecoration,
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet, color: Colors.white, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Points disponibles',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_availablePoints ?? totalScore}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Valeur',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                '${((_availablePoints ?? totalScore) / PartnerStore.pointsPerEuro).toStringAsFixed(2)} €',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConversionInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${PartnerStore.pointsPerEuro} points = 1 € · Échangez vos points contre des cartes cadeaux simulées !',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCard(PartnerStore store, bool unlocked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: unlocked
            ? AppTheme.bgCardOf(context)
            : AppTheme.bgCardLightOf(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: unlocked
            ? [
                BoxShadow(
                  color: AppTheme.isDark(context)
                      ? Colors.black.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: unlocked
                  ? AppTheme.primaryColor.withValues(alpha: 0.15)
                  : AppTheme.textMutedOf(context).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              store.icon,
              color: unlocked
                  ? AppTheme.primaryColor
                  : AppTheme.textMutedOf(context),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: unlocked
                        ? AppTheme.textPrimaryOf(context)
                        : AppTheme.textMutedOf(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  store.category,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondaryOf(context),
                  ),
                ),
                if (!unlocked) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.lock_outline, size: 14, color: AppTheme.warningColor),
                      const SizedBox(width: 4),
                      Text(
                        'Niveau ${store.requiredLevel} requis',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.warningColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (unlocked)
            ElevatedButton(
              onPressed: () => _showAmountPicker(store),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: Size.zero,
              ),
              child: const Text('Échanger'),
            ),
        ],
      ),
    );
  }

  void _showAmountPicker(PartnerStore store) {
    final available = _availablePoints ?? 0;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgCardOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(store.icon, color: AppTheme.primaryColor, size: 28),
                  const SizedBox(width: 12),
                  Text(store.name, style: AppTheme.headingMediumOf(context)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Points disponibles : $available (${(available / PartnerStore.pointsPerEuro).toStringAsFixed(2)} €)',
                style: AppTheme.bodyMediumOf(context),
              ),
              const SizedBox(height: 20),
              Text('Choisissez un montant :', style: AppTheme.bodyLargeOf(context)),
              const SizedBox(height: 12),
              ...store.availableAmounts.map((amount) {
                final cost = PartnerStore.euroToPoints(amount);
                final canAfford = cost <= available;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton(
                    onPressed: canAfford
                        ? () {
                            Navigator.pop(ctx);
                            _confirmRedemption(store, amount, cost);
                          }
                        : null,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: canAfford
                            ? AppTheme.primaryColor
                            : AppTheme.textMutedOf(context),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Carte $amount €',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: canAfford
                                ? AppTheme.primaryColor
                                : AppTheme.textMutedOf(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '($cost pts)',
                          style: TextStyle(
                            fontSize: 14,
                            color: canAfford
                                ? AppTheme.textSecondaryOf(context)
                                : AppTheme.textMutedOf(context),
                          ),
                        ),
                        if (!canAfford) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.lock_outline, size: 16, color: AppTheme.warningColor),
                        ],
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _confirmRedemption(PartnerStore store, int euroAmount, int pointsCost) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer l\'échange'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.textPrimaryOf(context),
                ),
                children: [
                  const TextSpan(text: 'Vous allez échanger '),
                  TextSpan(
                    text: '$pointsCost points',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' contre une carte cadeau '),
                  TextSpan(
                    text: '${store.name} de $euroAmount €',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Cette action est irréversible.',
              style: TextStyle(
                color: AppTheme.warningColor,
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _executeRedemption(store, euroAmount);
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  Future<void> _executeRedemption(PartnerStore store, int euroAmount) async {
    final user = context.read<UserProvider>().user;
    if (user == null) return;

    final provider = context.read<GiftCardProvider>();
    final success = await provider.redeemGiftCard(
      userId: user.id!,
      totalScore: user.totalScore,
      store: store,
      euroAmount: euroAmount,
    );

    if (!mounted) return;

    if (success) {
      final available =
          await provider.getAvailablePoints(user.id!, user.totalScore);
      setState(() => _availablePoints = available);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.celebration, color: Colors.white),
              const SizedBox(width: 8),
              Text('Carte ${store.name} $euroAmount € obtenue !'),
            ],
          ),
          backgroundColor: AppTheme.positiveColor,
        ),
      );
      _tabController.animateTo(1);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Points insuffisants pour cet échange.'),
          backgroundColor: AppTheme.negativeColor,
        ),
      );
    }
  }

  // ─── REDEMPTIONS TAB ───
  Widget _buildRedemptionsTab() {
    return Consumer<GiftCardProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.redemptions.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.card_giftcard,
                    size: 64,
                    color: AppTheme.textMutedOf(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune carte obtenue',
                    style: AppTheme.headingSmallOf(context),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Échangez vos points dans la boutique pour obtenir des cartes cadeaux !',
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyMediumOf(context),
                  ),
                ],
              ),
            ),
          );
        }

        final totalValue = provider.redemptions
            .fold<double>(0, (sum, r) => sum + r.euroValue);

        return RefreshIndicator(
          onRefresh: _loadData,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildTotalRedeemed(provider.redemptions.length, totalValue),
              const SizedBox(height: 16),
              ...provider.redemptions.map(_buildRedemptionCard),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTotalRedeemed(int count, double totalValue) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecorationOf(context),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, color: Colors.amber, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total obtenu', style: AppTheme.headingSmallOf(context)),
                const SizedBox(height: 4),
                Text(
                  '$count carte${count > 1 ? 's' : ''} · ${totalValue.toStringAsFixed(0)} €',
                  style: AppTheme.bodyMediumOf(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRedemptionCard(GiftCardRedemption redemption) {
    final store = PartnerStore.stores
        .where((s) => s.name == redemption.storeName)
        .firstOrNull;
    final icon = store?.icon ?? Icons.card_giftcard;

    String formattedDate = '';
    if (redemption.redeemedAt != null) {
      try {
        final dt = DateTime.parse(redemption.redeemedAt!);
        formattedDate =
            '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
      } catch (_) {
        formattedDate = redemption.redeemedAt!;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.cardDecorationOf(context),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  redemption.storeName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryOf(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryOf(context),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${redemption.euroValue.toStringAsFixed(0)} €',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              Text(
                '${redemption.pointsSpent} pts',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMutedOf(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
