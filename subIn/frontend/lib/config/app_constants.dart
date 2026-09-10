class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://localhost:8000';
  static const String apiVersion = '/api/v1';

  // Feature Flags
  static const bool enableMaps = true;
  static const bool enablePushNotifications = false;

  // App Info
  static const String appName = 'SubIn';
  static const String tagline = 'Find Your Game. Find Your Team.';

  // Defaults
  static const double defaultSearchRadiusKm = 10.0;
  static const double maxSearchRadiusKm = 50.0;

  // Sports List
  static const List<String> sports = [
    'Football',
    'Cricket',
    'Basketball',
    'Tennis',
    'Badminton',
    'Volleyball',
    'Table Tennis',
    'Running',
    'Cycling',
    'Swimming',
    'Yoga',
    'Gym',
    'Other',
  ];

  // Skill Levels
  static const List<String> skillLevels = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Professional',
  ];
}
