import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final homeSelectedSportProvider = StateProvider<String>((ref) => 'All Sports');

bool homeSportMatchesEvent(String eventSport, String selectedSport) {
  if (selectedSport == 'All Sports') return true;
  return eventSport.toLowerCase() == selectedSport.toLowerCase();
}

bool homeSportMatchesVenue(List<String> sports, String selectedSport) {
  if (selectedSport == 'All Sports') return true;
  final lower = selectedSport.toLowerCase();
  return sports.map((sport) => sport.toLowerCase()).contains(lower);
}