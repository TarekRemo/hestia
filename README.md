# Hestia

**Application mobile de suivi de discipline personnelle** développée avec Flutter. Développez et maintenez vos bonnes habitudes grâce à un système de score, de séries, de badges et de récompenses.

---

## Sommaire

- [Présentation](#présentation)
- [Fonctionnalités](#fonctionnalités)
- [Système de score](#système-de-score)
- [Niveaux et badges](#niveaux-et-badges)
- [Boutique de cartes cadeaux](#boutique-de-cartes-cadeaux)
- [Architecture technique](#architecture-technique)
- [Installation](#installation)
- [Dépendances](#dépendances)

---

## Présentation

**Discipline** est une application de développement personnel qui vous aide à construire de bonnes habitudes et à éliminer les mauvaises. Chaque jour, vous enregistrez vos progrès sur les actions que vous avez définies, et l'application calcule votre score de discipline, suit vos séries consécutives et vous récompense avec des badges et des cartes cadeaux simulées.

L'interface est entièrement en français et supporte les thèmes clair et sombre.

---

## Fonctionnalités

### Gestion des actions

- **Actions positives** : habitudes à développer (sport, lecture, méditation…). Les réaliser rapporte des points, ne pas les réaliser en retire.
- **Actions négatives** : habitudes à éliminer (tabac, malbouffe…). S'en abstenir rapporte des points, y succomber en retire.
- **Fréquence** : quotidienne, hebdomadaire ou personnalisée (tous les N jours).
- **Niveaux d'importance** : Faible (5 pts), Moyen (10 pts), Élevé (20 pts).
- **Plages horaires** : définissez des créneaux pour chaque action (ex : 8h00–9h00).
- **Notifications personnalisées** : 4 types par action — motivation, rappel, succès et échec.

### Tableau de bord

- Message d'accueil contextuel (Bonjour / Bon après-midi / Bonsoir).
- **Carte de score** avec gradient et affichage du niveau actuel.
- **Séries** : série actuelle et record personnel.
- **Progression du jour** : indicateur circulaire du pourcentage d'actions saisies.
- **Actions en attente** : saisie rapide des actions non encore enregistrées.
- **Citation de motivation** : message inspirant rotatif.
- **Accès rapide** à la boutique de cartes cadeaux.

### Historique

- Historique complet de toutes les actions enregistrées, regroupées par date.
- Filtres par période : aujourd'hui, 7 jours, 30 jours ou tout l'historique.
- Filtre par action spécifique.
- Score quotidien affiché pour chaque journée.

### Statistiques (3 onglets)

1. **Score** : graphique en courbe de l'évolution cumulative du score (7j / 30j / 90j / 365j).
2. **Actions** : taux de réussite par action avec diagrammes en barres.
3. **Détails** : progression des badges, niveau actuel, séries et score total.

### Profil et paramètres

- Carte profil avec avatar (initiales), nom, email et niveau de discipline.
- Résumé : score total, série actuelle, série record, date de naissance, genre.
- **Mode repos** : désactive les pénalités en cas de repos ou de maladie.
- **Thème sombre / clair** : bascule persistante via SharedPreferences.
- **Messages de motivation** personnalisables : après un succès, un échec ou une baisse du score.
- Modifier le profil, paramètres de notifications, à propos.
- Accès à la boutique de cartes cadeaux.

### Suivi des actions (saisie)

- Enregistrement du statut : réalisé ou non réalisé.
- Commentaire optionnel pour chaque entrée.
- Affichage de l'impact en points avant validation.
- Message de retour motivant après l'enregistrement.

---

## Système de score

Le score total est calculé à partir de l'ensemble des actions enregistrées :

| Situation | Action positive | Action négative |
|---|---|---|
| **Réalisée** | + points d'importance | − points d'importance |
| **Non réalisée** | − points d'importance | + points d'importance |

**Points par importance :**

| Importance | Points |
|---|---|
| Faible | 5 |
| Moyen | 10 |
| Élevé | 20 |

**Séries :** la série actuelle s'incrémente chaque jour où toutes les actions sont réalisées. Elle se remet à zéro au moindre échec. Le record est conservé indéfiniment.

---

## Niveaux et badges

Le niveau de discipline est déterminé par la série actuelle consécutive :

| Niveau | Série requise | Badge |
|---|---|---|
| 🌱 Débutant | 0 – 6 jours | Débutant |
| 💪 Régulier | 7 – 29 jours | Régulier |
| 🏆 Discipliné | 30 – 89 jours | Discipliné |
| ⭐ Exemplaire | 90+ jours | Exemplaire |

---

## Boutique de cartes cadeaux

Échangez vos points contre des cartes cadeaux simulées de grandes enseignes. **Taux de conversion : 100 points = 1 €.**

Les enseignes accessibles dépendent de votre niveau de discipline :

| Enseigne | Catégorie | Niveau requis | Montants |
|---|---|---|---|
| Decathlon | Sport | Débutant | 5 €, 10 €, 25 € |
| Leclerc | Courses | Débutant | 5 €, 10 €, 25 € |
| Intersport | Sport | Régulier | 5 €, 10 €, 25 € |
| Cultura | Culture | Régulier | 5 €, 10 €, 25 € |
| Nike | Sport | Discipliné | 10 €, 25 €, 50 € |
| Fnac | Tech & Culture | Discipliné | 10 €, 25 €, 50 € |
| Sephora | Beauté | Discipliné | 10 €, 25 €, 50 € |
| Apple | Tech | Exemplaire | 25 €, 50 €, 100 € |
| Amazon | Général | Exemplaire | 25 €, 50 €, 100 € |
| Darty | Électroménager | Exemplaire | 25 €, 50 €, 100 € |

- Les **points disponibles** = score total − points déjà échangés.
- L'utilisateur choisit une enseigne et un montant, puis confirme l'échange.
- L'onglet **Mes cartes** affiche l'historique complet des échanges.

---

## Architecture technique

### Structure du projet

```
lib/
├── main.dart                      # Point d'entrée, configuration des providers
├── database/
│   └── database_helper.dart       # SQLite : schéma, migrations, requêtes
├── models/
│   ├── app_user.dart              # Modèle utilisateur
│   ├── discipline_action.dart     # Modèle action
│   ├── action_history.dart        # Historique des actions
│   ├── action_importance.dart     # Niveaux d'importance
│   ├── action_notification.dart   # Notifications personnalisées
│   ├── action_time_slot.dart      # Plages horaires
│   ├── discipline_badge.dart      # Badges de discipline
│   ├── gift_card_redemption.dart  # Échanges de cartes cadeaux
│   └── partner_store.dart         # Catalogue des enseignes partenaires
├── providers/
│   ├── user_provider.dart         # État utilisateur, score, séries
│   ├── action_provider.dart       # CRUD actions, créneaux, notifications
│   ├── history_provider.dart      # Historique, statistiques, score quotidien
│   ├── gift_card_provider.dart    # Échanges de cartes cadeaux
│   └── theme_provider.dart        # Thème clair / sombre
├── screens/
│   ├── onboarding_screen.dart     # Inscription
│   ├── home_screen.dart           # Navigation principale (5 onglets)
│   ├── dashboard_screen.dart      # Tableau de bord
│   ├── actions_screen.dart        # Liste des actions
│   ├── action_detail_screen.dart  # Détail d'une action
│   ├── action_form_screen.dart    # Formulaire création / édition d'action
│   ├── log_action_screen.dart     # Saisie d'une réalisation
│   ├── history_screen.dart        # Historique
│   ├── statistics_screen.dart     # Statistiques et graphiques
│   ├── profile_screen.dart        # Profil et paramètres
│   └── gift_card_store_screen.dart # Boutique de cartes cadeaux
└── theme/
    └── app_theme.dart             # Thèmes Material, couleurs, styles
```

### Technologies

- **Flutter** — Framework UI multiplateforme
- **Provider** — Gestion d'état avec ChangeNotifier
- **SQLite (sqflite)** — Base de données locale relationnelle
- **SharedPreferences** — Persistance légère (préférence de thème)
- **fl_chart** — Graphiques (courbes, barres)
- **flutter_local_notifications** — Notifications push locales
- **intl** — Formatage des dates en français

### Base de données

7 tables avec clés étrangères et index :

- `APP_USER` — Utilisateur unique, score, séries
- `DISCIPLINE_BADGE` — 4 badges pré-remplis
- `ACTION_IMPORTANCE` — 3 niveaux pré-remplis
- `ACTION` — Actions de l'utilisateur
- `ACTION_HISTORY` — Journal des réalisations
- `ACTION_TIME_SLOT` — Créneaux horaires par action
- `ACTION_NOTIFICATION` — Notifications personnalisées par action
- `GIFT_CARD_REDEMPTION` — Historique des échanges de cartes cadeaux

---

## Installation

### Prérequis

- Flutter SDK (version stable)
- Android Studio ou VS Code avec l'extension Flutter
- Un émulateur ou appareil physique (Android / iOS)

### Lancement

```bash
# Cloner le dépôt
git clone <url-du-repo>
cd discipline_app

# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run
```

---

## Dépendances

| Package | Usage |
|---|---|
| `provider` | Gestion d'état |
| `sqflite` | Base de données SQLite |
| `path` | Manipulation de chemins |
| `shared_preferences` | Stockage clé-valeur (thème) |
| `fl_chart` | Graphiques statistiques |
| `flutter_local_notifications` | Notifications locales |
| `intl` | Localisation française |
| `timezone` | Support des fuseaux horaires |
| `percent_indicator` | Indicateurs de progression circulaires |
| `cupertino_icons` | Icônes iOS |

---

*Développé avec Flutter — © 2026 Discipline App*
