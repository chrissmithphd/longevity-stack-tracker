import 'package:flutter/material.dart';
import '../models/schedule/schedule_models.dart';
import '../services/database_service.dart';
import '../services/task_service.dart';
import '../theme/forest_night_theme.dart';

class SupplementsScreen extends StatefulWidget {
  const SupplementsScreen({super.key});

  @override
  State<SupplementsScreen> createState() => _SupplementsScreenState();
}

class _SupplementsScreenState extends State<SupplementsScreen> {
  final DatabaseService _db = DatabaseService.instance;
  List<Supplement> _supplements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSupplements();
  }

  Future<void> _loadSupplements() async {
    setState(() => _isLoading = true);
    final supplements = await _db.getAllSupplements();
    setState(() {
      _supplements = supplements;
      _isLoading = false;
    });
  }

  Future<void> _deleteSupplement(Supplement supplement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Supplement?'),
        content: Text('Are you sure you want to delete ${supplement.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _db.deleteSupplement(supplement.id);
      await _loadSupplements();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SupplementEditScreen(),
                ),
              );
              if (result == true) {
                await _loadSupplements();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _supplements.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.medical_services_outlined,
                        size: 64,
                        color: ForestNightTheme.secondaryText,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No supplements yet',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: ForestNightTheme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(ForestNightTheme.space4),
                  itemCount: _supplements.length,
                  itemBuilder: (context, index) {
                    final supplement = _supplements[index];
                    return _SupplementCard(
                      supplement: supplement,
                      onEdit: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SupplementEditScreen(
                              supplement: supplement,
                            ),
                          ),
                        );
                        if (result == true) {
                          await _loadSupplements();
                        }
                      },
                      onDelete: () => _deleteSupplement(supplement),
                      onActiveChanged: (bool active) async {
                        final updated = supplement.copyWith(active: active);
                        await _db.updateSupplement(updated);

                        // Regenerate today's tasks to reflect the change
                        final today = DateTime.now();
                        final todayDate = DateTime(today.year, today.month, today.day);
                        await _db.deleteTasksForDate(todayDate);
                        await TaskService().generateDailyTasks(todayDate);

                        await _loadSupplements();
                      },
                    );
                  },
                ),
    );
  }
}

class _SupplementCard extends StatefulWidget {
  final Supplement supplement;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(bool) onActiveChanged;

  const _SupplementCard({
    required this.supplement,
    required this.onEdit,
    required this.onDelete,
    required this.onActiveChanged,
  });

  @override
  State<_SupplementCard> createState() => _SupplementCardState();
}

class _SupplementCardState extends State<_SupplementCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.supplement.active ? 1.0 : 0.5,
      child: Container(
        margin: const EdgeInsets.only(bottom: ForestNightTheme.space3),
        decoration: BoxDecoration(
          color: ForestNightTheme.secondaryBackground,
          borderRadius: BorderRadius.circular(ForestNightTheme.radiusMedium),
          border: Border.all(
            color: widget.supplement.active
                ? ForestNightTheme.tertiaryBackground
                : ForestNightTheme.tertiaryText.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(ForestNightTheme.radiusMedium),
            child: Padding(
              padding: const EdgeInsets.all(ForestNightTheme.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.supplement.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Transform.scale(
                        scale: 0.7,
                        child: Switch(
                          value: widget.supplement.active,
                          onChanged: widget.onActiveChanged,
                          activeColor: ForestNightTheme.active,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        color: ForestNightTheme.secondaryText,
                        onPressed: widget.onEdit,
                        tooltip: 'Edit',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 16),
                        color: ForestNightTheme.tertiaryText,
                        onPressed: widget.onDelete,
                        tooltip: 'Delete',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: ForestNightTheme.tertiaryText,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: ForestNightTheme.space2),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: ForestNightTheme.active.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(ForestNightTheme.radiusSmall),
                        ),
                        child: Text(
                          widget.supplement.dose,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ForestNightTheme.active,
                          ),
                        ),
                      ),
                      if (widget.supplement.foodRequired)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: ForestNightTheme.pending.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(ForestNightTheme.radiusSmall),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.restaurant, size: 12, color: ForestNightTheme.pending),
                              SizedBox(width: 4),
                              Text(
                                'With food',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: ForestNightTheme.pending,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  if (!_isExpanded && widget.supplement.notes.isNotEmpty) ...[
                    const SizedBox(height: ForestNightTheme.space2),
                    Text(
                      widget.supplement.notes,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Expanded details section
          if (_isExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(ForestNightTheme.space4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(ForestNightTheme.radiusMedium),
                  bottomRight: Radius.circular(ForestNightTheme.radiusMedium),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(
                    label: 'ID',
                    value: widget.supplement.id,
                  ),
                  const SizedBox(height: ForestNightTheme.space2),
                  _DetailRow(
                    label: 'Dose',
                    value: widget.supplement.dose,
                  ),
                  const SizedBox(height: ForestNightTheme.space2),
                  _DetailRow(
                    label: 'Timing',
                    value: widget.supplement.timingRule,
                  ),
                  const SizedBox(height: ForestNightTheme.space2),
                  _DetailRow(
                    label: 'Food Required',
                    value: widget.supplement.foodRequired ? 'Yes' : 'No',
                  ),
                  if (widget.supplement.notes.isNotEmpty) ...[
                    const SizedBox(height: ForestNightTheme.space2),
                    Text(
                      'Notes:',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: ForestNightTheme.tertiaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.supplement.notes,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: ForestNightTheme.tertiaryText,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: ForestNightTheme.primaryText,
            ),
          ),
        ),
      ],
    );
  }
}

// Edit Screen (unchanged from before)
class SupplementEditScreen extends StatefulWidget {
  final Supplement? supplement;

  const SupplementEditScreen({super.key, this.supplement});

  @override
  State<SupplementEditScreen> createState() => _SupplementEditScreenState();
}

class _SupplementEditScreenState extends State<SupplementEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _doseController;
  late TextEditingController _timingController;
  late TextEditingController _notesController;
  bool _foodRequired = false;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.supplement?.id ?? '');
    _nameController = TextEditingController(text: widget.supplement?.name ?? '');
    _doseController = TextEditingController(text: widget.supplement?.dose ?? '');
    _timingController = TextEditingController(text: widget.supplement?.timingRule ?? 'with_first_meal');
    _notesController = TextEditingController(text: widget.supplement?.notes ?? '');
    _foodRequired = widget.supplement?.foodRequired ?? false;
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _doseController.dispose();
    _timingController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final supplement = Supplement(
        id: _idController.text.trim(),
        name: _nameController.text.trim(),
        dose: _doseController.text.trim(),
        timingRule: _timingController.text.trim(),
        foodRequired: _foodRequired,
        notes: _notesController.text.trim(),
      );

      final db = DatabaseService.instance;
      if (widget.supplement == null) {
        await db.insertSupplement(supplement);
      } else {
        await db.updateSupplement(supplement);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.supplement == null ? 'Add Supplement' : 'Edit Supplement'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(ForestNightTheme.space4),
          children: [
            TextFormField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'ID',
                hintText: 'e.g., vitd3',
              ),
              enabled: widget.supplement == null,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an ID';
                }
                return null;
              },
            ),
            const SizedBox(height: ForestNightTheme.space4),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g., Vitamin D3',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: ForestNightTheme.space4),
            TextFormField(
              controller: _doseController,
              decoration: const InputDecoration(
                labelText: 'Dose',
                hintText: 'e.g., 2000–4000 IU',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a dose';
                }
                return null;
              },
            ),
            const SizedBox(height: ForestNightTheme.space4),
            TextFormField(
              controller: _timingController,
              decoration: const InputDecoration(
                labelText: 'Timing Rule',
                hintText: 'e.g., with_first_meal',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a timing rule';
                }
                return null;
              },
            ),
            const SizedBox(height: ForestNightTheme.space4),
            SwitchListTile(
              title: const Text('Requires Food'),
              value: _foodRequired,
              onChanged: (value) {
                setState(() {
                  _foodRequired = value;
                });
              },
            ),
            const SizedBox(height: ForestNightTheme.space4),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Optional notes',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
