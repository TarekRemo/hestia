import 'package:flutter/material.dart';

class PartnerStore {
  final String name;
  final IconData icon;
  final String category;
  final String requiredLevel;
  final List<int> availableAmounts;

  const PartnerStore({
    required this.name,
    required this.icon,
    required this.category,
    required this.requiredLevel,
    required this.availableAmounts,
  });

  /// 100 points = 1€
  static const int pointsPerEuro = 100;

  static int euroToPoints(int euros) => euros * pointsPerEuro;

  static const List<String> levelOrder = [
    'Débutant',
    'Régulier',
    'Discipliné',
    'Exemplaire',
  ];

  static List<PartnerStore> getStoresForLevel(String level) {
    final levelIndex = levelOrder.indexOf(level);
    if (levelIndex == -1) return stores.where((s) => s.requiredLevel == 'Débutant').toList();
    return stores
        .where((s) => levelOrder.indexOf(s.requiredLevel) <= levelIndex)
        .toList();
  }

  static const List<PartnerStore> stores = [
    // Débutant
    PartnerStore(
      name: 'Decathlon',
      icon: Icons.directions_run,
      category: 'Sport',
      requiredLevel: 'Débutant',
      availableAmounts: [5, 10, 25],
    ),
    PartnerStore(
      name: 'Leclerc',
      icon: Icons.shopping_cart,
      category: 'Courses',
      requiredLevel: 'Débutant',
      availableAmounts: [5, 10, 25],
    ),
    // Régulier
    PartnerStore(
      name: 'Intersport',
      icon: Icons.sports_tennis,
      category: 'Sport',
      requiredLevel: 'Régulier',
      availableAmounts: [5, 10, 25],
    ),
    PartnerStore(
      name: 'Cultura',
      icon: Icons.menu_book,
      category: 'Culture',
      requiredLevel: 'Régulier',
      availableAmounts: [5, 10, 25],
    ),
    // Discipliné
    PartnerStore(
      name: 'Nike',
      icon: Icons.sports_basketball,
      category: 'Sport',
      requiredLevel: 'Discipliné',
      availableAmounts: [10, 25, 50],
    ),
    PartnerStore(
      name: 'Fnac',
      icon: Icons.devices,
      category: 'Tech & Culture',
      requiredLevel: 'Discipliné',
      availableAmounts: [10, 25, 50],
    ),
    PartnerStore(
      name: 'Sephora',
      icon: Icons.spa,
      category: 'Beauté',
      requiredLevel: 'Discipliné',
      availableAmounts: [10, 25, 50],
    ),
    // Exemplaire
    PartnerStore(
      name: 'Apple',
      icon: Icons.laptop_mac,
      category: 'Tech',
      requiredLevel: 'Exemplaire',
      availableAmounts: [25, 50, 100],
    ),
    PartnerStore(
      name: 'Amazon',
      icon: Icons.local_shipping,
      category: 'Général',
      requiredLevel: 'Exemplaire',
      availableAmounts: [25, 50, 100],
    ),
    PartnerStore(
      name: 'Darty',
      icon: Icons.kitchen,
      category: 'Électroménager',
      requiredLevel: 'Exemplaire',
      availableAmounts: [25, 50, 100],
    ),
  ];
}
