import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../../../core/theme/app_colors.dart';
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
  final _emailController = TextEditingController(text: 'admin@escom.mx');
  final _passwordController = TextEditingController(text: 'Admin123');

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final initialEmail = widget.initialEmail?.trim();
    if (initialEmail != null && initialEmail.isNotEmpty) {
      _emailController.text = initialEmail;
    }
  }

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
      ..showSnackBar(SnackBar(content: Text(message)));
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
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 880;

          if (wide) {
            return Row(
              children: [
                const Expanded(flex: 5, child: _BrandPanel()),
                Expanded(
                  flex: 6,
                  child: _FormArea(
                    formKey: _formKey,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    obscure: _obscurePassword,
                    isLoading: isLoading,
                    onToggleObscure: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    onSubmit: _submit,
                    onRegister: () => context.go('/register'),
                  ),
                ),
              ],
            );
          }

          // Móvil: una sola columna (panel de marca compacto arriba + formulario).
          return Column(
            children: [
              const _CompactBrandHeader(),
              Expanded(
                child: _FormArea(
                  formKey: _formKey,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  obscure: _obscurePassword,
                  isLoading: isLoading,
                  onToggleObscure: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  onSubmit: _submit,
                  onRegister: () => context.go('/register'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Panel de marca izquierdo (escaparate oscuro institucional).
class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return GradientHero(
      tallGradient: true,
      borderRadius: null,
      padding: const EdgeInsets.fromLTRB(48, 44, 48, 36),
      child: SizedBox.expand(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(BrandAssets.escudoEscomWhite, height: 40),
                  const SizedBox(width: 13),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Escuela Superior de Cómputo',
                        style: AppType.sans(
                          size: 14.5,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Instituto Politécnico Nacional',
                        style: AppType.sans(
                          size: 12,
                          color: AppColors.azul200,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 56),
              const Eyebrow('Panel administrativo', color: AppColors.azul200),
              const SizedBox(height: 16),
              Text(
                'Exámenes a Título\nde Suficiencia',
                style: AppType.serif(size: 42, color: Colors.white, height: 1.08),
              ),
              const SizedBox(height: 16),
              Text(
                'Coordina la oferta de ETS de ESCOM en un solo lugar: programa '
                'exámenes, gestiona carreras y monitorea estadísticas.',
                style: AppType.sans(
                  size: 16,
                  color: AppColors.textOnDark.withValues(alpha: 0.82),
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 34),
              const _Feature(
                icon: Icons.event_available_outlined,
                title: 'Programa exámenes ETS',
                desc: 'Fechas, salones, turnos y profesores.',
              ),
              const SizedBox(height: 18),
              const _Feature(
                icon: Icons.collections_bookmark_outlined,
                title: 'Administra catálogos',
                desc: 'Carreras, planes de estudio y edificios.',
              ),
              const SizedBox(height: 18),
              const _Feature(
                icon: Icons.bar_chart_rounded,
                title: 'Estadísticas en vivo',
                desc: 'Distribución por carrera y periodo.',
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.only(top: 24),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
                  ),
                ),
                child: Row(
                  children: [
                    Image.asset(BrandAssets.ipnLogoWhite, height: 26),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        '© 2026 · IPN · ESCOM · Periodo 2026/1',
                        style: AppType.sans(
                          size: 12,
                          color: AppColors.textOnDark.withValues(alpha: 0.62),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.title, required this.desc});

  final IconData icon;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeroIconDisc(icon: icon, size: 42),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppType.sans(
                  size: 15,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: AppType.sans(
                  size: 13,
                  color: AppColors.textOnDark.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Cabecera de marca compacta para móvil (tira oscura arriba del formulario).
class _CompactBrandHeader extends StatelessWidget {
  const _CompactBrandHeader();

  @override
  Widget build(BuildContext context) {
    return GradientHero(
      borderRadius: null,
      showWatermark: false,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.paddingOf(context).top + 18,
        20,
        18,
      ),
      child: Row(
        children: [
          Image.asset(BrandAssets.escudoEscomWhite, height: 34),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ETS ESCOM',
                style: AppType.serif(size: 18, color: Colors.white),
              ),
              Text(
                'Panel administrativo',
                style: AppType.sans(size: 11, color: AppColors.azul200),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Área del formulario (derecha en escritorio, único en móvil).
class _FormArea extends StatelessWidget {
  const _FormArea({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscure,
    required this.isLoading,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.onRegister,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscure;
  final bool isLoading;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgPage,
      alignment: Alignment.center,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Eyebrow('Bienvenido de nuevo'),
                const SizedBox(height: 8),
                Text('Inicia sesión', style: AppType.serif(size: 28)),
                const SizedBox(height: 6),
                Text(
                  'Ingresa con tu cuenta institucional.',
                  style: AppType.sans(size: 14, color: AppColors.textMuted),
                ),
                const SizedBox(height: 26),
                const FieldLabel('Correo electrónico'),
                TextFormField(
                  controller: emailController,
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
                const FieldLabel('Contraseña'),
                TextFormField(
                  controller: passwordController,
                  obscureText: obscure,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: onToggleObscure,
                      icon: Icon(
                        obscure
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
                    onPressed: isLoading ? null : onSubmit,
                    icon: isLoading
                        ? const SizedBox.shrink()
                        : const Icon(Icons.arrow_forward_rounded, size: 20),
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
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.borderSubtle)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'o',
                        style:
                            AppType.sans(size: 12.5, color: AppColors.textFaint),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.borderSubtle)),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '¿No tienes cuenta? ',
                        style:
                            AppType.sans(size: 14, color: AppColors.textMuted),
                      ),
                      GestureDetector(
                        onTap: isLoading ? null : onRegister,
                        child: Text(
                          'Crea una nueva',
                          style: AppType.sans(
                            size: 14,
                            weight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
