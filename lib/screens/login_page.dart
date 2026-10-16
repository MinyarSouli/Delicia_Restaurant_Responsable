import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../widgets/auth_widgets.dart';
import 'register_page.dart';

/// Page de connexion.
/// Retourne un [AppUser] à l'écran précédent quand la connexion réussit.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final user = await AuthService.instance.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pop(context, user); // renvoie l'utilisateur connecté
    } on AuthException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _goToRegister() async {
    final user = await Navigator.push<AppUser>(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
    // Si le compte a été créé, on renvoie directement l'utilisateur
    if (user != null && mounted) Navigator.pop(context, user);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AuthHeader(
              title: 'Bon retour !',
              subtitle: 'Connectez-vous pour confirmer votre commande',
              showBack: true,
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),

                        // ----- E-mail -----
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          decoration: authDecoration(
                            context,
                            label: 'Adresse e-mail',
                            hint: 'exemple@mail.com',
                            icon: Icons.email_outlined,
                          ),
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty)
                              return 'Veuillez saisir votre e-mail';
                            final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                            if (!ok.hasMatch(v))
                              return 'Adresse e-mail invalide';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // ----- Mot de passe -----
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _login(),
                          autofillHints: const [AutofillHints.password],
                          decoration: authDecoration(
                            context,
                            label: 'Mot de passe',
                            icon: Icons.lock_outline,
                            suffix: IconButton(
                              tooltip: _obscurePassword
                                  ? 'Afficher le mot de passe'
                                  : 'Masquer le mot de passe',
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir votre mot de passe';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),

                        // ----- Bouton connexion -----
                        FilledButton(
                          onPressed: _loading ? null : _login,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text('Se connecter'),
                        ),
                        const SizedBox(height: 24),

                        // ----- Lien vers l'inscription -----
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Pas encore de compte ?',
                              style: TextStyle(color: colors.onSurfaceVariant),
                            ),
                            TextButton(
                              onPressed: _goToRegister,
                              child: const Text(
                                'Créer un compte',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
