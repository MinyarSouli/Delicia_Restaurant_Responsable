/// Représente le client connecté dans l'application.
/// [id]    = identifiant unique Firebase (UID)
/// [name]  = nom complet affiché dans le profil
/// [email] = adresse e-mail du compte
class AppUser {
  final String id;
  final String name;
  final String email;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
  });
}
