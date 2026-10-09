// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:sub_in/config/app_theme.dart';
import 'package:sub_in/config/app_constants.dart';
import 'package:sub_in/models/venue.dart';
import 'package:sub_in/providers/event_provider.dart';
import 'package:sub_in/services/api_service.dart';
import 'package:sub_in/providers/location_provider.dart';
import 'package:sub_in/services/event_service.dart';
import 'package:sub_in/widgets/venue_selector.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxPlayersController = TextEditingController(text: '10');
  final _costController = TextEditingController();

  Venue? _selectedVenue;
  String? _selectedSport;
  String _selectedSkillLevel = 'Intermediate';
  bool _isFree = true;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
        backgroundColor: AppTheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              _buildSectionTitle('Event Details'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Event Title',
                  hintText: 'e.g., Weekend Football Match',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Tell players about your event',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Sport Selection
              _buildSectionTitle('Sport'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.sports.map((sport) {
                  final isSelected = _selectedSport == sport;
                  final color = AppTheme.sportColors[sport] ?? AppTheme.primaryColor;
                  return ChoiceChip(
                    label: Text(sport),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedSport = sport),
                    selectedColor: color.withOpacity(0.2),
                    backgroundColor: AppTheme.cardBackground,
                    labelStyle: TextStyle(
                      color: isSelected ? color : AppTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Location
         _buildSectionTitle('Location'),
        const SizedBox(height: 12),
        VenueSelector(
          onVenueSelected: (venue) {
            setState(() => _selectedVenue = venue);
          },
        ),
              const SizedBox(height: 24),

              // Date & Time
              _buildSectionTitle('When'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDateTimePicker(
                      label: 'Start Date & Time',
                      value: _startDate,
                      onPicked: (date) => setState(() => _startDate = date),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDateTimePicker(
                      label: 'End Date & Time',
                      value: _endDate,
                      onPicked: (date) => setState(() => _endDate = date),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Players
              _buildSectionTitle('Players'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _maxPlayersController,
                decoration: const InputDecoration(
                  labelText: 'Max Players',
                  prefixIcon: Icon(Icons.people),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  final num = int.tryParse(value);
                  if (num == null || num < 2 || num > 100) {
                    return 'Must be between 2 and 100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Skill Level
              _buildSectionTitle('Skill Level'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedSkillLevel,
                decoration: const InputDecoration(
                  labelText: 'Skill Level',
                ),
                items: AppConstants.skillLevels.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Text(level),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedSkillLevel = value);
                  }
                },
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Cost'),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Free Event'),
                value: _isFree,
                onChanged: (value) => setState(() => _isFree = value),
                activeColor: AppTheme.primaryColor,
              ),
              if (!_isFree) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _costController,
                  decoration: const InputDecoration(
                    labelText: 'Cost per Player',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Create Event',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildDateTimePicker({
    required String label,
    required DateTime? value,
    required Function(DateTime) onPicked,
  }) {
    return InkWell(
      onTap: () async {
        final date = await DatePicker.showDateTimePicker(
          context,
          showTitleActions: true,
          minTime: DateTime.now(),
          currentTime: value ?? DateTime.now(),
        );
        if (date != null) {
          onPicked(date);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value != null
                  ? DateFormat('MMM dd, yyyy HH:mm').format(value)
                  : 'Select date & time',
              style: TextStyle(
                fontSize: 14,
                color: value != null ? AppTheme.textPrimary : AppTheme.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a sport')),
      );
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end times')),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final eventService = ref.read(eventServiceProvider);

      // Fall back to GPS coords when no venue picked / map-picked virtual venue.
      // Backend requires venue_id OR (latitude AND longitude).
      final gps = ref.read(locationProvider).value;
      final venueLat = _selectedVenue?.latitude;
      final venueLon = _selectedVenue?.longitude;
      final latitude = venueLat ?? gps?.latitude;
      final longitude = venueLon ?? gps?.longitude;

      if ((_selectedVenue == null ||
              _selectedVenue!.id <= 0) &&
          (latitude == null || longitude == null)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a location')),
          );
          setState(() => _isLoading = false);
        }
        return;
      }

      final newEvent = await eventService.createEvent({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text.trim(),
        'sport': _selectedSport!.toLowerCase().replaceAll(' ', '_'),
        'venue_id':
            _selectedVenue != null && _selectedVenue!.id > 0 ? _selectedVenue!.id : null,
        // Backend needs a string here; venue name works for both real + virtual venues.
        'custom_location': _selectedVenue?.name ??
            (_locationController.text.trim().isEmpty
                ? null
                : _locationController.text.trim()),
        'latitude': latitude,
        'longitude': longitude,
        'start_time': _startDate!.toUtc().toIso8601String(),
        'end_time': _endDate!.toUtc().toIso8601String(),
        'max_players': int.parse(_maxPlayersController.text),
        'min_players': 2,
        'is_free': _isFree,
        'cost_per_player': _isFree ? null : double.tryParse(_costController.text),
        'skill_level': _selectedSkillLevel.toLowerCase(),
        'is_public': true,
      });

      if (!mounted) return;
      ref.invalidate(nearByEventsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully!')),
      );
      // go_router screen was pushed via context.push — pop once via go_router.
      context.pop(newEvent);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxPlayersController.dispose();
    _costController.dispose();
    super.dispose();
  }
}