import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/notifications/local_notifications_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ds_widgets.dart';
import '../../admin/domain/entities/career.dart';
import '../../admin/presentation/providers/admin_providers.dart';
import '../../auth/presentation/auth_providers.dart';
import '../domain/entities/ets.dart';
import 'ets_providers.dart';
import 'favorites_provider.dart';
import 'utils/ics_export.dart';
import 'utils/pdf_export.dart';

Career? _findCareerByCode(List<Career> careers, String? code) {
  if (code == null) {
    return null;
  }

  for (final career in careers) {
    if (career.code == code) {
      return career;
    }
  }

  return null;
}

enum _ReminderOption {
  now,
  oneHourBefore,
  oneDayBefore,
  cancel,
}

class EtsHomeScreen extends ConsumerStatefulWidget {
  const EtsHomeScreen({super.key});

  @override
  ConsumerState<EtsHomeScreen> createState() => _EtsHomeScreenState();
}

class _EtsHomeScreenState extends ConsumerState<EtsHomeScreen> {
  final _searchController = TextEditingController();

  int? _expandedExamId;

  Future<void> _showReminderOptions(BuildContext context, Ets exam) async {
    final option = await showModalBottomSheet<_ReminderOption>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_active_outlined),
                  title: const Text('Recordar ahora'),
                  subtitle: const Text('Muestra una notificación inmediata'),
                  onTap: () {
                    Navigator.of(context).pop(_ReminderOption.now);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.schedule_outlined),
                  title: const Text('Recordar 1 hora antes'),
                  subtitle: const Text(
                    'Programa una notificación antes del ETS',
                  ),
                  onTap: () {
                    Navigator.of(context).pop(_ReminderOption.oneHourBefore);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.event_available_outlined),
                  title: const Text('Recordar 1 día antes'),
                  subtitle: const Text(
                    'Programa una notificación un día antes',
                  ),
                  onTap: () {
                    Navigator.of(context).pop(_ReminderOption.oneDayBefore);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.notifications_off_outlined),
                  title: const Text('Cancelar recordatorios'),
                  subtitle: const Text('Elimina recordatorios de este ETS'),
                  onTap: () {
                    Navigator.of(context).pop(_ReminderOption.cancel);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || option == null) {
      return;
    }

    switch (option) {
      case _ReminderOption.now:
        await _sendImmediateReminder(exam);
        break;

      case _ReminderOption.oneHourBefore:
        await _scheduleReminder(
          exam,
          before: const Duration(hours: 1),
          message: 'Recordatorio programado 1 hora antes del ETS.',
        );
        break;

      case _ReminderOption.oneDayBefore:
        await _scheduleReminder(
          exam,
          before: const Duration(days: 1),
          message: 'Recordatorio programado 1 día antes del ETS.',
        );
        break;

      case _ReminderOption.cancel:
        await _cancelReminders(exam);
        break;
    }
  }

  Future<void> _sendImmediateReminder(Ets exam) async {
    try {
      await LocalNotificationsService.showEtsReminder(exam);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recordatorio enviado como notificación.'),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo generar el recordatorio.'),
        ),
      );
    }
  }

  Future<void> _scheduleReminder(
    Ets exam, {
    required Duration before,
    required String message,
  }) async {
    try {
      final scheduledDate = await LocalNotificationsService.scheduleEtsReminder(
        exam,
        before: before,
      );

      if (!mounted) {
        return;
      }

      final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(
        scheduledDate.toLocal(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$message Fecha: $formattedDate'),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo programar el recordatorio.'),
        ),
      );
    }
  }

  Future<void> _cancelReminders(Ets exam) async {
    try {
      await LocalNotificationsService.cancelEtsReminders(exam.id);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recordatorios cancelados para este ETS.'),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudieron cancelar los recordatorios.'),
        ),
      );
    }
  }

  Future<void> _refreshData() async {
    await Future.wait([
      ref.read(etsListProvider.notifier).refresh(),
      ref.read(adminCareersProvider.notifier).refresh(),
    ]);
  }

  Future<void> _exportResultsPdf(List<Ets> items) async {
    try {
      await exportEtsCalendarToPdf(
        items,
        title: 'Calendario de ETS',
        filename: 'ets_consulta.pdf',
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo generar el PDF.')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).asData?.value;
    final sourceResult = ref.watch(etsListProvider);
    final filteredResult = ref.watch(filteredEtsProvider);
    final filters = ref.watch(etsFiltersProvider);
    final favorites = ref.watch(favoritesProvider).value ?? <int>{};

    final careersState = ref.watch(adminCareersProvider);
    final careers = careersState.value ?? const <Career>[];

    final carreras = careers.map((career) => career.code).toList()..sort();

    final selectedCareer = _findCareerByCode(careers, filters.carrera);

    final planes = selectedCareer == null
        ? (careers.expand((career) => career.plans).toSet().toList()..sort())
        : (selectedCareer.plans.toList()..sort());

    final semestres = List<int>.generate(8, (index) => index + 1);

    final isOffline = sourceResult.asData?.value.fromCache ?? false;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(67),
        child: Column(
          children: [
            const BrandAccentBar(),
            Expanded(
              child: AppBar(
        toolbarHeight: 64,
        titleSpacing: 20,
        title: const BrandLockup(subtitle: 'Calendario de exámenes'),
        actions: [
          IconButton(
            tooltip: 'Mis favoritos',
            onPressed: () => context.go('/ets/favorites'),
            icon: const Icon(Icons.star_rounded, color: AppColors.azul600),
          ),
          IconButton(
            tooltip: 'Actualizar ETS y catálogos',
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
            },
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(width: 8),
        ],
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _Hero(
              userName: user?.name,
              etsCount: sourceResult.asData?.value.items.length ?? 0,
              careerCount: careers.length,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform.translate(
                    offset: const Offset(0, -24),
                    child: _FiltersCard(
                      searchController: _searchController,
                      filters: filters,
                      carreras: carreras,
                      planes: planes,
                      semestres: semestres,
                      onSearchChanged: (value) {
                        ref
                            .read(etsFiltersProvider.notifier)
                            .updateQuery(value);
                      },
                      onCarreraChanged: (value) {
                        ref
                            .read(etsFiltersProvider.notifier)
                            .updateCarrera(value);
                      },
                      onPlanChanged: (value) {
                        ref.read(etsFiltersProvider.notifier).updatePlan(value);
                      },
                      onSemestreChanged: (value) {
                        ref
                            .read(etsFiltersProvider.notifier)
                            .updateSemestre(value);
                      },
                      onClear: () {
                        _searchController.clear();
                        ref.read(etsFiltersProvider.notifier).clear();
                      },
                    ),
                  ),
                  if (isOffline) ...[
                    _OfflineBanner(
                      lastUpdated: sourceResult.asData?.value.lastUpdated,
                    ),
                    const SizedBox(height: 18),
                  ],
                  filteredResult.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, stackTrace) => _ErrorCard(
                      onRetry: () {
                        ref.read(etsListProvider.notifier).refresh();
                      },
                    ),
                    data: (result) {
                      if (result.items.isEmpty) {
                        return const _EmptyCard();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Resultados',
                                style: AppType.sans(
                                  size: 17,
                                  weight: FontWeight.w700,
                                  color: AppColors.textStrong,
                                ),
                              ),
                              const SizedBox(width: 10),
                              DsBadge(
                                label:
                                    '${result.items.length} ${result.items.length == 1 ? 'examen' : 'exámenes'}',
                                tone: BadgeTone.info,
                                mono: true,
                              ),
                              const Spacer(),
                              IconButton(
                                tooltip: 'Exportar resultados a PDF',
                                onPressed: () =>
                                    _exportResultsPdf(result.items),
                                icon: const Icon(
                                  Icons.picture_as_pdf_outlined,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ...result.items.map(
                            (exam) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _EtsCard(
                                exam: exam,
                                isExpanded: _expandedExamId == exam.id,
                                isFavorite: favorites.contains(exam.id),
                                onToggleExpanded: () {
                                  setState(() {
                                    if (_expandedExamId == exam.id) {
                                      _expandedExamId = null;
                                    } else {
                                      _expandedExamId = exam.id;
                                    }
                                  });
                                },
                                onToggleFavorite: () {
                                  ref
                                      .read(favoritesProvider.notifier)
                                      .toggleFavorite(exam.id);
                                },
                                onRemind: () async {
                                  await _showReminderOptions(context, exam);
                                },
                                onExportCalendar: () async {
                                  try {
                                    await exportEtsToCalendar(exam);
                                    if (!context.mounted) {
                                      return;
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Archivo de calendario generado correctamente.',
                                        ),
                                      ),
                                    );
                                  } catch (_) {
                                    if (!context.mounted) {
                                      return;
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'No se pudo exportar el calendario.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                onOpenEmail: () async {
                                  final uri = Uri(
                                    scheme: 'mailto',
                                    path: exam.correo,
                                    queryParameters: {
                                      'subject':
                                          'Consulta sobre ETS - ${exam.ua}',
                                    },
                                  );

                                  final opened = await launchUrl(uri);

                                  if (!opened && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'No se pudo abrir la aplicación de correo.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const _EscomFooterLocation(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Héroe: eyebrow + título serif + descripción, sobre tinte con motivo hexagonal.
class _Hero extends StatelessWidget {
  const _Hero({
    this.userName,
    required this.etsCount,
    required this.careerCount,
  });

  final String? userName;
  final int etsCount;
  final int careerCount;

  @override
  Widget build(BuildContext context) {
    return GradientHero(
      borderRadius: null,
      showHexMotif: true,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 46),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow(
            'Exámenes a Título de Suficiencia · Periodo 2026',
            color: AppColors.azul200,
          ),
          const SizedBox(height: 12),
          Text(
            userName == null
                ? 'Consulta tu calendario de ETS'
                : 'Hola, $userName',
            style: AppType.serif(size: 34, color: Colors.white, height: 1.06),
          ),
          const SizedBox(height: 12),
          Text(
            'Filtra por carrera, plan, semestre y materia. Guarda favoritos, '
            'programa recordatorios y exporta tu calendario a PDF o iCalendar.',
            style: AppType.sans(
              size: 16,
              color: AppColors.textOnDark.withValues(alpha: 0.85),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              HeroPill(
                icon: Icons.event_available_outlined,
                label: '$etsCount exámenes publicados',
              ),
              HeroPill(
                icon: Icons.school_outlined,
                label: '$careerCount carreras',
              ),
              const HeroPill(
                icon: Icons.download_outlined,
                label: 'Exporta a PDF · iCalendar',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({
    required this.lastUpdated,
  });

  final DateTime? lastUpdated;

  @override
  Widget build(BuildContext context) {
    final formattedDate = lastUpdated == null
        ? 'sin fecha disponible'
        : DateFormat('dd/MM/yyyy HH:mm').format(lastUpdated!);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warningSoft,
        borderRadius: AppRadii.rmd,
        border: Border.all(color: AppColors.amber600.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_outlined,
              color: AppColors.amber600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Mostrando datos guardados localmente. Última actualización: $formattedDate',
              style: AppType.sans(size: 13, color: AppColors.slate700),
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltersCard extends StatelessWidget {
  const _FiltersCard({
    required this.searchController,
    required this.filters,
    required this.carreras,
    required this.planes,
    required this.semestres,
    required this.onSearchChanged,
    required this.onCarreraChanged,
    required this.onPlanChanged,
    required this.onSemestreChanged,
    required this.onClear,
  });

  final TextEditingController searchController;
  final EtsFilters filters;
  final List<String> carreras;
  final List<String> planes;
  final List<int> semestres;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onCarreraChanged;
  final ValueChanged<String?> onPlanChanged;
  final ValueChanged<int?> onSemestreChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return DsCard(
      padding: const EdgeInsets.all(22),
      shadow: AppShadows.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PanelHeader(
            icon: Icons.search,
            title: 'Buscador inteligente',
            description: 'Acota la oferta de exámenes con los filtros.',
          ),
          const SizedBox(height: 18),
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: const InputDecoration(
              hintText: 'Buscar materia, profesor o salón',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 740;

              final carreraFilter = _FilterSelector<String>(
                label: 'Carrera',
                value: filters.carrera,
                items: carreras,
                itemLabel: (value) => value,
                onChanged: onCarreraChanged,
              );

              final planFilter = _FilterSelector<String>(
                label: 'Plan',
                value: filters.plan,
                items: planes,
                itemLabel: (value) => 'Plan $value',
                onChanged: onPlanChanged,
              );

              final semestreFilter = _FilterSelector<int>(
                label: 'Semestre',
                value: filters.semestre,
                items: semestres,
                itemLabel: (value) => '$value° semestre',
                onChanged: onSemestreChanged,
              );

              if (compact) {
                return Column(
                  children: [
                    carreraFilter,
                    const SizedBox(height: 12),
                    planFilter,
                    const SizedBox(height: 12),
                    semestreFilter,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: carreraFilter),
                  const SizedBox(width: 12),
                  Expanded(child: planFilter),
                  const SizedBox(width: 12),
                  Expanded(child: semestreFilter),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
              label: const Text('Limpiar filtros'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSelector<T> extends StatelessWidget {
  const _FilterSelector({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T value) itemLabel;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedText = value == null ? '' : itemLabel(value as T);

    return LayoutBuilder(
      builder: (context, constraints) {
        return PopupMenuButton<T>(
          tooltip: label,
          enabled: items.isNotEmpty,
          initialValue: value,
          constraints: BoxConstraints(
            minWidth: constraints.maxWidth,
            maxWidth: constraints.maxWidth,
          ),
          position: PopupMenuPosition.under,
          onSelected: (selected) {
            onChanged(selected);
          },
          itemBuilder: (context) {
            return items
                .map(
                  (item) => PopupMenuItem<T>(
                    value: item,
                    child: Text(
                      itemLabel(item),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList();
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: _iconForLabel(label),
              suffixIcon: const Icon(Icons.arrow_drop_down),
            ),
            child: Text(
              selectedText.isEmpty ? 'Seleccionar' : selectedText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: selectedText.isEmpty
                  ? AppType.sans(size: 15, color: AppColors.textFaint)
                  : AppType.sans(size: 15, color: AppColors.textStrong),
            ),
          ),
        );
      },
    );
  }

  Icon _iconForLabel(String label) {
    switch (label) {
      case 'Carrera':
        return const Icon(Icons.school_outlined);
      case 'Plan':
        return const Icon(Icons.list_alt_outlined);
      case 'Semestre':
        return const Icon(Icons.tag_outlined);
      default:
        return const Icon(Icons.filter_list_outlined);
    }
  }
}

class _EtsCard extends StatelessWidget {
  const _EtsCard({
    required this.exam,
    required this.isExpanded,
    required this.isFavorite,
    required this.onToggleExpanded,
    required this.onToggleFavorite,
    required this.onExportCalendar,
    required this.onOpenEmail,
    required this.onRemind,
  });

  final Ets exam;
  final bool isExpanded;
  final bool isFavorite;
  final VoidCallback onToggleExpanded;
  final VoidCallback onToggleFavorite;
  final VoidCallback onExportCalendar;
  final VoidCallback onOpenEmail;
  final VoidCallback onRemind;

  @override
  Widget build(BuildContext context) {
    final localDate = exam.fecha.toLocal();

    final date = DateFormat('dd MMM yyyy', 'es_MX').format(localDate);
    final hour = DateFormat('HH:mm').format(localDate);
    final isMorning = exam.turno.toLowerCase().startsWith('mat');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.rlg,
        border: Border.all(
          color: isExpanded ? AppColors.azul300 : AppColors.borderSubtle,
        ),
        boxShadow: isExpanded ? AppShadows.md : AppShadows.sm,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: onToggleExpanded,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
              child: Row(
                children: [
                  CareerBadge(code: exam.carrera, size: 44),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exam.ua,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppType.sans(
                            size: 15,
                            weight: FontWeight.w700,
                            color: AppColors.textStrong,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${exam.carrera} · ${exam.plan} · ${exam.semestre}° semestre',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppType.mono(
                            size: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: isFavorite
                        ? 'Quitar de favoritos'
                        : 'Guardar favorito',
                    onPressed: onToggleFavorite,
                    icon: Icon(
                      isFavorite
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: isFavorite
                          ? AppColors.amber600
                          : AppColors.textFaint,
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: _EtsDetails(
              exam: exam,
              date: date,
              hour: hour,
              isMorning: isMorning,
              onExportCalendar: onExportCalendar,
              onOpenEmail: onOpenEmail,
              onRemind: onRemind,
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: AppMotion.normal,
            sizeCurve: AppMotion.easeOut,
          ),
        ],
      ),
    );
  }
}

class _EtsDetails extends StatelessWidget {
  const _EtsDetails({
    required this.exam,
    required this.date,
    required this.hour,
    required this.isMorning,
    required this.onExportCalendar,
    required this.onOpenEmail,
    required this.onRemind,
  });

  final Ets exam;
  final String date;
  final String hour;
  final bool isMorning;
  final VoidCallback onExportCalendar;
  final VoidCallback onOpenEmail;
  final VoidCallback onRemind;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              DsBadge(
                label: exam.turno,
                tone: isMorning ? BadgeTone.warning : BadgeTone.info,
                icon: isMorning
                    ? Icons.wb_sunny_outlined
                    : Icons.nights_stay_outlined,
              ),
              DsBadge(label: 'Plan ${exam.plan}', tone: BadgeTone.neutral),
              DsBadge(
                label: '${exam.semestre}° semestre',
                tone: BadgeTone.neutral,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(icon: Icons.event_outlined, label: 'Fecha', value: date),
          _InfoRow(icon: Icons.schedule_outlined, label: 'Horario', value: '$hour h'),
          _InfoRow(
            icon: Icons.person_outline,
            label: 'Profesor evaluador',
            value: exam.profesor,
          ),
          _InfoRow(
            icon: Icons.mail_outlined,
            label: 'Correo',
            value: exam.correo,
            mono: true,
          ),
          _InfoRow(
            icon: Icons.meeting_room_outlined,
            label: 'Salón',
            value:
                '${exam.salon} · ${exam.edificio ?? 'Edificio no asignado'}',
            mono: true,
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 560;

              final buttons = <Widget>[
                OutlinedButton.icon(
                  onPressed: onOpenEmail,
                  icon: const Icon(Icons.mail_outlined, size: 18),
                  label: const Text('Contactar'),
                ),
                OutlinedButton.icon(
                  onPressed: onExportCalendar,
                  icon: const Icon(Icons.calendar_month_outlined, size: 18),
                  label: const Text('Calendario'),
                ),
                FilledButton.icon(
                  onPressed: onRemind,
                  icon: const Icon(Icons.notifications_active_outlined, size: 18),
                  label: const Text('Recordar'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    context.push('/mapa-salon', extra: exam.salon);
                  },
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: const Text('Ver salón'),
                ),
              ];

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < buttons.length; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      buttons[i],
                    ],
                  ],
                );
              }

              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: buttons
                    .map((button) => SizedBox(width: 188, child: button))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.mono = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 10),
          SizedBox(
            width: 116,
            child: Text(
              label,
              style: AppType.sans(size: 13, color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: mono
                  ? AppType.mono(size: 13, color: AppColors.textStrong)
                  : AppType.sans(
                      size: 14,
                      weight: FontWeight.w500,
                      color: AppColors.textStrong,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) {
    return DsCard(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.event_busy_outlined,
                size: 46, color: AppColors.slate300),
            const SizedBox(height: 14),
            Text(
              'Sin resultados',
              style: AppType.sans(
                size: 16,
                weight: FontWeight.w600,
                color: AppColors.textBody,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ajusta los filtros para ver la oferta de ETS.',
              style: AppType.sans(size: 14, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return DsCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.dangerSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.wifi_off_rounded,
                color: AppColors.danger, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            'No fue posible cargar los ETS',
            style: AppType.sans(
              size: 16,
              weight: FontWeight.w700,
              color: AppColors.textStrong,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No hay datos locales guardados. Revisa tu conexión e intenta otra vez.',
            style: AppType.sans(size: 14, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class _EscomFooterLocation extends StatelessWidget {
  const _EscomFooterLocation();

  @override
  Widget build(BuildContext context) {
    return DsCard(
      color: AppColors.primarySoft,
      borderColor: AppColors.azul200,
      shadow: AppShadows.xs,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.place_outlined,
                size: 26, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text(
            'Ubicación de ESCOM',
            style: AppType.sans(
              size: 16,
              weight: FontWeight.w700,
              color: AppColors.azul900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Consulta tu distancia aproximada y abre la ruta en Google Maps.',
            style: AppType.sans(size: 13, color: AppColors.azul800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                context.push('/ubicacion-escom');
              },
              icon: const Icon(Icons.directions_outlined, size: 18),
              label: const Text('Cómo llegar a ESCOM'),
            ),
          ),
        ],
      ),
    );
  }
}
