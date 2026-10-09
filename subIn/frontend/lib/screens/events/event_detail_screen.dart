import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import 'package:sub_in/config/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sub_in/models/event.dart';
import 'package:sub_in/models/participant.dart';
import 'package:sub_in/services/event_service.dart';
import 'package:sub_in/providers/event_provider.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final int eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  Event? _event;
  List<Participant> _participants = [];
  bool _isLoading = true;
  bool _isJoining = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEventDetails(widget.eventId); 
  }

  Future<void> _loadEventDetails(int eventId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final eventService = ref.read(eventServiceProvider);
      final data = await eventService.getEventDetails(widget.eventId);
      
      setState(() {
        _event = data['event'] as Event;
        _participants = data['participants'] as List<Participant>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _joinEvent() async {
    if (_event == null) return;

    setState(() => _isJoining = true);

    try {
      final eventService = ref.read(eventServiceProvider);
      final updatedEvent = await eventService.joinEvent(widget.eventId);
      
      setState(() {
        _event = updatedEvent;
        _isJoining = false;
      });

      // Refresh the participants list
      await _loadEventDetails(widget.eventId);

      // Invalidate the nearby events provider to refresh the list
      ref.invalidate(nearByEventsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully joined the event!'),
          backgroundColor: AppTheme.success,
        ),
      );
    } catch (e) {
      setState(() => _isJoining = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
              const SizedBox(height: 16),
              Text('Error: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _loadEventDetails(widget.eventId),
                
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final event = _event!;
    final sportColor = AppTheme.sportColors[event.sport] ?? AppTheme.primaryColor;
    final isFull = event.spotsRemaining == 0 || event.status == 'full';
    final isOrganizer = event.organizerId == 1; // TODO: Get current user ID

    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
        backgroundColor: sportColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sport & Status Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: sportColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    event.sport.toUpperCase(),
                    style: TextStyle(
                      color: sportColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                if (isFull)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'FULL',
                      style: TextStyle(
                        color: AppTheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Location Map
            _buildLocationMap(event),
            const SizedBox(height: 20),

            // Event Info Card
            _buildInfoCard(event),
            const SizedBox(height: 20),

            // Organizer Info
            _buildOrganizerCard(event),
            const SizedBox(height: 20),

            // Participants List
            _buildParticipantsSection(),
            const SizedBox(height: 100), // Space for bottom button
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(event, isFull, isOrganizer),
    );
  }

  Widget _buildLocationMap(Event event) {
    if (event.latitude == null || event.longitude == null) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Text('Location not available')),
      );
    }

    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
          

// Inside your build method:
FlutterMap(
  options: MapOptions(
    initialCenter: LatLng(event.latitude!, event.longitude!),
    initialZoom: 15.0,
    interactionOptions: const InteractionOptions(
      flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag, // Disable scroll if needed
    ),
  ),
  children: [
    // 1. The Map Tiles (OpenStreetMap is free)
    TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.gameon.app',
    ),
    
    // 2. The Marker
    MarkerLayer(
      markers: [
        Marker(
          point: LatLng(event.latitude!, event.longitude!),
          width: 40,
          height: 40,
          child: const Icon(
            Icons.location_pin,
            color: Colors.red,
            size: 40,
          ),
        ),
      ],
    ),
  ],
),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.customLocation ?? 'Custom Location',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (event.distanceKm != null)
                      Text(
                        '${event.distanceKm!.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget _buildInfoCard(Event event) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date & Time
          _buildInfoRow(
            Icons.calendar_today,
            DateFormat('EEEE, MMMM d, yyyy').format(event.startTime),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.access_time,
            '${DateFormat('h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.people,
            '${event.currentPlayers}/${event.maxPlayers} players (${event.spotsRemaining} spots left)',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.signal_cellular_alt,
            'Skill Level: ${event.skillLevel.toUpperCase()}',
          ),
          if (!event.isFree && event.costPerPlayer != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.attach_money,
              '\$${event.costPerPlayer!.toStringAsFixed(2)} per player',
            ),
          ],
          if (event.description != null && event.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(event.description!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 15)),
        ),
      ],
    );
  }

  Widget _buildOrganizerCard(Event event) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
            child: Text(
              event.organizerName[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Organizer',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
                Text(
                  event.organizerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              // TODO: Open chat with organizer
            },
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Participants (${_participants.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_participants.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'No participants yet. Be the first to join!',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            ),
          )
        else
          ..._participants.map((participant) => _buildParticipantTile(participant)),
      ],
    );
  }

  Widget _buildParticipantTile(Participant participant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
            child: Text(
              participant.fullName[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.fullName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  participant.skillLevel.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            DateFormat('MMM d').format(participant.joinedAt),
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(Event event, bool isFull, bool isOrganizer) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Directions button
          if (event.latitude != null && event.longitude != null)
            IconButton.outlined(
              onPressed: () async {
                final url = 'https://www.google.com/maps/dir/?api=1&destination=${event.latitude},${event.longitude}';
                await launchUrl(Uri.parse(url));
              },
              icon: const Icon(Icons.directions),
            ),
          const SizedBox(width: 12),
          // Join button
          Expanded(
            child: ElevatedButton(
              onPressed: isFull || isOrganizer || _isJoining
                  ? null
                  : _joinEvent,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isJoining
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isFull
                          ? 'Event Full'
                          : isOrganizer
                              ? 'You are the Organizer'
                              : 'Join Event',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}