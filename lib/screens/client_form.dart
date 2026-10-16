import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/client_info.dart';

class CustomerFormPage extends StatefulWidget {
  final CustomerInfo? initialInfo;
  final Widget? orderSummary;

  const CustomerFormPage({super.key, this.initialInfo, this.orderSummary});

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _tableController;
  late final TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    final info = widget.initialInfo;
    _nameController = TextEditingController(text: info?.fullName ?? '');
    _tableController = TextEditingController(
      text: info != null ? '${info.tableNumber}' : '',
    );
    _commentController = TextEditingController(text: info?.comment ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tableController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final info = CustomerInfo(
      fullName: _nameController.text.trim(),
      tableNumber: int.parse(_tableController.text.trim()),
      comment: _commentController.text.trim(),
    );

    Navigator.pop(context, info);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vos informations'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Retour',
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      size: 56,
                      color: colors.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Avant de confirmer',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Merci de renseigner vos informations pour que nous puissions vous servir.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),

                    if (widget.orderSummary != null) ...[
                      Card(
                        elevation: 0,
                        color: colors.secondaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: widget.orderSummary,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nom et prénom',
                        hintText: 'Ex : Sarra qyed',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez saisir votre nom et prénom';
                        }
                        if (value.trim().length < 3) {
                          return 'Le nom est trop court';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _tableController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Numéro de table',
                        hintText: 'Ex : 7',
                        prefixIcon: Icon(Icons.table_restaurant_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez saisir le numéro de table';
                        }
                        final number = int.tryParse(value.trim());
                        if (number == null || number <= 0) {
                          return 'Numéro de table invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _commentController,
                      maxLines: 4,
                      maxLength: 200,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Remarque (facultatif)',
                        hintText:
                            'Ex : sans oignons, allergie aux arachides...',
                        prefixIcon: Icon(Icons.edit_note),
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    FilledButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Confirmer les informations'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
