import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_in/models/event.dart';
import 'package:sub_in/models/venue.dart';
import 'package:sub_in/providers/event_provider.dart';
import 'package:sub_in/providers/venue_provider.dart';
import 'package:sub_in/screens/home/home_search_radius_provider.dart';
import 'package:sub_in/screens/home/home_screen.dart';
import 'package:sub_in/screens/home/widgets/home_header.dart';

Event _event(int id, String title, [String sport = 'Football']) => Event(
      id: id,
      title: title,
      sport: sport,
      customLocation: 'Zilker Park',
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

Venue _venue(int id, String name, [List<String> sports = const ['Football']]) =>
    Venue(
      id: id,
      name: name,
      address: '123 Turf St',
      city: 'Austin',
      latitude: 30.26,
      longitude: -97.74,
      sports: sports,
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
    expect(find.text('Host an Event'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
  });

  testWidgets('Broken event icon removed from Home AppBar', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    expect(find.byTooltip('Open event details'), findsOneWidget);
    expect(find.byIcon(Icons.event_available), findsOneWidget);
  });

  testWidgets('Sport chips filter both Home previews', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nearByEventsProvider.overrideWith(
            (ref) async => [
              _event(1, 'Pickup Soccer'),
              _event(2, 'Hoops Night', 'Basketball'),
            ],
          ),
          nearbyVenuesProvider.overrideWith(
            (ref) async => [
              _venue(1, 'Central Turf'),
              _venue(2, 'Riverside Court', ['Basketball']),
            ],
          ),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    expect(find.text('Pickup Soccer'), findsOneWidget);
    expect(find.text('Central Turf'), findsOneWidget);

    await tester.tap(find.text('Football'));
    await tester.pump();
    expect(find.text('Pickup Soccer'), findsOneWidget);
    expect(find.text('Central Turf'), findsOneWidget);
    expect(find.text('Hoops Night'), findsNothing);
    expect(find.text('Riverside Court'), findsNothing);

    await tester.tap(find.text('Basketball'));
    await tester.pump();
    expect(find.text('Hoops Night'), findsOneWidget);
    expect(find.text('Riverside Court'), findsOneWidget);
    testWidgets('HomeHeader shows Olympics animation after greeting',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HomeHeader(
                onNotificationTap: () {},
                onLocationTap: () {},
                onProfileTap: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Ready to play'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Athlete celebration animation'),
        findsOneWidget,
      );
    });

    expect(find.text('Pickup Soccer'), findsNothing);
    expect(find.text('Central Turf'), findsNothing);
    testWidgets('Event preview rows show rich details', (tester) async {
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
      expect(find.text('Pickup Soccer'), findsOneWidget);
      expect(find.textContaining('5/10 players'), findsOneWidget);
      expect(find.text('Zilker Park'), findsOneWidget);
      expect(find.textContaining('Oct 10'), findsOneWidget);
    });
  });

  testWidgets('Tennis filter with 0 matches shows empty-state recovery',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nearByEventsProvider.overrideWith(
            (ref) async => [
              _event(1, 'Pickup Soccer'),
              _event(2, 'Hoops Night', 'Basketball'),
            ],
          ),
          nearbyVenuesProvider.overrideWith(
            (ref) async => [_venue(1, 'Central Turf')],
          ),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Tennis'));
    await tester.pump();

    expect(find.text('No games found nearby yet.'), findsOneWidget);
    expect(find.text('Explore other sports'), findsOneWidget);
    expect(find.text('or Expand search radius to 15 mi'), findsOneWidget);
    expect(find.text('Update Location Permissions'), findsOneWidget);
    expect(find.text('Be the first to start a game'), findsOneWidget);
    expect(find.text('Host an Event'), findsOneWidget);
    // Venues stay explorable even when events are empty.
    expect(find.text('Venues near you'), findsOneWidget);
    expect(find.text('Central Turf'), findsOneWidget);

    // Explore other sports resets the filter.
    await tester.tap(find.text('Explore other sports'));
    await tester.pump();
    expect(find.text('No games found nearby yet.'), findsNothing);
    expect(find.text('Pickup Soccer'), findsOneWidget);

    // Expand radius writes the expanded value.
    await tester.tap(find.text('Tennis'));
    await tester.pump();
    await tester.tap(find.text('or Expand search radius to 15 mi'));
    await tester.pump();
    final container =
        ProviderScope.containerOf(tester.element(find.text('Home').first));
    expect(
      container.read(homeSearchRadiusKmProvider),
      homeExpandedSearchRadiusKm,
    );
  });
}
