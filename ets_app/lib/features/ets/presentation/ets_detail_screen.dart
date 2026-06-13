import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ds_widgets.dart';
import '../domain/entities/ets.dart';

class EtsDetailScreen extends StatelessWidget {
  final Ets ets;

  const EtsDetailScreen({
    super.key,
    required this.ets,
  });

  @override
  Widget build(BuildContext context) {
    final localDate = ets.fecha.toLocal();
    final date = DateFormat('dd MMMM yyyy', 'es_MX').format(localDate);
    final hour = DateFormat('HH:mm').format(localDate);
    final isMorning = ets.turno.toLowerCase().startsWith('mat');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del ETS'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CareerBadge(code: ets.carrera, size: 48),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ets.ua, style: AppType.serif(size: 22)),
                            const SizedBox(height: 4),
                            Text(
                              '${ets.carrera} · Plan ${ets.plan} · ${ets.semestre}° semestre',
                              style: AppType.mono(
                                size: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      DsBadge(
                        label: ets.turno,
                        tone: isMorning ? BadgeTone.warning : BadgeTone.info,
                        icon: isMorning
                            ? Icons.wb_sunny_outlined
                            : Icons.nights_stay_outlined,
                      ),
                      DsBadge(label: 'Plan ${ets.plan}', tone: BadgeTone.neutral),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DsCard(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  _DetailRow(icon: Icons.event_outlined, label: 'Fecha', value: date),
                  _DetailRow(
                      icon: Icons.schedule_outlined, label: 'Horario', value: '$hour h'),
                  _DetailRow(
                    icon: Icons.person_outline,
                    label: 'Profesor evaluador',
                    value: ets.profesor,
                  ),
                  _DetailRow(
                    icon: Icons.mail_outlined,
                    label: 'Correo',
                    value: ets.correo,
                    mono: true,
                    last: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DsCard(
              onTap: () => context.push('/mapa-salon', extra: ets.salon),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: AppRadii.rmd,
                    ),
                    child: const Icon(Icons.meeting_room_outlined,
                        color: AppColors.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Salón ${ets.salon}',
                          style: AppType.sans(
                            size: 15,
                            weight: FontWeight.w700,
                            color: AppColors.textStrong,
                          ),
                        ),
                        Text(
                          ets.edificio ?? 'Edificio no especificado',
                          style: AppType.sans(
                              size: 13, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textFaint),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.push('/mapa-salon', extra: ets.salon),
              icon: const Icon(Icons.map_outlined, size: 18),
              label: const Text('Ver salón en mapa interno'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => context.push('/ubicacion-escom'),
              icon: const Icon(Icons.place_outlined, size: 18),
              label: const Text('Cómo llegar a ESCOM'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.mono = false,
    this.last = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool mono;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.borderSubtle),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textMuted),
          const SizedBox(width: 12),
          SizedBox(
            width: 130,
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
