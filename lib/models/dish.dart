/// Un supplément que le client peut ajouter à un plat (sauce, frites...).
class Supplement {
  final String name;
  final double price;

  const Supplement(this.name, this.price);
}

/// Un plat du menu.
class Dish {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category; // Fast-food, Plats, Café, Boissons, Desserts
  final String image; // URL (http...) ou chemin d'asset (assets/images/...)
  final List<Supplement> supplements;

  const Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.image,
    this.supplements = const [],
  });
}

/// Affiche un prix en dinars tunisiens : 12.500 DT
String formatPrice(double value) => '${value.toStringAsFixed(3)} DT';
