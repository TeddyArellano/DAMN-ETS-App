import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ds_widgets.dart';
import '../../domain/entities/building.dart';
import '../../domain/entities/career.dart';
import '../../domain/entities/subject.dart';
import '../providers/admin_providers.dart';

class CatalogsScreen extends ConsumerStatefulWidget {
  const CatalogsScreen({super.key});

  @override
  ConsumerState<CatalogsScreen> createState() => _CatalogsScreenState();
}

class _CatalogsScreenState extends ConsumerState<CatalogsScreen> {
  final _careerFormKey = GlobalKey<FormState>();
  final _buildingFormKey = GlobalKey<FormState>();

  final _careerCodeController = TextEditingController();
  final _careerNameController = TextEditingController();
  final _careerPlansController = TextEditingController();

  final _buildingNameController = TextEditingController();

  bool _savingCareer = false;
  bool _savingBuilding = false;

  @override
  void dispose() {
    _careerCodeController.dispose();
    _careerNameController.dispose();
    _careerPlansController.dispose();
    _buildingNameController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  String _errorMessage(Object error) {
    return getReadableErrorMessage(error);
  }

    Future<bool> _confirmDelete({
    required String title,
    required String message,
  }) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    return accepted ?? false;
  }

  Future<void> _createCareer() async {
    if (!_careerFormKey.currentState!.validate()) {
      return;
    }

    final plans = _careerPlansController.text
        .split(',')
        .map((plan) => plan.trim())
        .where((plan) => plan.isNotEmpty)
        .toSet()
        .toList();

    setState(() {
      _savingCareer = true;
    });

    try {
      await ref.read(adminCareersProvider.notifier).createCareer(
            code: _careerCodeController.text,
            name: _careerNameController.text,
            plans: plans,
          );

      _careerCodeController.clear();
      _careerNameController.clear();
      _careerPlansController.clear();

      if (mounted) {
        _showMessage('Carrera creada correctamente.');
      }
    } catch (error) {
      if (mounted) {
        _showMessage(_errorMessage(error));
      }
    } finally {
      if (mounted) {
        setState(() {
          _savingCareer = false;
        });
      }
    }
  }

  Future<void> _createBuilding() async {
    if (!_buildingFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _savingBuilding = true;
    });

    try {
      await ref.read(adminBuildingsProvider.notifier).createBuilding(
            name: _buildingNameController.text,
          );

      _buildingNameController.clear();

      if (mounted) {
        _showMessage('Edificio creado correctamente.');
      }
    } catch (error) {
      if (mounted) {
        _showMessage(_errorMessage(error));
      }
    } finally {
      if (mounted) {
        setState(() {
          _savingBuilding = false;
        });
      }
    }
  }

    Future<void> _deleteCareer(Career career) async {
    final accepted = await _confirmDelete(
      title: 'Eliminar carrera',
      message:
          '¿Seguro que deseas eliminar "${career.code} · ${career.name}"?',
    );

    if (!accepted) {
      return;
    }

    try {
      await ref.read(adminCareersProvider.notifier).deleteCareer(career.id);

      if (mounted) {
        _showMessage('Carrera eliminada correctamente.');
      }
    } catch (error) {
      if (mounted) {
        _showMessage(_errorMessage(error));
      }
    }
  }

  Future<void> _deleteBuilding(Building building) async {
    final accepted = await _confirmDelete(
      title: 'Eliminar edificio',
      message: '¿Seguro que deseas eliminar "${building.name}"?',
    );

    if (!accepted) {
      return;
    }

    try {
      await ref
          .read(adminBuildingsProvider.notifier)
          .deleteBuilding(building.id);

      if (mounted) {
        _showMessage('Edificio eliminado correctamente.');
      }
    } catch (error) {
      if (mounted) {
        _showMessage(_errorMessage(error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final careersState = ref.watch(adminCareersProvider);
    final buildingsState = ref.watch(adminBuildingsProvider);
    final subjectsState = ref.watch(adminSubjectsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wideLayout = constraints.maxWidth >= 960;

          final careersCard = _CareersCard(
            formKey: _careerFormKey,
            codeController: _careerCodeController,
            nameController: _careerNameController,
            plansController: _careerPlansController,
            saving: _savingCareer,
            state: careersState,
            onSubmit: _createCareer,
            onDelete: _deleteCareer,
            onRefresh: () {
              ref.read(adminCareersProvider.notifier).refresh();
            },
          );

          final buildingsCard = _BuildingsCard(
            formKey: _buildingFormKey,
            nameController: _buildingNameController,
            saving: _savingBuilding,
            state: buildingsState,
            onSubmit: _createBuilding,
            onDelete: _deleteBuilding,
            onRefresh: () {
              ref.read(adminBuildingsProvider.notifier).refresh();
            },
          );

          final subjectsCard = _SubjectsCard(
            subjectsState: subjectsState,
            careersState: careersState,
            onRefresh: () {
              ref.read(adminSubjectsProvider.notifier).refresh();
            },
          );

          if (!wideLayout) {
            return Column(
              children: [
                careersCard,
                const SizedBox(height: 18),
                buildingsCard,
                const SizedBox(height: 18),
                subjectsCard,
              ],
            );
          }

          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: careersCard),
                  const SizedBox(width: 18),
                  Expanded(child: buildingsCard),
                ],
              ),
              const SizedBox(height: 18),
              subjectsCard,
            ],
          );
        },
      ),
    );
  }
}

class _CareersCard extends StatelessWidget {
  const _CareersCard({
    required this.formKey,
    required this.codeController,
    required this.nameController,
    required this.plansController,
    required this.saving,
    required this.state,
    required this.onSubmit,
    required this.onDelete,
    required this.onRefresh,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController codeController;
  final TextEditingController nameController;
  final TextEditingController plansController;
  final bool saving;
  final AsyncValue<List<Career>> state;
  final VoidCallback onSubmit;
  final ValueChanged<Career> onDelete;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              icon: Icons.school_outlined,
              title: 'Carreras',
              subtitle: 'Gestiona carreras y planes de estudio.',
              onRefresh: onRefresh,
            ),
            const SizedBox(height: 20),
            Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: codeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Código',
                      hintText: 'IIA',
                      prefixIcon: Icon(Icons.short_text),
                    ),
                    validator: (value) {
                      final code = value?.trim() ?? '';

                      if (!RegExp(r'^[A-Za-z0-9]{2,10}$').hasMatch(code)) {
                        return 'Usa entre 2 y 10 letras o números';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre completo',
                      hintText: 'Ingeniería en Inteligencia Artificial',
                      prefixIcon: Icon(Icons.menu_book_outlined),
                    ),
                    validator: (value) {
                      if ((value?.trim().length ?? 0) < 3) {
                        return 'Ingresa el nombre de la carrera';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: plansController,
                    decoration: const InputDecoration(
                      labelText: 'Planes',
                      hintText: '2020, 2025',
                      prefixIcon: Icon(Icons.list_alt_outlined),
                    ),
                    validator: (value) {
                      final plans = value
                              ?.split(',')
                              .map((item) => item.trim())
                              .where((item) => item.isNotEmpty)
                              .toList() ??
                          [];

                      if (plans.isEmpty) {
                        return 'Ingresa al menos un plan';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: saving ? null : onSubmit,
                      icon: saving
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add),
                      label: Text(
                        saving ? 'Guardando...' : 'Crear carrera',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Carreras registradas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            state.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stackTrace) => const _CatalogError(),
              data: (items) {
                if (items.isEmpty) {
                  return const _CatalogEmpty(
                    message: 'No hay carreras registradas.',
                  );
                }

                return Column(
                  children: items
                      .map(
                        (career) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                            child: _CareerItem(
                            career: career,
                            onDelete: () {
                              onDelete(career);
                            },
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BuildingsCard extends StatelessWidget {
  const _BuildingsCard({
    required this.formKey,
    required this.nameController,
    required this.saving,
    required this.state,
    required this.onSubmit,
    required this.onDelete,
    required this.onRefresh,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final bool saving;
  final AsyncValue<List<Building>> state;
  final VoidCallback onSubmit;
  final ValueChanged<Building> onDelete;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              icon: Icons.apartment_outlined,
              title: 'Edificios',
              subtitle: 'Registra edificios o zonas de salones.',
              onRefresh: onRefresh,
            ),
            const SizedBox(height: 20),
            Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del edificio',
                      hintText: 'Edificio 2',
                      prefixIcon: Icon(Icons.location_city_outlined),
                    ),
                    validator: (value) {
                      if ((value?.trim().length ?? 0) < 2) {
                        return 'Ingresa el nombre del edificio';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: saving ? null : onSubmit,
                      icon: saving
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add),
                      label: Text(
                        saving ? 'Guardando...' : 'Crear edificio',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Edificios registrados',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            state.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stackTrace) => const _CatalogError(),
              data: (items) {
                if (items.isEmpty) {
                  return const _CatalogEmpty(
                    message: 'No hay edificios registrados.',
                  );
                }

                return Column(
                  children: items
                      .map(
                        (building) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                            child: _BuildingItem(
                            building: building,
                            onDelete: () {
                              onDelete(building);
                            },
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectsCard extends StatelessWidget {
  const _SubjectsCard({
    required this.subjectsState,
    required this.careersState,
    required this.onRefresh,
  });

  final AsyncValue<List<Subject>> subjectsState;
  final AsyncValue<List<Career>> careersState;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final careers = careersState.value ?? const <Career>[];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              icon: Icons.menu_book_outlined,
              title: 'Materias',
              subtitle: 'Consulta materias por carrera, plan y semestre.',
              onRefresh: onRefresh,
            ),
            const SizedBox(height: 20),
            subjectsState.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stackTrace) => const _CatalogError(),
              data: (subjects) {
                if (subjects.isEmpty) {
                  return const _CatalogEmpty(
                    message: 'No hay materias registradas.',
                  );
                }

                final grouped = _groupSubjects(subjects, careers);

                return Column(
                  children: grouped.entries.map((careerEntry) {
                    final careerGroup = careerEntry.value;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _CareerSubjectsGroup(
                        title: careerEntry.key,
                        plans: careerGroup,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Map<String, Map<String, Map<int, List<Subject>>>> _groupSubjects(
    List<Subject> subjects,
    List<Career> careers,
  ) {
    final careerById = {
      for (final career in careers) career.id: career,
    };

    final sortedSubjects = [...subjects]
      ..sort((first, second) {
        final firstCareer = careerById[first.careerId]?.code ?? '';
        final secondCareer = careerById[second.careerId]?.code ?? '';

        final careerCompare = firstCareer.compareTo(secondCareer);
        if (careerCompare != 0) {
          return careerCompare;
        }

        final planCompare = first.plan.compareTo(second.plan);
        if (planCompare != 0) {
          return planCompare;
        }

        final semesterCompare = first.semestre.compareTo(second.semestre);
        if (semesterCompare != 0) {
          return semesterCompare;
        }

        return first.name.compareTo(second.name);
      });

    final grouped = <String, Map<String, Map<int, List<Subject>>>>{};

    for (final subject in sortedSubjects) {
      final career = careerById[subject.careerId];

      final careerTitle = career == null
          ? 'Carrera ${subject.careerId}'
          : '${career.code} · ${career.name}';

      grouped
          .putIfAbsent(careerTitle, () => <String, Map<int, List<Subject>>>{})
          .putIfAbsent('Plan ${subject.plan}', () => <int, List<Subject>>{})
          .putIfAbsent(subject.semestre, () => <Subject>[])
          .add(subject);
    }

    return grouped;
  }
}

class _CareerSubjectsGroup extends StatelessWidget {
  const _CareerSubjectsGroup({
    required this.title,
    required this.plans,
  });

  final String title;
  final Map<String, Map<int, List<Subject>>> plans;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(top: 10),
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(
              Icons.school_outlined,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          title: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text('${_countSubjects()} materia(s) registradas'),
          children: plans.entries.map((planEntry) {
            return _PlanSubjectsGroup(
              plan: planEntry.key,
              semesters: planEntry.value,
            );
          }).toList(),
        ),
      ),
    );
  }

  int _countSubjects() {
    var total = 0;

    for (final semesters in plans.values) {
      for (final subjects in semesters.values) {
        total += subjects.length;
      }
    }

    return total;
  }
}

class _PlanSubjectsGroup extends StatelessWidget {
  const _PlanSubjectsGroup({
    required this.plan,
    required this.semesters,
  });

  final String plan;
  final Map<int, List<Subject>> semesters;

  @override
  Widget build(BuildContext context) {
    final semesterEntries = semesters.entries.toList()
      ..sort((first, second) => first.key.compareTo(second.key));

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plan,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            ...semesterEntries.map(
              (entry) => _SemesterSubjectsGroup(
                semester: entry.key,
                subjects: entry.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SemesterSubjectsGroup extends StatelessWidget {
  const _SemesterSubjectsGroup({
    required this.semester,
    required this.subjects,
  });

  final int semester;
  final List<Subject> subjects;

  @override
  Widget build(BuildContext context) {
    final sortedSubjects = [...subjects]
      ..sort((first, second) => first.name.compareTo(second.name));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(left: 12, bottom: 8),
          initiallyExpanded: false,
          leading: CircleAvatar(
            radius: 16,
            child: Text('$semester'),
          ),
          title: Text(
            '$semester° semestre',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text('${sortedSubjects.length} materia(s)'),
          children: sortedSubjects
              .map(
                (subject) => Material(
                  color: Colors.transparent,
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.menu_book_outlined, size: 20),
                    title: Text(subject.name),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onRefresh,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return PanelHeader(
      icon: icon,
      title: title,
      description: subtitle,
      trailing: IconButton(
        tooltip: 'Actualizar',
        onPressed: onRefresh,
        icon: const Icon(Icons.refresh, size: 18),
        style: IconButton.styleFrom(
          side: const BorderSide(color: AppColors.borderSubtle),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.rsm),
        ),
      ),
    );
  }
}

class _CareerItem extends StatelessWidget {
  const _CareerItem({
    required this.career,
    required this.onDelete,
  });

  final Career career;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.rmd,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CareerBadge(code: career.code, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  career.name,
                  style: AppType.sans(
                    size: 14,
                    weight: FontWeight.w600,
                    color: AppColors.textStrong,
                  ),
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: career.plans
                      .map((plan) => DsBadge(
                            label: 'Plan $plan',
                            tone: BadgeTone.neutral,
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Eliminar carrera',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 20),
            color: AppColors.textFaint,
            hoverColor: AppColors.dangerSoft,
          ),
        ],
      ),
    );
  }
}

class _BuildingItem extends StatelessWidget {
  const _BuildingItem({
    required this.building,
    required this.onDelete,
  });

  final Building building;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.rmd,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: AppRadii.rsm,
            ),
            child: const Icon(Icons.apartment_outlined,
                size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              building.name,
              style: AppType.sans(
                size: 14,
                weight: FontWeight.w600,
                color: AppColors.textStrong,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Eliminar edificio',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 20),
            color: AppColors.textFaint,
            hoverColor: AppColors.dangerSoft,
          ),
        ],
      ),
    );
  }
}

class _CatalogEmpty extends StatelessWidget {
  const _CatalogEmpty({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Center(child: Text(message)),
    );
  }
}

class _CatalogError extends StatelessWidget {
  const _CatalogError();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(18),
      child: Center(
        child: Text('No fue posible cargar la información.'),
      ),
    );
  }
}