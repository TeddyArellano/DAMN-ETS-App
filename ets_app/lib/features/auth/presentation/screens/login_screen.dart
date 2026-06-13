import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ds_widgets.dart';
import '../auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({
    super.key,
    this.initialEmail,
  });

  final String? initialEmail;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(
    text: 'admin@escom.mx',
  );
  final _passwordController = TextEditingController(
    text: 'Admin123',
  );

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(Object error) {
    final message = error is ApiException
        ? error.message
        : 'No se pudo iniciar sesión. Intenta nuevamente.';

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

    await ref.read(authControllerProvider.notifier).login(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (!mounted) {
      return;
    }

    final authState = ref.read(authControllerProvider);

    if (authState.hasError && authState.error != null) {
      _showError(authState.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.bgPageTint, AppColors.bgPage],
          ),
        ),
        child: Stack(
          children: [
            // Florituría de marca: escudo a muy baja opacidad.
            Positioned(
              top: -110,
              left: -80,
              child: Opacity(
                opacity: 0.05,
                child: Image.asset(BrandAssets.escudoEscom, height: 440),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: DsCard(
                            padding: const EdgeInsets.all(36),
                            shadow: AppShadows.lg,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    BrandAssets.escudoEscom,
                                    height: 68,
                                  ),
                                  const SizedBox(height: 18),
                                  const Eyebrow('Sistema de gestión de ETS'),
                                  const SizedBox(height: 8),
                                  Text(
                                    'ETS ESCOM',
                                    style: AppType.serif(size: 34),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Consulta y administra tus exámenes',
                                    style: AppType.sans(
                                      size: 14,
                                      color: AppColors.textMuted,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 28),
                                  _FieldLabel('Correo electrónico'),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    enabled: !isLoading,
                                    decoration: const InputDecoration(
                                      hintText: 'alumno@escom.ipn.mx',
                                      prefixIcon: Icon(Icons.mail_outlined),
                                    ),
                                    validator: (value) {
                                      final email = value?.trim() ?? '';
                                      if (email.isEmpty || !email.contains('@')) {
                                        return 'Ingresa un correo válido';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _FieldLabel('Contraseña'),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    enabled: !isLoading,
                                    decoration: InputDecoration(
                                      hintText: '••••••••',
                                      prefixIcon: const Icon(Icons.lock_outline),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
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
                                        return 'La contraseña debe tener al menos 8 caracteres';
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
                                          : const Icon(Icons.login_rounded,
                                              size: 20),
                                      label: isLoading
                                          ? const SizedBox.square(
                                              dimension: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text('Iniciar sesión'),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextButton(
                                    onPressed: isLoading
                                        ? null
                                        : () => context.go('/register'),
                                    child: const Text('Crear una cuenta nueva'),
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
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    final initialEmail = widget.initialEmail?.trim();

    if (initialEmail != null && initialEmail.isNotEmpty) {
      _emailController.text = initialEmail;
    }
  }
}

/// Etiqueta de campo (caption por encima del input, estilo académico).
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: AppType.sans(
          size: 14,
          weight: FontWeight.w600,
          color: AppColors.textBody,
        ),
      ),
    );
  }
}
