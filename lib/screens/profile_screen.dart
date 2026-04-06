import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../models/app_user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _restMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          final user = userProvider.user;
          if (user == null) return const SizedBox();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Avatar & name
              Container(
                padding: const EdgeInsets.all(24),
                decoration: AppTheme.cardDecorationOf(context),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppTheme.primaryColor,
                      child: Text(
                        '${user.firstname[0]}${user.lastname[0]}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${user.firstname} ${user.lastname}',
                      style: AppTheme.headingMediumOf(context),
                    ),
                    const SizedBox(height: 4),
                    Text(user.mail, style: AppTheme.bodyMediumOf(context)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.emoji_events,
                              color: Colors.amber, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            user.disciplineLevel,
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Stats summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.cardDecorationOf(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Résumé', style: AppTheme.headingSmallOf(context)),
                    const SizedBox(height: 12),
                    _buildProfileRow(
                        Icons.score, 'Score total', '${user.totalScore}'),
                    _buildProfileRow(Icons.local_fire_department,
                        'Série actuelle', '${user.currentDisciplineStreak} jours'),
                    _buildProfileRow(Icons.star, 'Série record',
                        '${user.maxDisciplineStreak} jours'),
                    _buildProfileRow(Icons.cake, 'Date de naissance',
                        user.birthDate),
                    _buildProfileRow(
                        Icons.person, 'Genre',
                        user.gender == 'male' ? 'Homme' : 'Femme'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Rest mode
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.cardDecorationOf(context),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Mode repos', style: AppTheme.bodyLargeOf(context)),
                  subtitle: Text(
                    'Désactive les pénalités (repos, maladie)',
                    style: AppTheme.bodySmallOf(context),
                  ),
                  value: _restMode,
                  onChanged: (val) => setState(() => _restMode = val),
                  activeTrackColor: AppTheme.primaryColor.withValues(alpha: 0.5),
                  inactiveThumbColor: AppTheme.textMutedOf(context),
                  thumbColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppTheme.primaryColor;
                    }
                      return AppTheme.textMutedOf(context);
                  }),
                  secondary: Icon(
                    _restMode ? Icons.bedtime : Icons.bedtime_outlined,
                    color:
                        _restMode ? AppTheme.primaryColor : AppTheme.textMutedOf(context),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Theme toggle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.cardDecorationOf(context),
                child: Consumer<ThemeProvider>(
                  builder: (context, themeProvider, _) {
                    return SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Thème sombre', style: AppTheme.bodyLargeOf(context)),
                      subtitle: Text(
                        themeProvider.isDarkMode ? 'Mode sombre activé' : 'Mode clair activé',
                        style: AppTheme.bodySmallOf(context),
                      ),
                      value: themeProvider.isDarkMode,
                      onChanged: (_) => themeProvider.toggleTheme(),
                      activeTrackColor: AppTheme.primaryColor.withValues(alpha: 0.5),
                      inactiveThumbColor: AppTheme.textMutedOf(context),
                      thumbColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return AppTheme.primaryColor;
                        }
                        return AppTheme.textMutedOf(context);
                      }),
                      secondary: Icon(
                        themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color: themeProvider.isDarkMode ? AppTheme.primaryColor : AppTheme.warningColor,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Edit profile
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.cardDecorationOf(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Paramètres', style: AppTheme.headingSmallOf(context)),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.edit,
                          color: AppTheme.primaryColor),
                      title: Text('Modifier le profil',
                          style: AppTheme.bodyLargeOf(context)),
                      trailing: Icon(Icons.chevron_right,
                          color: AppTheme.textMutedOf(context)),
                      onTap: () => _editProfile(user),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.notifications_outlined,
                          color: AppTheme.accentColor),
                      title: Text('Notifications',
                          style: AppTheme.bodyLargeOf(context)),
                      trailing: Icon(Icons.chevron_right,
                          color: AppTheme.textMutedOf(context)),
                      onTap: () => _showNotificationSettings(),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.info_outline,
                          color: AppTheme.textMutedOf(context)),
                      title: Text('À propos',
                          style: AppTheme.bodyLargeOf(context)),
                      trailing: Icon(Icons.chevron_right,
                          color: AppTheme.textMutedOf(context)),
                      onTap: () => _showAbout(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Messages de motivation
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.cardDecorationOf(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Messages de motivation',
                        style: AppTheme.headingSmallOf(context)),
                    const SizedBox(height: 12),
                    Text(
                      'Personnalisez les messages qui apparaissent après vos actions.',
                      style: AppTheme.bodyMediumOf(context),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.celebration,
                          color: AppTheme.positiveColor),
                      title: const Text('Après un succès'),
                      subtitle: const Text('Ex: Bravo, continue !'),
                      onTap: () => _editMotivationMessage('succès'),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.sentiment_dissatisfied,
                          color: AppTheme.warningColor),
                      title: const Text('Après un échec'),
                      subtitle: const Text(
                          'Ex: Tu n\'as pas échoué, tu as appris.'),
                      onTap: () => _editMotivationMessage('échec'),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.trending_down,
                          color: AppTheme.negativeColor),
                      title: const Text('Baisse du score'),
                      subtitle: const Text(
                          'Ex: Chaque effort compte, même petit.'),
                      onTap: () => _editMotivationMessage('baisse'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textMuted),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppTheme.bodyMediumOf(context))),
          Text(value, style: AppTheme.bodyLargeOf(context)),
        ],
      ),
    );
  }

  void _editProfile(AppUser user) {
    final firstnameController =
        TextEditingController(text: user.firstname);
    final lastnameController =
        TextEditingController(text: user.lastname);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modifier le profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: firstnameController,
              decoration: const InputDecoration(labelText: 'Prénom'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lastnameController,
              decoration: const InputDecoration(labelText: 'Nom'),
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
              final updated = user.copyWith(
                firstname: firstnameController.text.trim(),
                lastname: lastnameController.text.trim(),
              );
              await context.read<UserProvider>().updateUser(updated);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Notifications'),
        content: const Text(
          'Les rappels de notification sont automatiquement configurés pour chaque action ayant des plages horaires définies.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Discipline',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 Discipline App',
      children: [
        const SizedBox(height: 16),
        const Text(
          'Application de suivi de discipline personnelle. '
          'Développez et maintenez vos bonnes habitudes grâce à un '
          'système de score, de séries et de statistiques.',
        ),
      ],
    );
  }

  void _editMotivationMessage(String type) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Message: $type'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Saisissez votre message de motivation...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // Save message (could be stored in SharedPreferences or DB)
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Message enregistré')),
              );
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
