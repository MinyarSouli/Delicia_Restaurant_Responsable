/// Un supplément que le client peut ajouter à un plat (sauce, frites...).
class Supplement {
  final String name;
  final double price;

  const Supplement(this.name, this.price);

  /// Format Firestore -> objet
  factory Supplement.fromMap(Map<String, dynamic> map) => Supplement(
        (map['name'] as String?) ?? '',
        (map['price'] as num?)?.toDouble() ?? 0,
      );

  /// Objet -> format Firestore
  Map<String, dynamic> toMap() => {
        'name': name,
        'price': price,
      };
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
  final bool isPopular; // true si le plat doit apparaître dans la section "Populaires"

  const Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.image,
    this.supplements = const [],
    this.isPopular = false,
  });

  /// Construit un plat depuis un document Firestore (collection `dishes`).
  /// [id] = identifiant du document.
  factory Dish.fromMap(String id, Map<String, dynamic> map) => Dish(
        id: id,
        name: (map['name'] as String?) ?? '',
        description: (map['description'] as String?) ?? '',
        price: (map['price'] as num?)?.toDouble() ?? 0,
        category: (map['category'] as String?) ?? '',
        image: (map['image'] as String?) ?? '',
        isPopular: (map['isPopular'] as bool?) ?? false,
        supplements: ((map['supplements'] as List?) ?? [])
            .map((s) => Supplement.fromMap(Map<String, dynamic>.from(s as Map)))
            .toList(),
      );

  /// Convertit le plat en Map pour l'écrire dans Firestore.
  /// L'id n'est pas stocké : c'est l'id du document.
  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'price': price,
        'category': category,
        'image': image,
        'isPopular': isPopular,
        'supplements': supplements.map((s) => s.toMap()).toList(),
      };
}

/// Affiche un prix en dinars tunisiens : 12.500 DT
String formatPrice(double value) => '${value.toStringAsFixed(3)} DT';