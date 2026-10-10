import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_in/models/event.dart';
import 'package:sub_in/models/venue.dart';
import 'package:sub_in/providers/event_provider.dart';
import 'package:sub_in/providers/venue_provider.dart';
import 'package:sub_in/screens/home/home_screen.dart';

Event _event(int id, String title) => Event(
      id: id,
      title: title,
      sport: 'Football',
      startTime: DateTime(2026, 10, 10, 18, 30),
      endTime: DateTime(2026, 10, 10, 20, 30),
      maxPlayers: 10,
      minPlayers: 2,
      currentPlayers: 5,
      isFree: true,
      status: 'open',
      skillLevel: 'intermediate',
      isPublic: true,
      organizerId: 1,
      organizerName: 'Alex',
      createdAt: DateTime(2026, 10, 1),
    );

Venue _venue(int id, String name) => Venue(
      id: id,
      name: name,
      address: '123 Turf St',
      city: 'Austin',
      latitude: 30.26,
      longitude: -97.74,
      sports: const ['Football'],
    );

void main() {
  testWidgets('Home renders both preview sections', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nearByEventsProvider.overrideWith(
            (ref) async => [_event(1, 'Pickup Soccer')],
          ),
          nearbyVenuesProvider.overrideWith(
            (ref) async => [_venue(1, 'Central Turf')],
          ),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    expect(find.text('Events near you'), findsOneWidget);
    expect(find.text('Venues near you'), findsOneWidget);
    expect(find.text('Pickup Soccer'), findsOneWidget);
    expect(find.text('Central Turf'), findsOneWidget);
    expect(find.text('See all'), findsNWidgets(2));
    expect(find.text('Ready to play, Alex?'), findsOneWidget);
    expect(find.text('Create Match'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
  });

  testWidgets('Broken event icon removed from Home AppBar', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    expect(find.byTooltip('Open event details'), findsOneWidget);
    expect(find.byIcon(Icons.event_available), findsOneWidget);
  });
}
