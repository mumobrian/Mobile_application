import 'package:flutter/material.dart';

// ---------- Data Models ----------
class Tyre {
  final String id;
  final String position;    // e.g., Front Left, Rear Right
  final double treadDepth;  // mm
  final double pressure;    // PSI
  final int mileage;        // km when fitted
  final String condition;   // Good, Warning, Critical
  final DateTime lastRotation;
  final String notes;

  Tyre({
    required this.id,
    required this.position,
    required this.treadDepth,
    required this.pressure,
    required this.mileage,
    required this.condition,
    required this.lastRotation,
    required this.notes,
  });
}

class Vehicle {
  final String registration; // Format: KLL NNNL (e.g., KAB 123C)
  final String model;
  final List<Tyre> tyres;

  Vehicle({
    required this.registration,
    required this.model,
    this.tyres = const [],
  });
}

class Company {
  final String name;
  final List<Vehicle> vehicles;

  Company({required this.name, this.vehicles = const []});
}

// ---------- Main Screen ----------
class TyreScreen extends StatefulWidget {
  const TyreScreen({super.key});

  @override
  State<TyreScreen> createState() => _TyreScreenState();
}

class _TyreScreenState extends State<TyreScreen> {
  List<Company> _companies = [];
  Company? _selectedCompany;
  Vehicle? _selectedVehicle;

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    final catTyres = [
      Tyre(
        id: 'TY-CAT-01',
        position: 'Front Left',
        treadDepth: 7.2,
        pressure: 38,
        mileage: 45200,
        condition: 'Good',
        lastRotation: DateTime(2026, 5, 10),
        notes: 'Depot A - Bay 2',
      ),
      Tyre(
        id: 'TY-CAT-02',
        position: 'Front Right',
        treadDepth: 7.0,
        pressure: 37,
        mileage: 45200,
        condition: 'Good',
        lastRotation: DateTime(2026, 5, 10),
        notes: 'Depot A - Bay 2',
      ),
    ];

    final superMetroTyres = [
      Tyre(
        id: 'TY-SM-01',
        position: 'Rear Left',
        treadDepth: 2.8,
        pressure: 32,
        mileage: 81200,
        condition: 'Warning',
        lastRotation: DateTime(2026, 3, 15),
        notes: 'Highway depot',
      ),
    ];

    _companies = [
      Company(
        name: 'CAT',
        vehicles: [
          Vehicle(
            registration: 'KAB 123C',
            model: 'CAT 740',
            tyres: catTyres,
          ),
          Vehicle(
            registration: 'KCD 456B',
            model: 'CAT 745',
            tyres: [],
          ),
        ],
      ),
      Company(
        name: 'SUPER METRO',
        vehicles: [
          Vehicle(
            registration: 'KEF 789D',
            model: 'Scania R450',
            tyres: superMetroTyres,
          ),
        ],
      ),
    ];

    if (_companies.isNotEmpty) {
      _selectedCompany = _companies[0];
      if (_selectedCompany!.vehicles.isNotEmpty) {
        _selectedVehicle = _selectedCompany!.vehicles[0];
      }
    }
  }

  void _addNewCompany() async {
    final name = await _showTextDialog('New Company', 'Enter company name');
    if (name != null && name.isNotEmpty) {
      setState(() {
        _companies.add(Company(name: name));
      });
    }
  }

  void _addNewVehicle() async {
    if (_selectedCompany == null) {
      _showSnack('Select a company first');
      return;
    }
    final reg = await _showTextDialog(
      'New Vehicle',
      'Registration (format: KLL NNNL)',
      validator: _validateRegistration,
    );
    if (reg == null) return;
    final model = await _showTextDialog('Vehicle Model', 'Enter model name');
    if (model == null) return;
    setState(() {
      final newVehicle = Vehicle(registration: reg.toUpperCase(), model: model);
      _selectedCompany!.vehicles.add(newVehicle);
      _selectedVehicle = newVehicle;
    });
  }

  String? _validateRegistration(String value) {
    final upper = value.trim().toUpperCase();
    final regExp = RegExp(r'^K[A-Z]{2}\s\d{3}[A-Z]$');
    if (!regExp.hasMatch(upper)) {
      return 'Format: KLL NNNL (e.g., KAB 123C)';
    }
    return null;
  }

  Future<String?> _showTextDialog(String title, String hint, {String? Function(String)? validator}) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final value = controller.text.trim();
              if (validator != null) {
                final error = validator(value);
                if (error != null) {
                  _showSnack(error);
                  return;
                }
              }
              if (value.isNotEmpty) Navigator.pop(ctx, value);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addNewTyre() async {
    if (_selectedVehicle == null) {
      _showSnack('Select a vehicle first');
      return;
    }
    final tyre = await showDialog<Tyre>(
      context: context,
      builder: (ctx) => _AddTyreDialog(
        vehicleMileage: _selectedVehicle!.tyres.isNotEmpty
            ? _selectedVehicle!.tyres.first.mileage
            : 0,
      ),
    );
    if (tyre != null) {
      setState(() {
        _selectedVehicle!.tyres.add(tyre);
      });
      _showSnack('Tyre ${tyre.id} added');
    }
  }

  void _deleteTyre(Tyre tyre) {
    setState(() {
      _selectedVehicle!.tyres.remove(tyre);
    });
    _showSnack('Tyre deleted');
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _getCondition(double treadDepth, double pressure) {
    if (treadDepth < 2.0 || pressure < 30) return 'Critical';
    if (treadDepth < 3.0 || pressure < 35) return 'Warning';
    return 'Good';
  }

  Color _getConditionColor(String condition) {
    switch (condition) {
      case 'Good': return Colors.green;
      case 'Warning': return Colors.orange;
      default: return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tyre Management'),
        backgroundColor: const Color(0xFFFFFFFF),
        actions: [
          IconButton(
            icon: const Icon(Icons.business),
            onPressed: _addNewCompany,
            tooltip: 'Add Company',
          ),
          IconButton(
            icon: const Icon(Icons.fire_truck_sharp),
            onPressed: _addNewVehicle,
            tooltip: 'Add Vehicle',
          ),
        ],
      ),
      body: Column(
        children: [
          // Company & Vehicle selectors
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<Company>(
                    value: _selectedCompany,
                    decoration: const InputDecoration(
                      labelText: 'Company',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.apartment),
                    ),
                    items: _companies.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                    onChanged: (company) {
                      setState(() {
                        _selectedCompany = company;
                        _selectedVehicle = company!.vehicles.isNotEmpty ? company.vehicles[0] : null;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<Vehicle>(
                    value: _selectedVehicle,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_shipping),
                    ),
                    items: _selectedCompany?.vehicles.map((v) => DropdownMenuItem(
                      value: v,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(v.registration),
                          Text(v.model, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    )).toList() ?? [],
                    onChanged: (vehicle) => setState(() => _selectedVehicle = vehicle),
                  ),
                ),
              ],
            ),
          ),
          // Tyre list
          Expanded(
            child: _selectedVehicle == null
                ? const Center(child: Text('Select a company and vehicle'))
                : _selectedVehicle!.tyres.isEmpty
                ? const Center(child: Text('No tyres. Tap + to add.'))
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _selectedVehicle!.tyres.length,
              itemBuilder: (ctx, idx) {
                final tyre = _selectedVehicle!.tyres[idx];
                final condition = _getCondition(tyre.treadDepth, tyre.pressure);
                final color = _getConditionColor(condition);
                return Dismissible(
                  key: Key(tyre.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _deleteTyre(tyre),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.grey.shade50],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(Icons.tire_repair, color: color),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(tyre.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text(tyre.position, style: TextStyle(color: Colors.grey.shade600)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(condition, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                _infoChip(Icons.straighten, '${tyre.treadDepth} mm'),
                                _infoChip(Icons.air, '${tyre.pressure} psi'),
                                _infoChip(Icons.speed, '${tyre.mileage} km'),
                                _infoChip(Icons.location_on, tyre.notes),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: ((tyre.treadDepth - 1.6) / (8.0 - 1.6)).clamp(0.0, 1.0),
                                backgroundColor: Colors.grey.shade200,
                                color: color,
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewTyre,
        backgroundColor: const Color(0xFF0D47A1),
        icon: const Icon(Icons.add),
        label: const Text('Add Tyre'),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

// ---------- Add Tyre Dialog (Scrollable & Keyboard Safe) ----------
class _AddTyreDialog extends StatefulWidget {
  final int vehicleMileage;
  const _AddTyreDialog({required this.vehicleMileage});

  @override
  State<_AddTyreDialog> createState() => _AddTyreDialogState();
}

class _AddTyreDialogState extends State<_AddTyreDialog> {
  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _positionCtrl = TextEditingController();
  final _treadCtrl = TextEditingController();
  final _pressureCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime? _lastRot;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Tyre'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(_idCtrl, 'Tyre ID', Icons.tag),
                const SizedBox(height: 12),
                _buildTextField(_positionCtrl, 'Position (e.g., Front Left)', Icons.settings),
                const SizedBox(height: 12),
                _buildTextField(_treadCtrl, 'Tread Depth (mm)', Icons.straighten, isNumber: true),
                const SizedBox(height: 12),
                _buildTextField(_pressureCtrl, 'Pressure (PSI)', Icons.air, isNumber: true),
                const SizedBox(height: 12),
                _buildTextField(_notesCtrl, 'Location / Notes', Icons.note),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(_lastRot == null
                      ? 'Last Rotation Date'
                      : 'Last Rotation: ${_lastRot!.toLocal().toString().split(' ')[0]}'),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2024),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => _lastRot = picked);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate() && _lastRot != null) {
              final tyre = Tyre(
                id: _idCtrl.text,
                position: _positionCtrl.text,
                treadDepth: double.parse(_treadCtrl.text),
                pressure: double.parse(_pressureCtrl.text),
                mileage: widget.vehicleMileage,
                condition: 'Good',
                lastRotation: _lastRot!,
                notes: _notesCtrl.text,
              );
              Navigator.pop(context, tyre);
            } else if (_lastRot == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select last rotation date')),
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1)),
          child: const Text('Add'),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
    );
  }
}