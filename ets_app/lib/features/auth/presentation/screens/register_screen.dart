import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ds_widgets.dart';
import '../auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _boletaController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _boletaController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  void _showError(Object error) {
    debugPrint('ERROR REGISTER: $error');

    final message = getReadableErrorMessage(error);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await ref.read(authControllerProvider.notifier).register(
            name: _nameController.text.trim(),
            email: _emailController.text.trim().toLowerCase(),
            boleta: _boletaController.text.trim().isEmpty
                ? null
                : _boletaController.text.trim(),
            password: _passwordController.text,
          );

      if (!mounted) {
        return;
      }

      _showMessage('Cuenta creada correctamente. Ahora inicia sesión.');

      final registeredEmail = _emailController.text.trim();

      context.go(
        Uri(
          path: '/login',
          queryParameters: {
            'email': registeredEmail,
          },
        ).toString(),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showError(error);
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _saving;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.bgPageTint, AppColors.bgPage],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const BrandAccentBar(),
              _TopBar(
                onBack: isLoading ? null : () => context.go('/login'),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: DsCard(
                        padding: const EdgeInsets.all(32),
                        shadow: AppShadows.lg,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(
                                child: Image.asset(
                                  BrandAssets.escudoEscom,
                                  height: 56,
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Center(child: Eyebrow('Crear una cuenta nueva')),
                              const SizedBox(height: 8),
                              Center(
                                child: Text(
                                  'Registro de estudiante',
                                  style: AppType.serif(size: 28),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Center(
                                child: Text(
                                  'Crea tu cuenta para guardar favoritos y recordatorios.',
                                  style: AppType.sans(
                                    size: 14,
                                    color: AppColors.textMuted,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 26),
                              const FieldLabel('Nombre completo'),
                              TextFormField(
                                controller: _nameController,
                                enabled: !isLoading,
                                decoration: const InputDecoration(
                                  hintText: 'Miguel Juárez',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: (value) {
                                  if ((value?.trim().length ?? 0) < 3) {
                                    return 'Ingresa tu nombre completo';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              const FieldLabel('Correo electrónico'),
                              TextFormField(
                                controller: _emailController,
                                enabled: !isLoading,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  hintText: 'alumno@escom.ipn.mx',
                                  prefixIcon: Icon(Icons.mail_outlined),
                                ),
                                validator: (value) {
                                  final email = value?.trim() ?? '';
                                  if (email.isEmpty ||
                                      !email.contains('@') ||
                                      !email.contains('.')) {
                                    return 'Ingresa un correo válido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              const FieldLabel('Boleta (opcional)'),
                              TextFormField(
                                controller: _boletaController,
                                enabled: !isLoading,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: '2024630123',
                                  prefixIcon: Icon(Icons.badge_outlined),
                                ),
                                validator: (value) {
                                  final boleta = value?.trim() ?? '';
                                  if (boleta.isNotEmpty &&
                                      !RegExp(r'^[0-9]{8,12}$')
                                          .hasMatch(boleta)) {
                                    return 'La boleta debe tener entre 8 y 12 números';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              const FieldLabel('Contraseña'),
                              TextFormField(
                                controller: _passwordController,
                                enabled: !isLoading,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  hintText: 'Mínimo 8 caracteres',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if ((value ?? '').length < 8) {
                                    return 'Usa una contraseña de al menos 8 caracteres';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 52,
                                child: FilledButton.icon(
                                  onPressed: isLoading ? null : _submit,
                                  icon: isLoading
                                      ? const SizedBox.shrink()
                                      : const Icon(Icons.person_add_alt_1,
                                          size: 20),
                                  label: isLoading
                                      ? const SizedBox.square(
                                          dimension: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Crear cuenta'),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed:
                                    isLoading ? null : () => context.go('/login'),
                                child: const Text('Ya tengo cuenta'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: IpnFooter(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Volver',
          ),
          const SizedBox(width: 4),
          const BrandLockup(subtitle: 'Sistema de gestión de ETS'),
        ],
      ),
    );
  }
}
