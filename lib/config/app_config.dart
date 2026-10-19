/// Configuration de l'application.
///
/// Le taux de TVA (VAT) appliqué aux prix du menu.
/// Les prix du menu sont exprimés **hors taxes (HT)**.
///
/// Pour changer le taux, modifiez simplement la valeur de `vatRate`.
/// Exemple : `const double vatRate = 0.07; // 7 %`
const double vatRate = 0.07; // 7 % de TVA

// ─────────────────────────────────────────────────────────
// Compte administrateur (responsable) — identifiants fixes
// ─────────────────────────────────────────────────────────
// Il n'existe pas de page d'inscription pour le responsable.
// Ces identifiants sont utilisés à la fois pour créer le compte
// dans Firebase Auth (au premier lancement) et pour le valider
// lors de la connexion.
//
// ⚠️  Changez ces valeurs AVANT le déploiement en production.
const String adminEmail    = 'admin@delicia.com';
const String adminPassword = 'Delicia@2024';
const String adminName     = 'Responsable Délicias';
