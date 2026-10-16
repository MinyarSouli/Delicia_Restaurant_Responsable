import '../models/app_user.dart';

/// Erreur d'authentification avec un message lisible (en français).
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
}

/// Service d'authentification SIMPLE, en mémoire (sans Firebase).
///
/// Les comptes sont perdus quand l'application se ferme.
/// Plus tard, il suffira de remplacer le contenu des méthodes
/// register() et login() par Firebase Auth : les écrans ne changeront pas.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  // email -> {name, password}
  final Map<String, Map<String, String>> _accounts = {};

  /// Le client actuellement connecté (null si personne).
  AppUser? currentUser;

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800)); // simule le réseau
    final key = email.trim().toLowerCase();

    if (_accounts.containsKey(key)) {
      throw const AuthException('Un compte existe déjà avec cet e-mail.');
    }

    _accounts[key] = {'name': name.trim(), 'password': password};
    currentUser = AppUser(name: name.trim(), email: key);
    return currentUser!;
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final key = email.trim().toLowerCase();
    final account = _accounts[key];

    if (account == null || account['password'] != password) {
      throw const AuthException('E-mail ou mot de passe incorrect.');
    }

    currentUser = AppUser(name: account['name']!, email: key);
    return currentUser!;
  }

  void logout() => currentUser = null;
}
