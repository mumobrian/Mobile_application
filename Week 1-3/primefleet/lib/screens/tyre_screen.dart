import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/database_helper.dart';

// ---------- Models (unchanged) ----------
class Tyre {
  int? id;
  final String tyreId;
  final String position;
  final double treadDepth;
  final double pressure;
  final int mileage;
  final String condition;
  final DateTime lastRotation;
  final String notes;

  Tyre({
    this.id,
    required this.tyreId,
    required this.position,
    required this.treadDepth,
    required this.pressure,
    required this.mileage,
    required this.condition,
    required this.lastRotation,
    required this.notes,
  });

  Map<String, dynamic> toMap(int vehicleId) => {
    'tyre_id': tyreId,
    'position': position,
    'tread_depth': treadDepth,
    'pressure': pressure,
    'mileage': mileage,
    'condition': condition,
    'last_rotation': lastRotation.toIso8601String(),
    'notes': notes,
    'vehicle_id': vehicleId,
  };

  factory Tyre.fromMap(Map<String, dynamic> map) => Tyre(
    id: map['id'],
    tyreId: map['tyre_id'],
    position: map['position'],
    treadDepth: map['tread_depth'],
    pressure: map['pressure'],
    mileage: map['mileage'],
    condition: map['condition'],
    lastRotation: DateTime.parse(map['last_rotation']),
    notes: map['notes'] ?? '',
  );
}

class Vehicle {
  int? id;
  String registration;
  String model;
  int companyId;
  List<Tyre> tyres;
  bool isExpanded = false; // for UI expansion

  Vehicle({
    this.id,
    required this.registration,
    required this.model,
    required this.companyId,
    this.tyres = const [],
    this.isExpanded = false,
  });
}

class Company {
  int? id;
  String name;
  List<Vehicle> vehicles;
  bool isExpanded = false; // for UI expansion

  Company({
    this.id,
    required this.name,
    this.vehicles = const [],
    this.isExpanded = false,
  });
}

// ---------- Main Screen ----------
class TyreScreen extends StatefulWidget {
  const TyreScreen({super.key});

  @override
  State<TyreScreen> createState() => _TyreScreenState();
}

class _TyreScreenState extends State<TyreScreen> {
  List<Company> _companies = [];
  final DatabaseHelper _db = DatabaseHelper();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  Company? _selectedCompanyForAddVehicle;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadCompaniesAndVehicles();
    final prefs = await SharedPreferences.getInstance();
    // Expand last opened company/vehicle if needed (optional)
    setState(() {});
  }

  Future<void> _loadCompaniesAndVehicles() async {
    final companyMaps = await _db.getAllCompanies();
    final companies = <Company>[];
    for (var cMap in companyMaps) {
      final company = Company(id: cMap['id'], name: cMap['name']);
      final vehicleMaps = await _db.getVehiclesByCompany(company.id!);
      final vehicles = <Vehicle>[];
      for (var vMap in vehicleMaps) {
        final tyreMaps = await _db.getTyresByVehicle(vMap['id']);
        final tyres = tyreMaps.map((t) => Tyre.fromMap(t)).toList();
        vehicles.add(Vehicle(
          id: vMap['id'],
          registration: vMap['registration'],
          model: vMap['model'],
          companyId: company.id!,
          tyres: tyres,
        ));
      }
      company.vehicles = vehicles;
      companies.add(company);
    }
    _companies = companies;
  }

  // ---------- Company CRUD ----------
  Future<void> _addCompany() async {
    final name = await _showTextDialog('New Company', 'Enter company name');
    if (name != null && name.isNotEmpty) {
      await _db.insertCompany(name);
      await _loadCompaniesAndVehicles();
      setState(() {});
    }
  }

  Future<void> _updateCompany(Company company) async {
    final newName = await _showTextDialog('Edit Company', company.name, initialValue: company.name);
    if (newName != null && newName.isNotEmpty) {
      await _db.updateCompany(company.id!, newName);
      await _loadCompaniesAndVehicles();
      setState(() {});
    }
  }

  Future<void> _deleteCompany(Company company) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Company', style: TextStyle(color: Colors.black)),
        content: Text('Delete "${company.name}" and all its vehicles & tyres?', style: const TextStyle(color: Colors.black87)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: Colors.black54))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await _db.deleteCompany(company.id!);
      await _loadCompaniesAndVehicles();
      setState(() {});
    }
  }

  // ---------- Vehicle CRUD ----------
  Future<void> _addVehicle(Company company) async {
    final reg = await _showTextDialog(
      'New Vehicle',
      'Registration (KLL NNNL)',
      validator: _validateRegistration,
    );
    if (reg == null) return;
    final model = await _showTextDialog('Vehicle Model', 'Enter model name');
    if (model == null) return;
    await _db.insertVehicle(reg.toUpperCase(), model, company.id!);
    await _loadCompaniesAndVehicles();
    setState(() {});
  }

  Future<void> _updateVehicle(Vehicle vehicle, Company parentCompany) async {
    final newReg = await _showTextDialog(
      'Edit Vehicle',
      'Registration',
      initialValue: vehicle.registration,
      validator: _validateRegistration,
    );
    if (newReg == null) return;
    final newModel = await _showTextDialog('Edit Vehicle Model', 'Model', initialValue: vehicle.model);
    if (newModel == null) return;
    await _db.updateVehicle(vehicle.id!, newReg.toUpperCase(), newModel);
    await _loadCompaniesAndVehicles();
    setState(() {});
  }

  Future<void> _deleteVehicle(Vehicle vehicle, Company parentCompany) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Vehicle', style: TextStyle(color: Colors.black)),
        content: Text('Delete "${vehicle.registration}" and all its tyres?', style: const TextStyle(color: Colors.black87)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: Colors.black54))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await _db.deleteVehicle(vehicle.id!);
      await _loadCompaniesAndVehicles();
      setState(() {});
    }
  }

  // ---------- Tyre CRUD ----------
  Future<void> _addTyre(Vehicle vehicle, Company parentCompany) async {
    final tyre = await showDialog<Tyre>(
      context: context,
      builder: (ctx) => _AddTyreDialog(
        vehicleMileage: vehicle.tyres.isNotEmpty ? vehicle.tyres.first.mileage : 0,
      ),
    );
    if (tyre != null) {
      await _db.insertTyre(tyre.toMap(vehicle.id!));
      await _loadCompaniesAndVehicles();
      setState(() {});
    }
  }

  Future<void> _updateTyre(Tyre tyre, Vehicle parentVehicle) async {
    final updated = await showDialog<Tyre>(
      context: context,
      builder: (ctx) => _EditTyreDialog(tyre: tyre),
    );
    if (updated != null) {
      await _db.updateTyre(tyre.id!, updated.toMap(parentVehicle.id!));
      await _loadCompaniesAndVehicles();
      setState(() {});
    }
  }

  Future<void> _deleteTyre(Tyre tyre, Vehicle parentVehicle) async {
    await _db.deleteTyre(tyre.id!);
    await _loadCompaniesAndVehicles();
    setState(() {});
  }

  // ---------- Search ----------
  Future<void> _performSearch(String keyword) async {
    if (keyword.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }
    final results = await _db.searchTyres(keyword);
    setState(() {
      _isSearching = true;
      _searchResults = results;
    });
  }

  // ---------- Helpers ----------
  String? _validateRegistration(String value) {
    final upper = value.trim().toUpperCase();
    final regExp = RegExp(r'^K[A-Z]{2}\s\d{3}[A-Z]$');
    if (!regExp.hasMatch(upper)) {
      return 'Format: KLL NNNL (e.g., KAB 123C)';
    }
    return null;
  }

  Future<String?> _showTextDialog(String title, String hint,
      {String? initialValue, String? Function(String)? validator}) {
    final controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(color: Colors.black)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black45),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black38),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF0D47A1)),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          style: const TextStyle(color: Colors.black),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.black54))),
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
            child: const Text('Save', style: TextStyle(color: Color(0xFF0D47A1))),
          ),
        ],
      ),
    );
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

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search tyres...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: _performSearch,
        )
            : const Text('Tyre Management', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D47A1),
        actions: [
          if (!_isSearching)
            IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () => setState(() => _isSearching = true)),
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                  _searchResults = [];
                });
              },
            ),
          PopupMenuButton<String>(
            onSelected: (value) => _addCompany(),
            icon: const Icon(Icons.add_business, color: Colors.white),
            itemBuilder: (ctx) => const [
              PopupMenuItem(value: 'add_company', child: Text('Add Company', style: TextStyle(color: Colors.black))),
            ],
          ),
        ],
      ),
      body: _isSearching ? _buildSearchResults() : _buildExpandableList(),
      floatingActionButton: !_isSearching
          ? FloatingActionButton.extended(
        onPressed: () {
          // Add tyre to first vehicle? Better to show a dialog to select vehicle first.
          if (_companies.isEmpty) {
            _showSnack('Add a company and vehicle first');
            return;
          }
          // Find first vehicle with tyres or just any vehicle
          Vehicle? targetVehicle;
          for (var c in _companies) {
            if (c.vehicles.isNotEmpty) {
              targetVehicle = c.vehicles.first;
              break;
            }
          }
          if (targetVehicle == null) {
            _showSnack('No vehicles found. Add a vehicle first.');
            return;
          }
          _addTyre(targetVehicle, _companies.firstWhere((c) => c.id == targetVehicle!.companyId));
        },
        backgroundColor: const Color(0xFF0D47A1),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Tyre', style: TextStyle(color: Colors.white)),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildExpandableList() {
    if (_companies.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business, size: 64, color: Colors.black38),
            SizedBox(height: 16),
            Text('No companies yet.\nTap the + icon to add one.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black87)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _companies.length,
      itemBuilder: (ctx, companyIdx) {
        final company = _companies[companyIdx];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ExpansionPanelList(
            elevation: 0,
            expandedHeaderPadding: EdgeInsets.zero,
            expansionCallback: (panelIndex, isExpanded) {
              setState(() {
                company.isExpanded = !company.isExpanded;
              });
            },
            children: [
              ExpansionPanel(
                isExpanded: company.isExpanded,
                headerBuilder: (context, isExpanded) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.apartment, color: Color(0xFF0D47A1)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            company.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20, color: Colors.black54),
                          onPressed: () => _updateCompany(company),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                          onPressed: () => _deleteCompany(company),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_box, size: 20, color: Colors.green),
                          onPressed: () => _addVehicle(company),
                        ),
                      ],
                    ),
                  );
                },
                body: company.vehicles.isEmpty
                    ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text('No vehicles. Tap + to add.', style: TextStyle(color: Colors.black54))),
                )
                    : Column(
                  children: company.vehicles.map((vehicle) => _buildVehicleTile(vehicle, company)).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVehicleTile(Vehicle vehicle, Company parentCompany) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionPanelList(
        elevation: 0,
        expandedHeaderPadding: EdgeInsets.zero,
        expansionCallback: (panelIndex, isExpanded) {
          setState(() {
            vehicle.isExpanded = !vehicle.isExpanded;
          });
        },
        children: [
          ExpansionPanel(
            isExpanded: vehicle.isExpanded,
            headerBuilder: (context, isExpanded) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.local_shipping, color: Color(0xFF0D47A1)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(vehicle.registration, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                          Text(vehicle.model, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18, color: Colors.black54),
                      onPressed: () => _updateVehicle(vehicle, parentCompany),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                      onPressed: () => _deleteVehicle(vehicle, parentCompany),
                    ),
                    IconButton(
                      icon: const Icon(Icons.tire_repair, size: 18, color: Colors.green),
                      onPressed: () => _addTyre(vehicle, parentCompany),
                    ),
                  ],
                ),
              );
            },
            body: vehicle.tyres.isEmpty
                ? const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: Text('No tyres. Tap + to add.', style: TextStyle(color: Colors.black54))),
            )
                : Column(
              children: vehicle.tyres.map((tyre) => _buildTyreTile(tyre, vehicle)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTyreTile(Tyre tyre, Vehicle parentVehicle) {
    final condition = _getCondition(tyre.treadDepth, tyre.pressure);
    final color = _getConditionColor(condition);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.tire_repair, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tyre.tyreId, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                    Text(tyre.position, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Text(condition, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 18, color: Colors.black54),
                onPressed: () => _updateTyre(tyre, parentVehicle),
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                onPressed: () => _deleteTyre(tyre, parentVehicle),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _infoChip(Icons.straighten, '${tyre.treadDepth} mm'),
              _infoChip(Icons.air, '${tyre.pressure} psi'),
              _infoChip(Icons.speed, '${tyre.mileage} km'),
              _infoChip(Icons.location_on, tyre.notes),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ((tyre.treadDepth - 1.6) / (8.0 - 1.6)).clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              color: color,
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.black54),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty && _searchController.text.isNotEmpty) {
      return const Center(child: Text('No tyres found', style: TextStyle(color: Colors.black87)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _searchResults.length,
      itemBuilder: (ctx, idx) {
        final map = _searchResults[idx];
        final tyre = Tyre.fromMap(map);
        final condition = _getCondition(tyre.treadDepth, tyre.pressure);
        final color = _getConditionColor(condition);
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(Icons.tire_repair, color: color),
            title: Text('${tyre.tyreId} - ${map['registration']}', style: const TextStyle(color: Colors.black)),
            subtitle: Text('${tyre.position} | ${tyre.treadDepth}mm | ${map['company_name']}', style: const TextStyle(color: Colors.black54)),
            trailing: Text(condition, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }
}

// ---------- Add Tyre Dialog (same as before) ----------
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
      title: const Text('Add New Tyre', style: TextStyle(color: Colors.black)),
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
                  leading: const Icon(Icons.calendar_today, color: Colors.black54),
                  title: Text(
                    _lastRot == null ? 'Last Rotation Date' : 'Last Rotation: ${_lastRot!.toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(color: Colors.black87),
                  ),
                  trailing: const Icon(Icons.arrow_drop_down, color: Colors.black54),
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
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.black54))),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate() && _lastRot != null) {
              final tyre = Tyre(
                tyreId: _idCtrl.text,
                position: _positionCtrl.text,
                treadDepth: double.parse(_treadCtrl.text),
                pressure: double.parse(_pressureCtrl.text),
                mileage: widget.vehicleMileage,
                condition: 'Good',
                lastRotation: _lastRot!,
                notes: _notesCtrl.text,
              );
              Navigator.pop(context, tyre);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1)),
          child: const Text('Add', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController c, String label, IconData icon,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black87),
          prefixIcon: Icon(icon, color: Colors.black54),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF0D47A1)),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }
}

// ---------- Edit Tyre Dialog (same as before) ----------
class _EditTyreDialog extends StatefulWidget {
  final Tyre tyre;
  const _EditTyreDialog({required this.tyre});

  @override
  State<_EditTyreDialog> createState() => _EditTyreDialogState();
}

class _EditTyreDialogState extends State<_EditTyreDialog> {
  late final TextEditingController _idCtrl;
  late final TextEditingController _positionCtrl;
  late final TextEditingController _treadCtrl;
  late final TextEditingController _pressureCtrl;
  late final TextEditingController _notesCtrl;
  late DateTime _lastRot;

  String _getCondition(double treadDepth, double pressure) {
    if (treadDepth < 2.0 || pressure < 30) return 'Critical';
    if (treadDepth < 3.0 || pressure < 35) return 'Warning';
    return 'Good';
  }

  @override
  void initState() {
    super.initState();
    _idCtrl = TextEditingController(text: widget.tyre.tyreId);
    _positionCtrl = TextEditingController(text: widget.tyre.position);
    _treadCtrl = TextEditingController(text: widget.tyre.treadDepth.toString());
    _pressureCtrl = TextEditingController(text: widget.tyre.pressure.toString());
    _notesCtrl = TextEditingController(text: widget.tyre.notes);
    _lastRot = widget.tyre.lastRotation;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Tyre', style: TextStyle(color: Colors.black)),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(_idCtrl, 'Tyre ID', Icons.tag),
              const SizedBox(height: 12),
              _buildTextField(_positionCtrl, 'Position', Icons.settings),
              const SizedBox(height: 12),
              _buildTextField(_treadCtrl, 'Tread Depth (mm)', Icons.straighten, isNumber: true),
              const SizedBox(height: 12),
              _buildTextField(_pressureCtrl, 'Pressure (PSI)', Icons.air, isNumber: true),
              const SizedBox(height: 12),
              _buildTextField(_notesCtrl, 'Notes', Icons.note),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.black54),
                title: Text('Last Rotation: ${_lastRot.toLocal().toString().split(' ')[0]}', style: const TextStyle(color: Colors.black87)),
                trailing: const Icon(Icons.edit, color: Colors.black54),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _lastRot,
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
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.black54))),
        ElevatedButton(
          onPressed: () {
            final tread = double.parse(_treadCtrl.text);
            final pressure = double.parse(_pressureCtrl.text);
            final tyre = Tyre(
              id: widget.tyre.id,
              tyreId: _idCtrl.text,
              position: _positionCtrl.text,
              treadDepth: tread,
              pressure: pressure,
              mileage: widget.tyre.mileage,
              condition: _getCondition(tread, pressure),
              lastRotation: _lastRot,
              notes: _notesCtrl.text,
            );
            Navigator.pop(context, tyre);
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1)),
          child: const Text('Save', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController c, String label, IconData icon,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black87),
          prefixIcon: Icon(icon, color: Colors.black54),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF0D47A1)),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}