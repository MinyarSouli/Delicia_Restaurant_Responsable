import 'package:flutter/material.dart';

import '../models/dish.dart';

/// Une catégorie du menu avec son icône.
class MenuCategory {
  final String name;
  final IconData icon;

  const MenuCategory(this.name, this.icon);
}

const List<MenuCategory> menuCategories = [
  MenuCategory('Fast-food', Icons.lunch_dining),
  MenuCategory('Plats', Icons.dinner_dining),
  MenuCategory('Café', Icons.coffee),
  MenuCategory('Boissons', Icons.local_drink),
  MenuCategory('Desserts', Icons.icecream),
];

// Image Unsplash à partir de son identifiant.
// Pour utiliser tes propres images, remplace _img('...') par
// 'assets/images/nom_de_ton_image.jpg'
String _img(String id) =>
    'https://images.unsplash.com/photo-$id?auto=format&fit=crop&w=900&q=80';

// Suppléments proposés selon le type de plat
const _extrasFastFood = [
  Supplement('Sauce fromagère', 1.000),
  Supplement('Frites', 3.000),
  Supplement('Fromage extra', 1.500),
  Supplement('Boisson gazeuse', 3.500),
];

const _extrasPlats = [
  Supplement('Sauce champignons', 2.000),
  Supplement('Portion de riz', 2.500),
  Supplement('Pain maison', 1.000),
];

const _extrasCafe = [
  Supplement('Lait végétal', 1.000),
  Supplement('Sirop vanille', 1.000),
  Supplement('Chantilly', 1.000),
];

const _extrasBoissons = [
  Supplement('Glaçons en plus', 0.000),
  Supplement('Feuilles de menthe', 0.500),
];

const _extrasDesserts = [
  Supplement('Boule de glace vanille', 2.500),
  Supplement('Sauce chocolat', 1.000),
  Supplement('Chantilly', 1.000),
];

final List<Dish> menuDishes = [
  // ---------- Fast-food ----------
  Dish(
    id: 'ff1',
    name: 'Burger Classique',
    description: 'Steak haché grillé, cheddar fondu, salade, tomate et sauce maison dans un pain brioché.',
    price: 12.500,
    category: 'Fast-food',
    image: _img('1568901346375-23c9450c58cd'),
    supplements: _extrasFastFood,
    isPopular: true,
  ),
  Dish(
    id: 'ff2',
    name: 'Pizza Margherita',
    description: 'Sauce tomate, mozzarella fondante et basilic frais sur une pâte fine cuite au feu de bois.',
    price: 14.000,
    category: 'Fast-food',
    image: _img('1513104890138-7c749659a591'),
    supplements: _extrasFastFood,
    isPopular: true,
  ),
  Dish(
    id: 'ff3',
    name: 'Sandwich Poulet Croustillant',
    description: 'Poulet pané croustillant, coleslaw, cornichons et sauce épicée dans un pain moelleux.',
    price: 11.000,
    category: 'Fast-food',
    image: _img('1606755962773-d324e0a13086'),
    supplements: _extrasFastFood,
  ),

  // ---------- Plats ----------
  Dish(
    id: 'pl1',
    name: 'Pennes Bolognaise',
    description: 'Pennes al dente, sauce bolognaise mijotée lentement et parmesan râpé.',
    price: 16.500,
    category: 'Plats',
    image: _img('1621996346565-e3dbc646d9a9'),
    supplements: _extrasPlats,
    isPopular: true,
  ),
  Dish(
    id: 'pl2',
    name: 'Salade César au Poulet',
    description: 'Laitue croquante, poulet grillé, croûtons dorés, copeaux de parmesan et sauce César.',
    price: 13.500,
    category: 'Plats',
    image: _img('1550304943-4f24f54ddde9'),
    supplements: _extrasPlats,
  ),
  Dish(
    id: 'pl3',
    name: 'Poulet Grillé & Légumes',
    description:
        'Filet de poulet mariné grillé, accompagné de légumes de saison rôtis.',
    price: 18.000,
    category: 'Plats',
    image: _img('1532550907401-a500c9a57435'),
    supplements: _extrasPlats,
  ),

  // ---------- Café ----------
  Dish(
    id: 'ca1',
    name: 'Espresso',
    description:
        'Un café court, intense et parfumé, préparé avec des grains torréfiés.',
    price: 3.000,
    category: 'Café',
    image: _img('1510707577719-ae7c14805e3a'),
    supplements: _extrasCafe,
  ),
  Dish(
    id: 'ca2',
    name: 'Cappuccino',
    description: 'Espresso, lait chaud onctueux et mousse de lait légère saupoudrée de cacao.',
    price: 4.500,
    category: 'Café',
    image: _img('1572442388796-11668a67e53d'),
    supplements: _extrasCafe,
  ),
  Dish(
    id: 'ca3',
    name: 'Café Glacé',
    description: 'Café froid sur glaçons avec une touche de lait, parfait pour se rafraîchir.',
    price: 5.500,
    category: 'Café',
    image: _img('1461023058943-07fcbe16d735'),
    supplements: _extrasCafe,
  ),

  // ---------- Boissons ----------
  Dish(
    id: 'bo1',
    name: 'Citronnade Maison',
    description: 'Citrons pressés, menthe fraîche et un soupçon de sucre, servie bien fraîche.',
    price: 4.000,
    category: 'Boissons',
    image: _img('1621263764928-df1444c5e859'),
    supplements: _extrasBoissons,
  ),
  Dish(
    id: 'bo2',
    name: 'Jus d\'Orange Frais',
    description: 'Oranges pressées à la commande, sans sucre ajouté.',
    price: 5.000,
    category: 'Boissons',
    image: _img('1600271886742-f049cd451bba'),
    supplements: _extrasBoissons,
  ),
  Dish(
    id: 'bo3',
    name: 'Milkshake Chocolat',
    description: 'Milkshake au chocolat crémeux, réalisé avec du chocolat noir fondant et de la glace vanille.',
    price: 7.000,
    category: 'Boissons',
    image: _img('1572490122747-3968b75cc699'),
    supplements: _extrasBoissons,
    isPopular: true,
  ),

  // ---------- Desserts ----------
  Dish(
    id: 'de1',
    name: 'Fondant au Chocolat',
    description: 'Gâteau tiède au cœur coulant de chocolat noir intense.',
    price: 8.500,
    category: 'Desserts',
    image: _img('1606313564200-e75d5e30476c'),
    supplements: _extrasDesserts,
  ),
  Dish(
    id: 'de2',
    name: 'Tiramisu',
    description:
        'Biscuits imbibés de café, crème mascarpone onctueuse et cacao amer.',
    price: 9.000,
    category: 'Desserts',
    image: _img('1571877227200-a0d98ea607e9'),
    supplements: _extrasDesserts,
  ),
  Dish(
    id: 'de3',
    name: 'Crêpe Nutella',
    description: 'Crêpe fine et moelleuse généreusement fourrée de Nutella.',
    price: 7.500,
    category: 'Desserts',
    image: _img('1519676867240-f03562e64548'),
    supplements: _extrasDesserts,
  ),
];
