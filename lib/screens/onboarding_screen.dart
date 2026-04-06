import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_user.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _mailController = TextEditingController();
  String _gender = 'male';
  DateTime _birthDate = DateTime(2000, 1, 1);
  bool _isLoading = false;

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _mailController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final user = AppUser(
      mail: _mailController.text.trim(),
      firstname: _firstnameController.text.trim(),
      lastname: _lastnameController.text.trim(),
      gender: _gender,
      birthDate: _birthDate.toIso8601String().substring(0, 10),
    );

    try {
      await context.read<UserProvider>().createUser(user);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Logo / Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: AppTheme.gradientCardDecoration,
                  child: const Icon(
                    Icons.flash_on,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Bienvenue !',
                  style: AppTheme.headingLargeOf(context),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Commencez votre parcours de discipline personnelle',
                  style: AppTheme.bodyMediumOf(context),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _firstnameController,
                  decoration: const InputDecoration(
                    labelText: 'Prénom',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Prénom requis' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastnameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Nom requis' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _mailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.mail_outline),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email requis';
                    if (!v.contains('@')) return 'Email invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Gender selection
                Row(
                  children: [
                    Text('Genre :', style: AppTheme.bodyLargeOf(context)),
                    const SizedBox(width: 16),
                    ChoiceChip(
                      label: const Text('Homme'),
                      selected: _gender == 'male',
                      onSelected: (_) => setState(() => _gender = 'male'),
                      selectedColor: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Femme'),
                      selected: _gender == 'female',
                      onSelected: (_) => setState(() => _gender = 'female'),
                      selectedColor: AppTheme.primaryColor,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Birth date
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date de naissance',
                      prefixIcon: Icon(Icons.cake_outlined),
                    ),
                    child: Text(
                      '${_birthDate.day.toString().padLeft(2, '0')}/${_birthDate.month.toString().padLeft(2, '0')}/${_birthDate.year}',
                      style: AppTheme.bodyLargeOf(context),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Commencer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
