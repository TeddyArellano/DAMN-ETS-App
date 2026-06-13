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
import '../../auth/presentation/auth_providers.dart';
import '../domain/entities/ets.dart';
import 'ets_providers.dart';
import 'favorites_provider.dart';
import 'utils/ics_export.dart';

enum _ReminderOption {
  now,
  oneHourBefore,
  oneDayBefore,
  cancel,
}

class FavoriteEtsScreen extends ConsumerStatefulWidget {
  const FavoriteEtsScreen({super.key});

  @override
  ConsumerState<FavoriteEtsScreen> createState() => _FavoriteEtsScreenState();
}

class _FavoriteEtsScreenState extends ConsumerState<FavoriteEtsScreen> {
  int? _expandedExamId;

  Future<bool> _confirmClearFavorites() async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
        return AlertDialog(
            title: const Text('Limpiar favoritos'),
            content: const Text(
            '¿Seguro que quieres eliminar todos tus ETS favoritos? Esta acción no se puede deshacer.',
            ),
            actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            actions: [
            Row(
                children: [
                Expanded(
                    child: OutlinedButton(
                    onPressed: () {
                        Navigator.of(context).pop(false);
                    },
                    child: const Text('Cancelar'),
                    ),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: FilledButton.icon(
                    onPressed: () {
                        Navigator.of(context).pop(true);
                    },
                    icon: const Icon(Icons.delete_sweep_outlined),
                    label: const Text('Sí, eliminar'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
    );

    return confirmed ?? false;
  }   

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

      _showMessage('Recordatorio enviado como notificación.');
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage('No se pudo generar el recordatorio.');
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

      _showMessage('$message Fecha: $formattedDate');
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage('No se pudo programar el recordatorio.');
    }
  }

  Future<void> _cancelReminders(Ets exam) async {
    try {
      await LocalNotificationsService.cancelEtsReminders(exam.id);

      if (!mounted) {
        return;
      }

      _showMessage('Recordatorios cancelados para este ETS.');
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage('No se pudieron cancelar los recordatorios.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).asData?.value;
    final etsResult = ref.watch(etsListProvider);
    final favoritesResult = ref.watch(favoritesProvider);
    final favorites = favoritesResult.value ?? <int>{};

    return Scaffold(
        appBar: AppBar(
        leading: IconButton(
            tooltip: 'Regresar',
            onPressed: () {
            context.go('/ets');
            },
            icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Mis favoritos'),
        actions: [
          if (user != null && MediaQuery.sizeOf(context).width >= 480)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 140),
                  child: Text(
                    user.name,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
          IconButton(
            tooltip: 'Actualizar ETS',
            onPressed: () {
              ref.read(etsListProvider.notifier).refresh();
            },
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
      body: RefreshIndicator(
        onRefresh: () => ref.read(etsListProvider.notifier).refresh(),
        child: etsResult.when(
          loading: () => ListView(
            children: const [
                SizedBox(height: 180),
                Center(child: CircularProgressIndicator()),
              ],
            ),
          error: (error, stackTrace) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _ErrorCard(
                onRetry: () {
                  ref.read(etsListProvider.notifier).refresh();
                },
              ),
            ],
          ),
          data: (result) {
            final favoriteItems = result.items
                .where((exam) => favorites.contains(exam.id))
                .toList();

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _HeaderCard(
                  totalFavorites: favoriteItems.length,
                ),
                const SizedBox(height: 18),
                if (result.fromCache) ...[
                  _OfflineBanner(lastUpdated: result.lastUpdated),
                  const SizedBox(height: 18),
                ],
                if (favoriteItems.isEmpty)
                  const _EmptyFavoritesCard()
                else ...[
                  Text(
                    '${favoriteItems.length} ETS favorito(s)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...favoriteItems.map(
                    (exam) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _FavoriteEtsCard(
                        exam: exam,
                        isExpanded: _expandedExamId == exam.id,
                        onToggleExpanded: () {
                          setState(() {
                            _expandedExamId =
                                _expandedExamId == exam.id ? null : exam.id;
                          });
                        },
                        onRemoveFavorite: () async {
                          await ref
                              .read(favoritesProvider.notifier)
                              .toggleFavorite(exam.id);

                          if (!context.mounted) {
                            return;
                          }

                          _showMessage('ETS eliminado de favoritos.');
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

                            _showMessage(
                              'Archivo de calendario generado correctamente.',
                            );
                          } catch (_) {
                            if (!context.mounted) {
                              return;
                            }

                            _showMessage(
                              'No se pudo exportar el calendario.',
                            );
                          }
                        },
                        onOpenEmail: () async {
                          final uri = Uri(
                            scheme: 'mailto',
                            path: exam.correo,
                            queryParameters: {
                              'subject': 'Consulta sobre ETS - ${exam.ua}',
                            },
                          );

                          final opened = await launchUrl(uri);

                          if (!opened && context.mounted) {
                            _showMessage(
                              'No se pudo abrir la aplicación de correo.',
                            );
                          }
                        },
                        onOpenMap: () {
                          context.push(
                            '/mapa-salon',
                            extra: exam.salon,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                    OutlinedButton.icon(
                    onPressed: () async {
                        final confirmed = await _confirmClearFavorites();

                        if (!confirmed) {
                        return;
                        }

                        await ref
                            .read(favoritesProvider.notifier)
                            .clearFavorites();

                        if (!context.mounted) {
                        return;
                        }

                        _showMessage('Todos los favoritos fueron eliminados.');
                    },
                    icon: const Icon(Icons.delete_sweep_outlined),
                    label: const Text('Limpiar todos los favoritos'),
                    ),
                    const SizedBox(height: 14),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 46,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Ubicación general de ESCOM',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Consulta tu distancia aproximada y abre la ruta en Google Maps.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () {
                                context.push('/ubicacion-escom');
                              },
                              icon: const Icon(Icons.assistant_direction_outlined),
                              label: const Text('Cómo llegar a ESCOM'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.totalFavorites,
  });

  final int totalFavorites;

  @override
  Widget build(BuildContext context) {
    return DsCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.warningSoft,
              borderRadius: AppRadii.rmd,
            ),
            child: const Icon(Icons.star_rounded,
                color: AppColors.amber600, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mis ETS favoritos', style: AppType.serif(size: 22)),
                const SizedBox(height: 2),
                Text(
                  totalFavorites == 0
                      ? 'Todavía no tienes ETS guardados.'
                      : 'Consulta rápidamente tus ETS favoritos.',
                  style: AppType.sans(size: 14, color: AppColors.textMuted),
                ),
              ],
            ),
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

class _FavoriteEtsCard extends StatelessWidget {
  const _FavoriteEtsCard({
    required this.exam,
    required this.isExpanded,
    required this.onToggleExpanded,
    required this.onRemoveFavorite,
    required this.onExportCalendar,
    required this.onOpenEmail,
    required this.onRemind,
    required this.onOpenMap,
  });

  final Ets exam;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final VoidCallback onRemoveFavorite;
  final VoidCallback onExportCalendar;
  final VoidCallback onOpenEmail;
  final VoidCallback onRemind;
  final VoidCallback onOpenMap;

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
                              size: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Quitar de favoritos',
                    onPressed: onRemoveFavorite,
                    icon: const Icon(Icons.star_rounded,
                        color: AppColors.amber600),
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
            secondChild: Container(
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
                        tone:
                            isMorning ? BadgeTone.warning : BadgeTone.info,
                        icon: isMorning
                            ? Icons.wb_sunny_outlined
                            : Icons.nights_stay_outlined,
                      ),
                      DsBadge(
                          label: 'Plan ${exam.plan}', tone: BadgeTone.neutral),
                      DsBadge(
                        label: '${exam.semestre}° semestre',
                        tone: BadgeTone.neutral,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(
                      icon: Icons.event_outlined, label: 'Fecha', value: date),
                  _InfoRow(
                      icon: Icons.schedule_outlined,
                      label: 'Horario',
                      value: '$hour h'),
                  _InfoRow(
                    icon: Icons.person_outline,
                    label: 'Profesor',
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
                          icon: const Icon(Icons.calendar_month_outlined,
                              size: 18),
                          label: const Text('Calendario'),
                        ),
                        FilledButton.icon(
                          onPressed: onRemind,
                          icon: const Icon(Icons.notifications_active_outlined,
                              size: 18),
                          label: const Text('Recordar'),
                        ),
                        OutlinedButton.icon(
                          onPressed: onOpenMap,
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
                            .map((button) =>
                                SizedBox(width: 188, child: button))
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
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
            width: 96,
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

class _EmptyFavoritesCard extends StatelessWidget {
  const _EmptyFavoritesCard();

  @override
  Widget build(BuildContext context) {
    return DsCard(
      padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 24),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.star_border_rounded,
                size: 52, color: AppColors.slate300),
            const SizedBox(height: 14),
            Text(
              'Todavía no tienes ETS favoritos',
              textAlign: TextAlign.center,
              style: AppType.sans(
                size: 16,
                weight: FontWeight.w600,
                color: AppColors.textBody,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Regresa a Consulta de ETS y toca la estrella para guardar uno.',
              textAlign: TextAlign.center,
              style: AppType.sans(size: 14, color: AppColors.textMuted),
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
          const Icon(Icons.error_outline, size: 46, color: AppColors.danger),
          const SizedBox(height: 12),
          Text(
            'No fue posible cargar tus favoritos.',
            textAlign: TextAlign.center,
            style: AppType.sans(size: 15, color: AppColors.textBody),
          ),
          const SizedBox(height: 16),
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