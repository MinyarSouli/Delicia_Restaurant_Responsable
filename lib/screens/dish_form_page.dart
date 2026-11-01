// lib/screens/dish_form_page.dart
// ─────────────────────────────────────────────────────────────────────────────
// Formulaire Admin : Ajout (dish == null) ou Modification d'un plat.
//
// Fonctionnalités :
//  • Champs : Image (URL/asset), Nom, Description, Prix (DT), Catégorie,
//             Plat populaire (switch), Suppléments (dynamiques)
//  • Catégorie : liste dynamique depuis Firestore (CategoryService)
//  • Validation de formulaire intégrée
//  • Appel Firebase (DishService.add / DishService.update) à la soumission
//  • Aperçu de l'image en temps réel au-dessus du formulaire
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/dish.dart';
import '../services/category_service.dart';
import '../services/dish_service.dart';
import '../theme/app_colors.dart';
import '../widgets/dish_image.dart';

/// Formulaire d'ajout (dish == null) ou de modification d'un plat.
class DishFormPage extends StatefulWidget {
  final Dish? dish;
  const DishFormPage({super.key, this.dish});

  @override
  State<DishFormPage> createState() => _DishFormPageState();
}

// ── Classe interne : une ligne de supplément (nom + prix) ────────────────────
class _SuppRow {
  final TextEditingController name;
  final TextEditingController price;

  _SuppRow({String n = '', String p = ''})
      : name = TextEditingController(text: n),
        price = TextEditingController(text: p);

  void dispose() {
    name.dispose();
    price.dispose();
  }
}

// ── État du formulaire ───────────────────────────────────────────────────────
class _DishFormPageState extends State<DishFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs de champs texte
  late final TextEditingController _name;
  late final TextEditingController _desc;
  late final TextEditingController _price;
  late final TextEditingController _image;

  // Valeurs hors-texte
  late String _category;
  late bool _isPopular;

  // Liste dynamique de lignes suppléments
  final List<_SuppRow> _supps = [];

  // Indicateur de chargement (lors de la sauvegarde Firebase)
  bool _saving = false;

  /// Vrai si on est en mode MODIFICATION (dish fourni), faux si AJOUT.
  bool get _isEdit => widget.dish != null;

  // ── initState ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    final d = widget.dish;

    // Pré-remplit les champs si on modifie un plat existant
    _name = TextEditingController(text: d?.name ?? '');
    _desc = TextEditingController(text: d?.description ?? '');
    _price = TextEditingController(
        text: d != null ? d.price.toStringAsFixed(3) : '');
    _image = TextEditingController(text: d?.image ?? '');
    _category = d?.category ?? '';
    _isPopular = d?.isPopular ?? false;

    // Pré-remplit les suppléments existants
    for (final s in d?.supplements ?? const <Supplement>[]) {
      _supps.add(_SuppRow(n: s.name, p: s.price.toStringAsFixed(3)));
    }
  }

  // ── dispose ────────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _price.dispose();
    _image.dispose();
    for (final s in _supps) {
      s.dispose();
    }
    super.dispose();
  }

  // ── Utilitaire : parse un prix en double ───────────────────────────────────
  double _parse(String v) =>
      double.tryParse(v.trim().replaceAll(',', '.')) ?? 0;

  // ─────────────────────────────────────────────────────────────────────────
  // _save() – SOUMISSION DU FORMULAIRE → ÉCRITURE FIREBASE
  // ─────────────────────────────────────────────────────────────────────────
  /// Valide, construit l'objet [Dish], puis :
  ///  • En mode AJOUT  → DishService.add(dish)    : crée un nouveau document
  ///  • En mode MODIF  → DishService.update(dish) : met à jour le document
  ///
  /// En cas d'erreur Firebase, affiche un SnackBar avec le message d'erreur.
  Future<void> _save() async {
    // 1. Validation locale du formulaire (champs requis / prix valide)
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    // 2. Construction de l'objet Dish depuis les champs du formulaire
    final dish = Dish(
      id: widget.dish?.id ?? '', // id vide = Firestore en générera un
      name: _name.text.trim(),
      description: _desc.text.trim(),
      price: _parse(_price.text),
      category: _category,
      image: _image.text.trim(),
      isPopular: _isPopular,
      supplements: _supps
          .where((s) => s.name.text.trim().isNotEmpty) // ignore lignes vides
          .map((s) => Supplement(s.name.text.trim(), _parse(s.price.text)))
          .toList(),
    );

    try {
      if (_isEdit) {
        // 3a. MISE À JOUR → écrit dans Firestore le document existant
        await DishService.instance.update(dish);
      } else {
        // 3b. AJOUT → crée un nouveau document dans la collection "dishes"
        await DishService.instance.add(dish);
      }

      if (!mounted) return;
      // 4. Retour à la page précédente après succès
      Navigator.pop(context);
    } catch (e) {
      // 5. Erreur Firebase : affiche le message et réactive le bouton
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  // ── Décoration partagée pour les champs TextFormField ────────────────────
  InputDecoration _deco(String label, {String? hint}) => InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.cardCream,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
                const BorderSide(color: AppColors.orangePrimary, width: 1.5)),
      );

  // ── build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Modifier le plat' : 'Nouveau plat'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textBrown,
      ),
      extendBodyBehindAppBar: false,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.peachTop, AppColors.peachBottom],
          ),
        ),
        // ════════════════════════════════════════════════════════════════════
        // StreamBuilder : écoute les catégories en temps réel pour le dropdown
        // ════════════════════════════════════════════════════════════════════
        child: StreamBuilder<List<MenuCategory>>(
          stream: CategoryService.instance.watchCategories(),
          builder: (context, catSnap) {
            final categories = catSnap.data ?? [];

            // Initialise _category avec la première catégorie disponible
            // (si pas encore initialisé et des catégories existent)
            if (_category.isEmpty && categories.isNotEmpty) {
              _category = categories.first.name;
            }

            // Vérifie que la catégorie sélectionnée existe encore dans la liste
            // (protection contre suppression de catégorie)
            if (categories.isNotEmpty &&
                !categories.any((c) => c.name == _category)) {
              _category = categories.first.name;
            }

            return SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // ── Aperçu de l'image (mis à jour à chaque frappe) ──────
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: _image.text.trim().isEmpty
                            ? Container(
                                color: AppColors.cardCream,
                                child: const Icon(Icons.image_outlined,
                                    size: 48, color: AppColors.textSecondary))
                            : DishImage(path: _image.text.trim()),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Champ : URL ou chemin d'image ───────────────────────
                    TextFormField(
                      controller: _image,
                      decoration:
                          _deco('Image (URL ou assets/images/...)'),
                      // Rafraîchit l'aperçu au-dessus à chaque caractère tapé
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 14),

                    // ── Champ : Nom du plat (obligatoire) ───────────────────
                    TextFormField(
                      controller: _name,
                      decoration: _deco('Nom du plat'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Nom obligatoire' : null,
                    ),
                    const SizedBox(height: 14),

                    // ── Champ : Description ─────────────────────────────────
                    TextFormField(
                      controller: _desc,
                      maxLines: 3,
                      decoration: _deco('Description'),
                    ),
                    const SizedBox(height: 14),

                    // ── Champ : Prix en DT ──────────────────────────────────
                    TextFormField(
                      controller: _price,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: _deco('Prix (DT)', hint: '12.500'),
                      validator: (v) {
                        final p = double.tryParse(
                            (v ?? '').trim().replaceAll(',', '.'));
                        return (p == null || p <= 0) ? 'Prix invalide' : null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // ── Champ : Catégorie (Dropdown dynamique depuis Firestore)
                    if (categories.isEmpty)
                      // Chargement ou aucune catégorie
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardCream,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.orangePrimary),
                            ),
                            const SizedBox(width: 12),
                            Text('Chargement des catégories...',
                                style: TextStyle(
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      )
                    else
                      DropdownButtonFormField<String>(
                        initialValue: _category.isEmpty ? null : _category,
                        decoration: _deco('Catégorie'),
                        items: categories
                            .map((c) => DropdownMenuItem(
                                value: c.name,
                                child: Row(
                                  children: [
                                    Icon(c.icon,
                                        size: 18,
                                        color: AppColors.textSecondary),
                                    const SizedBox(width: 8),
                                    Text(c.name),
                                  ],
                                )))
                            .toList(),
                        onChanged: (v) => setState(() => _category = v!),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Catégorie obligatoire' : null,
                      ),
                    const SizedBox(height: 8),

                    // ── Switch : Plat populaire ──────────────────────────────
                    SwitchListTile(
                      value: _isPopular,
                      onChanged: (v) => setState(() => _isPopular = v),
                      activeThumbColor: AppColors.orangePrimary,
                      title: const Text('Plat populaire'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 8),

                    // ── Section Suppléments (lignes dynamiques) ─────────────
                    Row(
                      children: [
                        const Expanded(
                          child: Text('Suppléments',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.textBrown)),
                        ),
                        TextButton.icon(
                          onPressed: () => setState(() => _supps.add(_SuppRow())),
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter'),
                        ),
                      ],
                    ),
                    // Affiche une ligne par supplément
                    for (int i = 0; i < _supps.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            // Nom du supplément
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                  controller: _supps[i].name,
                                  decoration: _deco('Nom')),
                            ),
                            const SizedBox(width: 8),
                            // Prix du supplément
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _supps[i].price,
                                keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true),
                                decoration: _deco('Prix'),
                              ),
                            ),
                            // Bouton suppression de la ligne
                            IconButton(
                              icon:
                                  const Icon(Icons.close, color: AppColors.error),
                              onPressed: () => setState(() {
                                _supps.removeAt(i).dispose();
                              }),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),

                    // ── Bouton de soumission Firebase ───────────────────────
                    FilledButton(
                      onPressed: _saving ? null : _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.orangePrimary,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      // Indicateur de chargement pendant la sauvegarde Firebase
                      child: _saving
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(_isEdit ? 'Enregistrer' : 'Ajouter le plat'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
