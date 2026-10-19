// lib/services/auth_service.dart  (VERSION ADMIN — identifiants fixes)
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../config/app_config.dart'; // adminEmail, adminPassword, adminName

// ─────────────────────────────────────────────────────────
// Erreur d'authentification avec un message lisible (en français)
// ─────────────────────────────────────────────────────────

/// Exception personnalisée renvoyée par AuthService.
/// Les écrans affichent simplement [message] dans un SnackBar.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
}

// ─────────────────────────────────────────────────────────
// Service d'authentification admin — Firebase Auth + Firestore
// ─────────────────────────────────────────────────────────

/// Gère la connexion et la déconnexion du responsable (admin).
///
/// L'administrateur est identifié par son e-mail fixe [adminEmail]
/// défini dans [app_config.dart].  Il n'existe pas de page d'inscription :
/// le compte est créé automatiquement dans Firebase Auth au premier
/// lancement (via [_ensureAdminAccountExists]).
///
/// Usage :
///   AuthService.instance.login(email: ..., password: ...)
///   AuthService.instance.currentUser  // AppUser? synchrone
///   AuthService.instance.logout()
class AuthService {
  // ── Singleton ──────────────────────────────────────────
  AuthService._();
  static final AuthService instance = AuthService._();

  // ── Références Firebase ────────────────────────────────
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // ── Utilisateur courant (lecture synchrone) ────────────
  /// L'admin connecté, ou null si personne n'est connecté.
  AppUser? currentUser;

  // ─────────────────────────────────────────────────────────
  // Initialisation
  // ─────────────────────────────────────────────────────────

  /// À appeler une seule fois dans main(), juste avant runApp().
  Future<void> init() async {
    // S'assure que le compte admin existe dans Firebase Auth
    await _ensureAdminAccountExists();

    // Attend que Firebase nous dise si une session existe déjà
    final firebaseUser = await _auth.authStateChanges().first;

    if (firebaseUser != null) {
      currentUser = await _buildAdminOrSignOut(firebaseUser);
    }

    // Écoute les changements futurs (connexion / déconnexion)
    _auth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser == null) {
        currentUser = null;
      } else {
        currentUser = await _buildAdminOrSignOut(firebaseUser);
      }
    });
  }

  // ─────────────────────────────────────────────────────────
  // Création automatique du compte admin (premier lancement)
  // ─────────────────────────────────────────────────────────

  /// Crée le compte admin dans Firebase Auth si il n'existe pas encore,
  /// puis enregistre (ou met à jour) son document Firestore avec role='admin'.
  Future<void> _ensureAdminAccountExists() async {
    try {
      // Tentative de connexion silencieuse pour vérifier l'existence du compte
      final credential = await _auth.signInWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );

      // Le compte existe — s'assurer que Firestore est à jour
      await _upsertAdminDoc(credential.user!.uid);

      // Déconnexion immédiate (l'init ne doit pas garder de session ouverte)
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        // Le compte n'existe pas encore → on le crée
        try {
          final credential = await _auth.createUserWithEmailAndPassword(
            email: adminEmail,
            password: adminPassword,
          );

          // Met à jour le displayName dans Firebase Auth
          await credential.user!.updateDisplayName(adminName);

          // Crée le document Firestore avec role='admin'
          await _upsertAdminDoc(credential.user!.uid);

          // Déconnexion immédiate
          await _auth.signOut();
        } catch (_) {
          // Échec silencieux — la connexion montrera une erreur appropriée
        }
      }
      // Autres codes d'erreur (réseau, etc.) : on ignore silencieusement
    } catch (_) {
      // Erreur inattendue : on ignore silencieusement
    }
  }

  /// Crée ou met à jour le document `users/{uid}` dans Firestore
  /// avec les informations de l'admin (role='admin').
  Future<void> _upsertAdminDoc(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'fullName': adminName,
        'email': adminEmail,
        'role': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Erreur Firestore (permissions, réseau) : on ignore
    }
  }

  // ─────────────────────────────────────────────────────────
  // Connexion (admin uniquement)
  // ─────────────────────────────────────────────────────────

  /// Connecte l'admin. Si l'e-mail ne correspond pas au compte admin fixe,
  /// on rejette la connexion immédiatement.
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    // Vérification préalable : seul l'email admin est autorisé
    if (email.trim().toLowerCase() != adminEmail.toLowerCase()) {
      throw const AuthException(
        'Accès refusé : ce compte n\'est pas administrateur.',
      );
    }

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = credential.user!;

      // Construction de l'AppUser admin (sans vérification Firestore bloquante)
      final admin = AppUser(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? adminName,
        email: firebaseUser.email ?? adminEmail,
      );

      currentUser = admin;

      // Mise à jour Firestore en arrière-plan (non bloquante)
      _upsertAdminDoc(firebaseUser.uid);

      return admin;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_traduire(e.code));
    }
  }

  // ─────────────────────────────────────────────────────────
  // Déconnexion
  // ─────────────────────────────────────────────────────────

  /// Déconnecte l'utilisateur de Firebase et vide [currentUser].
  Future<void> logout() async {
    await _auth.signOut();
    currentUser = null;
  }

  // ─────────────────────────────────────────────────────────
  // Méthodes privées
  // ─────────────────────────────────────────────────────────

  /// Lit users/{uid} dans Firestore.
  /// - Si role == 'admin' : renvoie un [AppUser].
  /// - Si l'e-mail correspond à adminEmail : renvoie un [AppUser] sans
  ///   dépendre de Firestore (fallback si Firestore est inaccessible).
  /// - Sinon : déconnecte Firebase et renvoie null.
  Future<AppUser?> _buildAdminOrSignOut(User firebaseUser) async {
    // Fallback : si l'e-mail correspond à l'admin fixe, on accepte
    if ((firebaseUser.email ?? '').toLowerCase() == adminEmail.toLowerCase()) {
      return AppUser(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? adminName,
        email: firebaseUser.email ?? adminEmail,
      );
    }

    // Vérification Firestore pour d'éventuels autres comptes
    String name = firebaseUser.displayName ?? '';
    String email = firebaseUser.email ?? '';
    String? role;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        name = (data['fullName'] as String?) ?? name;
        email = (data['email'] as String?) ?? email;
        role = data['role'] as String?;
      }
    } catch (_) {
      // Erreur réseau / permissions : on ne peut pas confirmer le rôle admin
      role = null;
    }

    if (role != 'admin') {
      await _auth.signOut();
      return null;
    }

    return AppUser(
      id: firebaseUser.uid,
      name: name,
      email: email,
    );
  }

  /// Traduit un code d'erreur FirebaseAuth en message français lisible.
  String _traduire(String code) {
    switch (code) {
      case 'invalid-email':
        return 'L\'adresse e-mail n\'est pas valide.';
      case 'user-not-found':
        return 'Aucun compte trouvé avec cette adresse e-mail.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'invalid-credential':
        return 'E-mail ou mot de passe incorrect.';
      case 'user-disabled':
        return 'Ce compte a été désactivé.';
      case 'network-request-failed':
        return 'Impossible de se connecter au réseau. Vérifiez votre connexion.';
      case 'too-many-requests':
        return 'Trop de tentatives. Veuillez patienter quelques minutes avant de réessayer.';
      default:
        return 'Une erreur est survenue. Veuillez réessayer.';
    }
  }
}