// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';

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
// Service d'authentification — Firebase Auth + Firestore
// ─────────────────────────────────────────────────────────

/// Gère l'inscription, la connexion et la déconnexion via Firebase.
///
/// Usage depuis n'importe quel écran :
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
  /// Le client connecté, ou null si personne n'est connecté.
  /// Cette valeur est mise à jour automatiquement par [_listenToAuthChanges].
  AppUser? currentUser;

  // ─────────────────────────────────────────────────────────
  // Initialisation : écoute l'état Firebase dès le démarrage
  // ─────────────────────────────────────────────────────────

  /// À appeler une seule fois dans main(), juste avant runApp().
  /// Attend le premier événement d'authentification (connecté ou non)
  /// pour que [currentUser] soit déjà renseigné quand l'interface s'affiche.
  Future<void> init() async {
    // Attend que Firebase nous dise si une session existe déjà
    final firebaseUser = await _auth.authStateChanges().first;

    if (firebaseUser != null) {
      // Une session Firebase est active : on charge le profil Firestore
      currentUser = await _buildAppUser(firebaseUser);
    }

    // Écoute les changements futurs (connexion / déconnexion)
    _auth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser == null) {
        currentUser = null; // déconnexion
      } else {
        currentUser = await _buildAppUser(firebaseUser);
      }
    });
  }

  // ─────────────────────────────────────────────────────────
  // Inscription
  // ─────────────────────────────────────────────────────────

  /// Crée un nouveau compte :
  /// 1. Firebase Auth (e-mail + mot de passe)
  /// 2. Met à jour le displayName dans Firebase Auth
  /// 3. Écrit le document users/{uid} dans Firestore
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // 1. Création du compte dans Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = credential.user!;

      // 2. Mise à jour du nom dans Firebase Auth
      await firebaseUser.updateDisplayName(name.trim());

      // 3. Écriture du profil dans Firestore
      // Le rôle est TOUJOURS 'client' : le client ne peut pas se l'attribuer lui-même.
      await _firestore.collection('users').doc(firebaseUser.uid).set({
        'fullName': name.trim(),
        'email': email.trim().toLowerCase(),
        'role': 'client',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // On construit le AppUser local
      currentUser = AppUser(
        id: firebaseUser.uid,
        name: name.trim(),
        email: email.trim().toLowerCase(),
      );
      return currentUser!;
    } on FirebaseAuthException catch (e) {
      // On traduit l'erreur Firebase en français
      throw AuthException(_traduire(e.code));
    }
  }

  // ─────────────────────────────────────────────────────────
  // Connexion
  // ─────────────────────────────────────────────────────────

  /// Connecte un compte existant et charge son profil depuis Firestore.
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      // Connexion via Firebase Auth
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = credential.user!;

      // Lecture du profil dans Firestore pour récupérer le nom complet
      currentUser = await _buildAppUser(firebaseUser);
      return currentUser!;
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

  /// Construit un [AppUser] à partir de l'utilisateur Firebase.
  /// Lit d'abord Firestore pour avoir le nom complet ;
  /// si le document n'existe pas encore, utilise le displayName.
  Future<AppUser> _buildAppUser(User firebaseUser) async {
    String name = firebaseUser.displayName ?? '';
    String email = firebaseUser.email ?? '';

    try {
      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        name = (data['fullName'] as String?) ?? name;
        email = (data['email'] as String?) ?? email;
      }
    } catch (_) {
      // En cas d'erreur réseau, on utilise les données Firebase Auth
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
      case 'email-already-in-use':
        return 'Un compte existe déjà avec cette adresse e-mail.';
      case 'invalid-email':
        return 'L\'adresse e-mail n\'est pas valide.';
      case 'weak-password':
        return 'Le mot de passe est trop court (6 caractères minimum).';
      case 'user-not-found':
        return 'Aucun compte trouvé avec cette adresse e-mail.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'invalid-credential':
        return 'E-mail ou mot de passe incorrect.';
      case 'network-request-failed':
        return 'Impossible de se connecter au réseau. Vérifiez votre connexion.';
      case 'too-many-requests':
        return 'Trop de tentatives. Veuillez patienter quelques minutes avant de réessayer.';
      default:
        return 'Une erreur est survenue. Veuillez réessayer.';
    }
  }
}
