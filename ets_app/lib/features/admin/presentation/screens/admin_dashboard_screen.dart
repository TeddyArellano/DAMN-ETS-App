import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ds_widgets.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../../domain/entities/admin_dashboard.dart';
import '../providers/admin_providers.dart';
import 'catalogs_screen.dart';
import 'ets_crud_screen.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).asData?.value;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 64,
          titleSpacing: 20,
          title: const BrandLockup(subtitle: 'Panel administrativo'),
          actions: [
            _AdminChip(name: user?.name ?? 'Administrador'),
            IconButton(
              tooltip: 'Cerrar sesión',
              onPressed: () {
                ref.read(authControllerProvider.notifier).logout();
              },
              icon: const Icon(Icons.logout),
            ),
            const SizedBox(width: 8),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.dashboard_outlined),
                text: 'Dashboard',
              ),
              Tab(
                icon: Icon(Icons.collections_bookmark_outlined),
                text: 'Catálogos',
              ),
              Tab(
                icon: Icon(Icons.event_available_outlined),
                text: 'ETS',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _DashboardContent(),
            CatalogsScreen(),
            EtsCrudScreen(),
          ],
        ),
      ),
    );
  }
}

class _AdminChip extends StatelessWidget {
  const _AdminChip({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isEmpty
        ? 'AD'
        : name
            .trim()
            .split(RegExp(r'\s+'))
            .take(2)
            .map((w) => w.characters.first.toUpperCase())
            .join();

    // En pantallas angostas (móvil) se muestra solo el avatar para no saturar
    // el AppBar; el nombre aparece a partir de ~400px de ancho.
    final showName = MediaQuery.sizeOf(context).width >= 400;

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.guinda600,
              shape: BoxShape.circle,
            ),
            child: Text(
              initials,
              style: AppType.sans(
                size: 12,
                weight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ),
          if (showName) ...[
            const SizedBox(width: 9),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 130),
              child: Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: AppType.sans(
                  size: 14,
                  weight: FontWeight.w600,
                  color: AppColors.textBody,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(adminDashboardProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(adminDashboardProvider.notifier).refresh(),
      child: dashboardState.when(
        loading: () => ListView(
          children: const [
            SizedBox(height: 220),
            Center(child: CircularProgressIndicator()),
          ],
        ),
        error: (error, stackTrace) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            DsCard(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  const Icon(Icons.error_outline,
                      size: 46, color: AppColors.danger),
                  const SizedBox(height: 12),
                  Text(
                    'No fue posible cargar el dashboard administrativo.',
                    style: AppType.sans(size: 15, color: AppColors.textBody),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      ref.read(adminDashboardProvider.notifier).refresh();
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ],
        ),
        data: (dashboard) => _DashboardDataView(dashboard: dashboard),
      ),
    );
  }
}

class _DashboardDataView extends StatelessWidget {
  const _DashboardDataView({
    required this.dashboard,
  });

  final AdminDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        DsCard(
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: AppRadii.rmd,
                ),
                child: const Icon(Icons.verified_user_outlined,
                    size: 28, color: AppColors.primary),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen administrativo',
                      style: AppType.serif(size: 24),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Consulta estadísticas y administra la oferta de ETS.',
                      style:
                          AppType.sans(size: 14, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width >= 1050
                ? 4
                : width >= 560
                    ? 2
                    : 1;
            const gap = 14.0;
            // Ancho calculado para que la altura del StatTile sea intrínseca:
            // así nunca se desborda en móvil (a diferencia de un aspect ratio fijo).
            final itemWidth =
                ((width - gap * (columns - 1)) / columns).floorToDouble();

            final tiles = <Widget>[
              StatTile(
                value: '${dashboard.totalEts}',
                label: 'ETS registrados',
                icon: Icons.event_available_outlined,
              ),
              StatTile(
                value: '${dashboard.totalCareers}',
                label: 'Carreras',
                icon: Icons.school_outlined,
                tone: StatTone.guinda,
              ),
              StatTile(
                value: '${dashboard.totalBuildings}',
                label: 'Edificios',
                icon: Icons.apartment_outlined,
                tone: StatTone.neutral,
              ),
              StatTile(
                value: '${dashboard.totalUsers}',
                label: 'Usuarios',
                icon: Icons.people_outline,
                tone: StatTone.success,
              ),
            ];

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final tile in tiles)
                  SizedBox(width: itemWidth, child: tile),
              ],
            );
          },
        ),
        const SizedBox(height: 18),
        DsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ETS por carrera',
                style: AppType.sans(
                  size: 18,
                  weight: FontWeight.w700,
                  color: AppColors.textStrong,
                ),
              ),
              const SizedBox(height: 16),
              if (dashboard.examsByCareer.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'Todavía no existen carreras registradas.',
                      style:
                          AppType.sans(size: 14, color: AppColors.textMuted),
                    ),
                  ),
                )
              else
                ..._buildCareerRows(),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCareerRows() {
    final maxEts = dashboard.examsByCareer
        .map((c) => c.totalEts)
        .fold<int>(1, (prev, e) => e > prev ? e : prev);

    return [
      for (final career in dashboard.examsByCareer)
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _CareerStatRow(item: career, maxEts: maxEts),
        ),
    ];
  }
}

class _CareerStatRow extends StatelessWidget {
  const _CareerStatRow({
    required this.item,
    required this.maxEts,
  });

  final EtsByCareer item;
  final int maxEts;

  @override
  Widget build(BuildContext context) {
    final fraction = maxEts <= 0 ? 0.0 : item.totalEts / maxEts;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CareerBadge(code: item.careerCode, size: 40),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      item.careerName,
                      overflow: TextOverflow.ellipsis,
                      style: AppType.sans(
                        size: 14,
                        weight: FontWeight.w600,
                        color: AppColors.textStrong,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DsBadge(
                    label: '${item.totalEts} ETS',
                    tone: BadgeTone.info,
                    mono: true,
                  ),
                ],
              ),
              const SizedBox(height: 7),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: fraction),
                  duration: AppMotion.slow,
                  curve: AppMotion.easeOut,
                  builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 8,
                    backgroundColor: AppColors.surfaceSunken,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
