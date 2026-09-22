import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:sub_in/config/app_theme.dart';
import 'package:sub_in/services/venue_service.dart';

class CreateVenueSheet extends ConsumerStatefulWidget {
  final LatLng initialLocation;
  const CreateVenueSheet({super.key, required this.initialLocation});
  @override
  ConsumerState<CreateVenueSheet> createState() => _CreateVenueSheetState();
}

class _CreateVenueSheetState extends ConsumerState<CreateVenueSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _address;
  late final TextEditingController _city;
  late final TextEditingController _lat;
  late final TextEditingController _lng;
  final Set<String> _sports = {'Football'};
  bool _isFree = true;
  bool _saving = false;
  String? _error;

  static const _allSports = ['Football', 'Cricket', 'Basketball', 'Tennis', 'Badminton'];

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _address = TextEditingController();
    _city = TextEditingController();
    _lat = TextEditingController(text: widget.initialLocation.latitude.toString());
    _lng = TextEditingController(text: widget.initialLocation.longitude.toString());
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _city.dispose();
    _lat.dispose();
    _lng.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textMuted,
                    borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 12),
              Text('Add venue here', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              const Text('POST /venues/ — appears after refresh',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name *'),
                validator: (v) => (v == null || v.trim().length < 3) ? 'Min 3 chars' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _address,
                decoration: const InputDecoration(labelText: 'Address *'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _city,
                decoration: const InputDecoration(labelText: 'City *'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _lat,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      decoration: const InputDecoration(labelText: 'Latitude *'),
                      validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lng,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      decoration: const InputDecoration(labelText: 'Longitude *'),
                      validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Sports *', style: TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _allSports.map((s) {
                  final selected = _sports.contains(s);
                  return FilterChip(
                    selected: selected,
                    label: Text(s),
                    onSelected: (_) => setState(() {
                      if (selected) {
                        if (_sports.length > 1) _sports.remove(s);
                      } else {
                        _sports.add(s);
                      }
                    }),
                  );
                }).toList(),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Free venue'),
                value: _isFree,
                onChanged: (v) => setState(() => _isFree = v),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(_error!, style: const TextStyle(color: AppTheme.error)),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Create venue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _saving = true; _error = null; });
    try {
      final service = ref.read(venueServiceProvider);
      await service.createVenue(
        name: _name.text.trim(),
        address: _address.text.trim(),
        city: _city.text.trim(),
        latitude: double.parse(_lat.text.trim()),
        longitude: double.parse(_lng.text.trim()),
        sports: _sports.toList(),
        isFree: _isFree,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ref.read(venueRefreshProvider.notifier).state++;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Venue created')),
      );
    } catch (e) {
      setState(() { _saving = false; _error = 'Failed: $e'; });
    }
  }
}
