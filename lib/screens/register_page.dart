import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/auth_widgets.dart';

/// Page de création de compte.
/// Retourne un [AppUser] à l'écran précédent quand l'inscription réussit.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final user = await AuthService.instance.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pop(context, user); // renvoie le nouvel utilisateur
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AuthHeader(
              title: 'Créer un compte',
              subtitle: 'Quelques secondes pour commander en toute simplicité',
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

                        // ----- Nom et prénom -----
                        TextFormField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          decoration: authDecoration(
                            context,
                            label: 'Nom et prénom',
                            hint: 'Ex : Sarra Ben Ali',
                            icon: Icons.person_outline,
                          ),
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) {
                              return 'Veuillez saisir votre nom et prénom';
                            }
                            if (v.length < 3) return 'Le nom est trop court';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // ----- E-mail -----
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
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
                          textInputAction: TextInputAction.next,
                          decoration: authDecoration(
                            context,
                            label: 'Mot de passe',
                            hint: '6 caractères minimum',
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
                              return 'Veuillez saisir un mot de passe';
                            }
                            if (value.length < 6) {
                              return 'Au moins 6 caractères';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // ----- Confirmation -----
                        TextFormField(
                          controller: _confirmController,
                          obscureText: _obscureConfirm,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _register(),
                          decoration: authDecoration(
                            context,
                            label: 'Confirmer le mot de passe',
                            icon: Icons.lock_reset_outlined,
                            suffix: IconButton(
                              tooltip: _obscureConfirm
                                  ? 'Afficher le mot de passe'
                                  : 'Masquer le mot de passe',
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez confirmer le mot de passe';
                            }
                            if (value != _passwordController.text) {
                              return 'Les mots de passe ne correspondent pas';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),

                        // ----- Bouton -----
                        FilledButton(
                          onPressed: _loading ? null : _register,
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
                              : const Text('Créer mon compte'),
                        ),
                        const SizedBox(height: 24),

                        // ----- Lien vers la connexion -----
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Vous avez déjà un compte ?',
                              style: TextStyle(color: colors.onSurfaceVariant),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Se connecter',
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
