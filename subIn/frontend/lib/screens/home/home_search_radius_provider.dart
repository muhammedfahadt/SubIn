import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Home-only search radius in km.
///
/// Default 8.0 km (~5 miles) matches the empty-state copy.
/// Expanded 24.0 km (~15 miles) is the "Expand search radius" recovery path.
final homeSearchRadiusKmProvider = StateProvider<double>((ref) => 8.0);

/// Expanded radius for the "Expand search radius to 15 mi" quick action.
const double homeExpandedSearchRadiusKm = 24.0;
