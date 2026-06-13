import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ds_widgets.dart';
import '../../../ets/domain/entities/ets.dart';
import '../../../ets/presentation/ets_providers.dart';
import '../../domain/entities/building.dart';
import '../../domain/entities/career.dart';
import '../../domain/entities/subject.dart';
import '../providers/admin_providers.dart';

class EtsCrudScreen extends ConsumerStatefulWidget {
  const EtsCrudScreen({super.key});

  @override
  ConsumerState<EtsCrudScreen> createState() => _EtsCrudScreenState();
}

class _EtsCrudScreenState extends ConsumerState<EtsCrudScreen> {
  final _formKey = GlobalKey<FormState>();

  final _uaController = TextEditingController();
  final _semestreController = TextEditingController();
  final _turnoController = TextEditingController(text: 'Matutino');
  final _salonController = TextEditingController();
  final _profesorController = TextEditingController();
  final _correoController = TextEditingController();

  int? _careerId;
  String? _plan;
  int? _buildingId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int? _editingId;
  bool _saving = false;
  int _formVersion = 0;
  int? _selectedSemester;
  Subject? _selectedSubject;
  List<Subject> _subjects = [];

  bool get _isEditing => _editingId != null;

  @override
  void dispose() {
    _uaController.dispose();
    _semestreController.dispose();
    _turnoController.dispose();
    _salonController.dispose();
    _profesorController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  List<String> _plansForCareer(List<Career> careers, int? careerId) {
    for (final career in careers) {
      if (career.id == careerId) {
        return career.plans;
      }
    }

    return const [];
  }

  String _errorMessage(Object error) {
    return getReadableErrorMessage(error);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  void _clearForm() {
    _formKey.currentState?.reset();

    setState(() {
      _uaController.clear();
      _semestreController.clear();
      _turnoController.text = 'Matutino';
      _salonController.clear();
      _profesorController.clear();
      _correoController.clear();

      _careerId = null;
      _plan = null;
      _buildingId = null;
      _selectedDate = null;
      _selectedTime = null;
      _editingId = null;

      _selectedSemester = null;
      _selectedSubject = null;
      _subjects = [];

      _formVersion++;
    });
  }

  Future<void> _loadExamForEditing(Ets exam) async {
    final localDate = exam.fecha.toLocal();

    setState(() {
      _editingId = exam.id;
      _uaController.text = exam.ua;
      _semestreController.text = '${exam.semestre}';
      _turnoController.text = exam.turno;
      _salonController.text = exam.salon;
      _profesorController.text = exam.profesor;
      _correoController.text = exam.correo;

      _careerId = exam.careerId;
      _plan = exam.plan;
      _buildingId = exam.buildingId;

      _selectedSemester = exam.semestre;
      _selectedSubject = null;
      _subjects = [];

      _selectedDate = DateTime(
        localDate.year,
        localDate.month,
        localDate.day,
      );
      _selectedTime = TimeOfDay(
        hour: localDate.hour,
        minute: localDate.minute,
      );

      _formVersion++;
    });

    await _loadSubjects(clearSubject: false);

    if (!mounted) {
      return;
    }

    setState(() {
      for (final subject in _subjects) {
        if (subject.name == exam.ua) {
          _selectedSubject = subject;
          _uaController.text = subject.name;
          break;
        }
      }
    });
  }

  void _onCareerChanged(int? value, List<Career> careers) {
    final plans = _plansForCareer(careers, value);
    final nextPlan = plans.length == 1 ? plans.first : null;

    setState(() {
      _careerId = value;
      _plan = nextPlan;
      _selectedSemester = null;
      _selectedSubject = null;
      _subjects = [];
      _uaController.clear();
      _semestreController.clear();
      _formVersion++;
    });
  }

  void _onPlanChanged(String? value) {
    setState(() {
      _plan = value;
      _selectedSemester = null;
      _selectedSubject = null;
      _subjects = [];
      _uaController.clear();
      _semestreController.clear();
      _formVersion++;
    });
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime(2035),
      initialDate: _selectedDate ?? DateTime.now(),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _selectedDate = selected;
    });
  }

  Future<void> _selectTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _selectedTime ??
          const TimeOfDay(
            hour: 9,
            minute: 0,
          ),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _selectedTime = selected;
    });
  }

  Future<void> _saveExam(List<Career> careers) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final plans = _plansForCareer(careers, _careerId);

    if (_careerId == null) {
      _showMessage('Selecciona una carrera.');
      return;
    }

    if (_plan == null || !plans.contains(_plan)) {
      _showMessage('Selecciona un plan válido.');
      return;
    }

    if (_selectedSemester == null) {
      _showMessage('Selecciona un semestre.');
      return;
    }

    if (_selectedSubject == null) {
      _showMessage('Selecciona una unidad de aprendizaje.');
      return;
    }

    if (_buildingId == null) {
      _showMessage('Selecciona un edificio.');
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      _showMessage('Selecciona fecha y hora del ETS.');
      return;
    }

    final localDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final fechaIso = localDateTime.toUtc().toIso8601String();
    final adminEtsController = ref.read(adminEtsProvider.notifier);

    setState(() {
      _saving = true;
    });

    try {
      if (_isEditing) {
        await adminEtsController.updateEts(
          id: _editingId!,
          ua: _uaController.text.trim(),
          subjectId: _selectedSubject!.id,
          careerId: _careerId!,
          plan: _plan!,
          semestre: _selectedSemester!,
          fechaIso: fechaIso,
          turno: _turnoController.text.trim(),
          salon: _salonController.text.trim(),
          profesor: _profesorController.text.trim(),
          correo: _correoController.text.trim(),
          buildingId: _buildingId!,
        );

        if (mounted) {
          _showMessage('ETS actualizado correctamente.');
        }
      } else {
        await adminEtsController.createEts(
          ua: _uaController.text.trim(),
          subjectId: _selectedSubject!.id,
          careerId: _careerId!,
          plan: _plan!,
          semestre: _selectedSemester!,
          fechaIso: fechaIso,
          turno: _turnoController.text.trim(),
          salon: _salonController.text.trim(),
          profesor: _profesorController.text.trim(),
          correo: _correoController.text.trim(),
          buildingId: _buildingId!,
        );

        if (mounted) {
          _showMessage('ETS creado correctamente.');
        }
      }

      ref.invalidate(adminDashboardProvider);
      ref.invalidate(etsListProvider);

      if (mounted) {
        _clearForm();
      }
    } catch (error) {
      if (mounted) {
        _showMessage(_errorMessage(error));
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _deleteExam(Ets exam) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar ETS'),
          content: Text(
            '¿Seguro que deseas eliminar "${exam.ua}"?',
          ),
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

    if (accepted != true) {
      return;
    }

    try {
      await ref.read(adminEtsProvider.notifier).deleteEts(exam.id);

      if (mounted) {
        if (_editingId == exam.id) {
          _clearForm();
        }

        _showMessage('ETS eliminado correctamente.');
      }
    } catch (error) {
      if (mounted) {
        _showMessage(_errorMessage(error));
      }
    }
  }

  Future<void> _loadSubjects({
    bool clearSubject = true,
  }) async {
    if (_careerId == null || _plan == null || _selectedSemester == null) {
      setState(() {
        _subjects = [];
        _selectedSubject = null;
        _uaController.clear();
      });
      return;
    }

    try {
      final result = await ref.read(adminRepositoryProvider).getSubjects(
            careerId: _careerId,
            plan: _plan,
            semestre: _selectedSemester,
          );

      if (!mounted) {
        return;
      }

      setState(() {
        _subjects = result;

        if (clearSubject) {
          _selectedSubject = null;
          _uaController.clear();
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _subjects = [];
        _selectedSubject = null;
        _uaController.clear();
      });

      _showMessage(_errorMessage(error));
    }
  }
  @override
  Widget build(BuildContext context) {
    final etsState = ref.watch(adminEtsProvider);
    final careersState = ref.watch(adminCareersProvider);
    final buildingsState = ref.watch(adminBuildingsProvider);

    final careers = careersState.value ?? const <Career>[];
    final buildings = buildingsState.value ?? const <Building>[];

    final validCareerId =
        careers.any((career) => career.id == _careerId) ? _careerId : null;

    final plans = _plansForCareer(careers, validCareerId);
    final validPlan = plans.contains(_plan) ? _plan : null;

    final validBuildingId = buildings.any(
      (building) => building.id == _buildingId,
    )
        ? _buildingId
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wideLayout = constraints.maxWidth >= 1080;

          final form = _EtsFormCard(
            formKey: _formKey,
            formVersion: _formVersion,
            isEditing: _isEditing,
            saving: _saving,
            uaController: _uaController,
            semestreController: _semestreController,
            turnoController: _turnoController,
            salonController: _salonController,
            profesorController: _profesorController,
            correoController: _correoController,
            careers: careers,
            buildings: buildings,
            plans: plans,
            selectedCareerId: validCareerId,
            selectedPlan: validPlan,
            selectedBuildingId: validBuildingId,
            selectedDate: _selectedDate,
            selectedTime: _selectedTime,
            selectedSemester: _selectedSemester,
            selectedSubject: _selectedSubject,
            subjects: _subjects,
            onCareerChanged: (value) {
              _onCareerChanged(value, careers);
            },
            onPlanChanged: _onPlanChanged,
            onBuildingChanged: (value) {
              setState(() {
                _buildingId = value;
              });
            },
            onSemesterChanged: (value) async {
              setState(() {
                _selectedSemester = value;
                _semestreController.text = value?.toString() ?? '';
                _selectedSubject = null;
                _uaController.clear();
                _subjects = [];
                _formVersion++;
              });

              await _loadSubjects();
            },
            onSubjectChanged: (subject) {
              setState(() {
                _selectedSubject = subject;
                _uaController.text = subject?.name ?? '';
              });
            },
            onSelectDate: _selectDate,
            onSelectTime: _selectTime,
            onSubmit: () {
              _saveExam(careers);
            },
            onCancel: _clearForm,
          );

          final list = _EtsListCard(
            state: etsState,
            onRefresh: () {
              ref.read(adminEtsProvider.notifier).refresh();
            },
            onEdit: _loadExamForEditing,
            onDelete: _deleteExam,
          );

          final layout = !wideLayout
              ? Column(
                  children: [
                    form,
                    const SizedBox(height: 18),
                    list,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 440, child: form),
                    const SizedBox(width: 18),
                    Expanded(child: list),
                  ],
                );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GradientHero(
                borderRadius: AppRadii.rxl,
                shadow: AppShadows.lg,
                padding: const EdgeInsets.all(26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const HeroIconDisc(icon: Icons.event_available_outlined),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Eyebrow('Programación',
                                  color: AppColors.azul200),
                              const SizedBox(height: 6),
                              Text('Exámenes a Título de Suficiencia',
                                  style: AppType.serif(
                                      size: 24, color: Colors.white, height: 1.1)),
                              const SizedBox(height: 4),
                              Text(
                                'Registra, edita y consulta los ETS del periodo.',
                                style: AppType.sans(
                                  size: 14,
                                  color: AppColors.textOnDark
                                      .withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    HeroPill(
                      icon: Icons.event_note_outlined,
                      label: '${etsState.value?.length ?? 0} ETS en total',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              layout,
            ],
          );
        },
      ),
    );
  }
}

class _EtsFormCard extends StatelessWidget {
  const _EtsFormCard({
    required this.formKey,
    required this.formVersion,
    required this.isEditing,
    required this.saving,
    required this.uaController,
    required this.semestreController,
    required this.turnoController,
    required this.salonController,
    required this.profesorController,
    required this.correoController,
    required this.careers,
    required this.buildings,
    required this.plans,
    required this.selectedCareerId,
    required this.selectedPlan,
    required this.selectedBuildingId,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedSemester,
    required this.selectedSubject,
    required this.subjects,
    required this.onCareerChanged,
    required this.onPlanChanged,
    required this.onBuildingChanged,
    required this.onSemesterChanged,
    required this.onSubjectChanged,
    required this.onSelectDate,
    required this.onSelectTime,
    required this.onSubmit,
    required this.onCancel,
  });

  final GlobalKey<FormState> formKey;
  final int formVersion;
  final bool isEditing;
  final bool saving;
  final TextEditingController uaController;
  final TextEditingController semestreController;
  final TextEditingController turnoController;
  final TextEditingController salonController;
  final TextEditingController profesorController;
  final TextEditingController correoController;
  final List<Career> careers;
  final List<Building> buildings;
  final List<String> plans;
  final int? selectedCareerId;
  final String? selectedPlan;
  final int? selectedBuildingId;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final ValueChanged<int?> onCareerChanged;
  final ValueChanged<String?> onPlanChanged;
  final ValueChanged<int?> onBuildingChanged;
  final VoidCallback onSelectDate;
  final VoidCallback onSelectTime;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;
  final int? selectedSemester;
  final Subject? selectedSubject;
  final List<Subject> subjects;
  final ValueChanged<int?> onSemesterChanged;
  final ValueChanged<Subject?> onSubjectChanged;

  @override
  Widget build(BuildContext context) {
    final dateText = selectedDate == null
        ? 'Seleccionar fecha'
        : DateFormat('dd/MM/yyyy').format(selectedDate!);

    final timeText =
        selectedTime == null ? 'Seleccionar hora' : selectedTime!.format(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Eyebrow(isEditing ? 'Edición de examen' : 'Alta de examen'),
              const SizedBox(height: 8),
              Text(
                isEditing ? 'Editar ETS' : 'Crear ETS',
                style: AppType.serif(size: 24),
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<int>(
                key: ValueKey('career_$formVersion'),
                initialValue: selectedCareerId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Carrera',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                items: careers
                    .map(
                      (career) => DropdownMenuItem<int>(
                        value: career.id,
                        child: Text(
                          '${career.code} · ${career.name}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    )
                    .toList(),
                selectedItemBuilder: (context) {
                  return careers.map((career) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${career.code} · ${career.name}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    );
                  }).toList();
                },
                onChanged: onCareerChanged,
                validator: (value) {
                  if (value == null) {
                    return 'Selecciona una carrera';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: ValueKey('plan_${formVersion}_$selectedCareerId'),
                initialValue: selectedPlan,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Plan',
                  prefixIcon: Icon(Icons.list_alt_outlined),
                ),
                items: plans
                    .map(
                      (plan) => DropdownMenuItem<String>(
                        value: plan,
                        child: Text('Plan $plan'),
                      ),
                    )
                    .toList(),
                onChanged: plans.isEmpty ? null : onPlanChanged,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Selecciona un plan';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                key: ValueKey(
                  'semester_${formVersion}_${selectedCareerId}_$selectedPlan',
                ),
                initialValue: selectedSemester,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Semestre',
                  prefixIcon: Icon(Icons.tag),
                ),
                items: List.generate(8, (index) => index + 1)
                    .map(
                      (semester) => DropdownMenuItem<int>(
                        value: semester,
                        child: Text('$semester° semestre'),
                      ),
                    )
                    .toList(),
                onChanged: selectedCareerId == null || selectedPlan == null
                    ? null
                    : onSemesterChanged,
                validator: (value) {
                  if (value == null || value < 1 || value > 8) {
                    return 'Selecciona un semestre válido';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Subject>(
                key: ValueKey(
                  'subject_${formVersion}_${selectedCareerId}_${selectedPlan}_$selectedSemester',
                ),
                initialValue: selectedSubject,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Unidad de aprendizaje',
                  prefixIcon: Icon(Icons.menu_book),
                ),
                items: subjects
                    .map(
                      (subject) => DropdownMenuItem<Subject>(
                        value: subject,
                        child: Text(
                          subject.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    )
                    .toList(),
                selectedItemBuilder: (context) {
                  return subjects.map((subject) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        subject.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    );
                  }).toList();
                },
                onChanged: subjects.isEmpty ? null : onSubjectChanged,
                validator: (value) {
                  if (value == null) {
                    return 'Selecciona la unidad de aprendizaje';
                  }

                  return null;
                },
              ),
              if (selectedCareerId == null ||
                  selectedPlan == null ||
                  selectedSemester == null) ...[
                const SizedBox(height: 6),
                Text(
                  'Primero selecciona carrera, plan y semestre para cargar las materias.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ] else if (subjects.isEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'No hay materias registradas para esta carrera, plan y semestre.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onSelectDate,
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: Text(
                        dateText,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onSelectTime,
                      icon: const Icon(Icons.schedule_outlined),
                      label: Text(
                        timeText,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: turnoController,
                decoration: const InputDecoration(
                  labelText: 'Turno',
                  prefixIcon: Icon(Icons.wb_sunny_outlined),
                ),
                validator: (value) {
                  if ((value?.trim().length ?? 0) < 3) {
                    return 'Ingresa el turno';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: salonController,
                decoration: const InputDecoration(
                  labelText: 'Salón',
                  prefixIcon: Icon(Icons.meeting_room_outlined),
                  helperText: 'Ejemplo: 2007, 2101, 1111',
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  final salon = value?.trim() ?? '';

                  if (salon.isEmpty) {
                    return 'Ingresa el salón';
                  }

                  if (!RegExp(r'^\d{4}$').hasMatch(salon)) {
                    return 'El salón debe tener 4 dígitos, por ejemplo 2007';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                key: ValueKey('building_$formVersion'),
                initialValue: selectedBuildingId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Edificio',
                  prefixIcon: Icon(Icons.apartment_outlined),
                ),
                items: buildings
                    .map(
                      (building) => DropdownMenuItem<int>(
                        value: building.id,
                        child: Text(
                          building.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onBuildingChanged,
                validator: (value) {
                  if (value == null) {
                    return 'Selecciona un edificio';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: profesorController,
                decoration: const InputDecoration(
                  labelText: 'Profesor evaluador',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if ((value?.trim().length ?? 0) < 3) {
                    return 'Ingresa el nombre del profesor';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: correoController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo del profesor',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';

                  if (!email.contains('@') || !email.contains('.')) {
                    return 'Ingresa un correo válido';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: saving ? null : onSubmit,
                  icon: saving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(isEditing ? Icons.save_outlined : Icons.add),
                  label: Text(
                    saving
                        ? 'Guardando...'
                        : isEditing
                            ? 'Guardar cambios'
                            : 'Crear ETS',
                  ),
                ),
              ),
              if (isEditing) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: saving ? null : onCancel,
                    child: const Text('Cancelar edición'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EtsListCard extends StatelessWidget {
  const _EtsListCard({
    required this.state,
    required this.onRefresh,
    required this.onEdit,
    required this.onDelete,
  });

  final AsyncValue<List<Ets>> state;
  final VoidCallback onRefresh;
  final ValueChanged<Ets> onEdit;
  final ValueChanged<Ets> onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'ETS registrados',
                    style: AppType.serif(size: 24),
                  ),
                ),
                if (state.hasValue && state.value!.isNotEmpty) ...[
                  DsBadge(
                    label: '${state.value!.length} en total',
                    tone: BadgeTone.info,
                    mono: true,
                  ),
                  const SizedBox(width: 4),
                ],
                IconButton(
                  tooltip: 'Actualizar',
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh, size: 18),
                  style: IconButton.styleFrom(
                    side: const BorderSide(color: AppColors.borderSubtle),
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.rsm),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            state.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => const Padding(
                padding: EdgeInsets.all(22),
                child: Center(
                  child: Text('No fue posible cargar los ETS.'),
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(
                      child: Text('No existen ETS registrados.'),
                    ),
                  );
                }

                return Column(
                  children: items
                      .map(
                        (exam) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _AdminEtsItem(
                            exam: exam,
                            onEdit: () {
                              onEdit(exam);
                            },
                            onDelete: () {
                              onDelete(exam);
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

class _AdminEtsItem extends StatelessWidget {
  const _AdminEtsItem({
    required this.exam,
    required this.onEdit,
    required this.onDelete,
  });

  final Ets exam;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final local = exam.fecha.toLocal();
    final day = DateFormat('dd').format(local);
    final month = DateFormat('MMM', 'es_MX').format(local).toUpperCase();
    final shortDate = DateFormat('dd/MM').format(local);
    final hora = DateFormat('HH:mm').format(local);
    final isMorning = exam.turno.toLowerCase().startsWith('mat');
    final accent = isMorning ? AppColors.warning : AppColors.primary;
    // En móviles angostos se oculta el date chip (la fecha pasa a la línea de
    // detalle) para dar espacio al contenido y evitar desbordes.
    final compact = MediaQuery.sizeOf(context).width < 360;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.rmd,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Barra lateral por turno (matutino = ámbar, vespertino = azul).
            Container(width: 4, color: accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date chip (oculto en móviles angostos).
                    if (!compact) ...[
                      Container(
                        width: 46,
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: AppRadii.rsm,
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              day,
                              style: AppType.serif(
                                size: 21,
                                color: AppColors.azul700,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              month,
                              style: AppType.mono(
                                  size: 10.5, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 11),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CareerBadge(code: exam.carrera, size: 26),
                              const SizedBox(width: 9),
                              Flexible(
                                child: Text(
                                  exam.ua,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppType.sans(
                                    size: 15,
                                    weight: FontWeight.w700,
                                    color: AppColors.textStrong,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${compact ? '$shortDate · ' : ''}Plan ${exam.plan} · ${exam.semestre}° semestre · $hora h · ${exam.salon} · ${exam.edificio ?? ''}',
                            style: AppType.mono(
                                size: 12.5, color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 9),
                          Row(
                            children: [
                              DsBadge(
                                label: exam.turno,
                                tone: isMorning
                                    ? BadgeTone.warning
                                    : BadgeTone.info,
                                icon: isMorning
                                    ? Icons.wb_sunny_outlined
                                    : Icons.nights_stay_outlined,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(Icons.person_outline,
                                        size: 14, color: AppColors.textMuted),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        exam.profesor,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppType.sans(
                                          size: 13,
                                          color: AppColors.textBody,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        IconButton(
                          tooltip: 'Editar',
                          onPressed: onEdit,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                              minWidth: 34, minHeight: 34),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          color: AppColors.textFaint,
                          hoverColor: AppColors.primarySoft,
                        ),
                        IconButton(
                          tooltip: 'Eliminar',
                          onPressed: onDelete,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                              minWidth: 34, minHeight: 34),
                          icon: const Icon(Icons.delete_outline, size: 18),
                          color: AppColors.textFaint,
                          hoverColor: AppColors.dangerSoft,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}