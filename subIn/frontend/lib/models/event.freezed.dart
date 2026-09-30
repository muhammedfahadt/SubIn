// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Event {
  int get id;
  String get title;
  String? get description;
  String get sport;
  int? get venueId;
  String? get customLocation;
  double? get latitude;
  double? get longitude;
  DateTime get startTime;
  DateTime get endTime;
  int get maxPlayers;
  int get minPlayers;
  int get currentPlayers;
  bool get isFree;
  double? get costPerPlayer;
  String get status;
  String get skillLevel;
  bool get isPublic;
  int get organizerId;
  String get organizerName;
  DateTime get createdAt;
  double? get distanceKm;
  int? get spotsRemaining;

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $EventCopyWith<Event> get copyWith =>
      _$EventCopyWithImpl<Event>(this as Event, _$identity);

  /// Serializes this Event to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Event &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.sport, sport) || other.sport == sport) &&
            (identical(other.venueId, venueId) || other.venueId == venueId) &&
            (identical(other.customLocation, customLocation) ||
                other.customLocation == customLocation) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.maxPlayers, maxPlayers) ||
                other.maxPlayers == maxPlayers) &&
            (identical(other.minPlayers, minPlayers) ||
                other.minPlayers == minPlayers) &&
            (identical(other.currentPlayers, currentPlayers) ||
                other.currentPlayers == currentPlayers) &&
            (identical(other.isFree, isFree) || other.isFree == isFree) &&
            (identical(other.costPerPlayer, costPerPlayer) ||
                other.costPerPlayer == costPerPlayer) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.skillLevel, skillLevel) ||
                other.skillLevel == skillLevel) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic) &&
            (identical(other.organizerId, organizerId) ||
                other.organizerId == organizerId) &&
            (identical(other.organizerName, organizerName) ||
                other.organizerName == organizerName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.distanceKm, distanceKm) ||
                other.distanceKm == distanceKm) &&
            (identical(other.spotsRemaining, spotsRemaining) ||
                other.spotsRemaining == spotsRemaining));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        title,
        description,
        sport,
        venueId,
        customLocation,
        latitude,
        longitude,
        startTime,
        endTime,
        maxPlayers,
        minPlayers,
        currentPlayers,
        isFree,
        costPerPlayer,
        status,
        skillLevel,
        isPublic,
        organizerId,
        organizerName,
        createdAt,
        distanceKm,
        spotsRemaining
      ]);

  @override
  String toString() {
    return 'Event(id: $id, title: $title, description: $description, sport: $sport, venueId: $venueId, customLocation: $customLocation, latitude: $latitude, longitude: $longitude, startTime: $startTime, endTime: $endTime, maxPlayers: $maxPlayers, minPlayers: $minPlayers, currentPlayers: $currentPlayers, isFree: $isFree, costPerPlayer: $costPerPlayer, status: $status, skillLevel: $skillLevel, isPublic: $isPublic, organizerId: $organizerId, organizerName: $organizerName, createdAt: $createdAt, distanceKm: $distanceKm, spotsRemaining: $spotsRemaining)';
  }
}

/// @nodoc
abstract mixin class $EventCopyWith<$Res> {
  factory $EventCopyWith(Event value, $Res Function(Event) _then) =
      _$EventCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      String title,
      String? description,
      String sport,
      int? venueId,
      String? customLocation,
      double? latitude,
      double? longitude,
      DateTime startTime,
      DateTime endTime,
      int maxPlayers,
      int minPlayers,
      int currentPlayers,
      bool isFree,
      double? costPerPlayer,
      String status,
      String skillLevel,
      bool isPublic,
      int organizerId,
      String organizerName,
      DateTime createdAt,
      double? distanceKm,
      int? spotsRemaining});
}

/// @nodoc
class _$EventCopyWithImpl<$Res> implements $EventCopyWith<$Res> {
  _$EventCopyWithImpl(this._self, this._then);

  final Event _self;
  final $Res Function(Event) _then;

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? sport = null,
    Object? venueId = freezed,
    Object? customLocation = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? startTime = null,
    Object? endTime = null,
    Object? maxPlayers = null,
    Object? minPlayers = null,
    Object? currentPlayers = null,
    Object? isFree = null,
    Object? costPerPlayer = freezed,
    Object? status = null,
    Object? skillLevel = null,
    Object? isPublic = null,
    Object? organizerId = null,
    Object? organizerName = null,
    Object? createdAt = null,
    Object? distanceKm = freezed,
    Object? spotsRemaining = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      sport: null == sport
          ? _self.sport
          : sport // ignore: cast_nullable_to_non_nullable
              as String,
      venueId: freezed == venueId
          ? _self.venueId
          : venueId // ignore: cast_nullable_to_non_nullable
              as int?,
      customLocation: freezed == customLocation
          ? _self.customLocation
          : customLocation // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      startTime: null == startTime
          ? _self.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: null == endTime
          ? _self.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      maxPlayers: null == maxPlayers
          ? _self.maxPlayers
          : maxPlayers // ignore: cast_nullable_to_non_nullable
              as int,
      minPlayers: null == minPlayers
          ? _self.minPlayers
          : minPlayers // ignore: cast_nullable_to_non_nullable
              as int,
      currentPlayers: null == currentPlayers
          ? _self.currentPlayers
          : currentPlayers // ignore: cast_nullable_to_non_nullable
              as int,
      isFree: null == isFree
          ? _self.isFree
          : isFree // ignore: cast_nullable_to_non_nullable
              as bool,
      costPerPlayer: freezed == costPerPlayer
          ? _self.costPerPlayer
          : costPerPlayer // ignore: cast_nullable_to_non_nullable
              as double?,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      skillLevel: null == skillLevel
          ? _self.skillLevel
          : skillLevel // ignore: cast_nullable_to_non_nullable
              as String,
      isPublic: null == isPublic
          ? _self.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      organizerId: null == organizerId
          ? _self.organizerId
          : organizerId // ignore: cast_nullable_to_non_nullable
              as int,
      organizerName: null == organizerName
          ? _self.organizerName
          : organizerName // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      distanceKm: freezed == distanceKm
          ? _self.distanceKm
          : distanceKm // ignore: cast_nullable_to_non_nullable
              as double?,
      spotsRemaining: freezed == spotsRemaining
          ? _self.spotsRemaining
          : spotsRemaining // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// Adds pattern-matching-related methods to [Event].
extension EventPatterns on Event {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Event value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Event() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Event value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Event():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Event value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Event() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            int id,
            String title,
            String? description,
            String sport,
            int? venueId,
            String? customLocation,
            double? latitude,
            double? longitude,
            DateTime startTime,
            DateTime endTime,
            int maxPlayers,
            int minPlayers,
            int currentPlayers,
            bool isFree,
            double? costPerPlayer,
            String status,
            String skillLevel,
            bool isPublic,
            int organizerId,
            String organizerName,
            DateTime createdAt,
            double? distanceKm,
            int? spotsRemaining)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Event() when $default != null:
        return $default(
            _that.id,
            _that.title,
            _that.description,
            _that.sport,
            _that.venueId,
            _that.customLocation,
            _that.latitude,
            _that.longitude,
            _that.startTime,
            _that.endTime,
            _that.maxPlayers,
            _that.minPlayers,
            _that.currentPlayers,
            _that.isFree,
            _that.costPerPlayer,
            _that.status,
            _that.skillLevel,
            _that.isPublic,
            _that.organizerId,
            _that.organizerName,
            _that.createdAt,
            _that.distanceKm,
            _that.spotsRemaining);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            int id,
            String title,
            String? description,
            String sport,
            int? venueId,
            String? customLocation,
            double? latitude,
            double? longitude,
            DateTime startTime,
            DateTime endTime,
            int maxPlayers,
            int minPlayers,
            int currentPlayers,
            bool isFree,
            double? costPerPlayer,
            String status,
            String skillLevel,
            bool isPublic,
            int organizerId,
            String organizerName,
            DateTime createdAt,
            double? distanceKm,
            int? spotsRemaining)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Event():
        return $default(
            _that.id,
            _that.title,
            _that.description,
            _that.sport,
            _that.venueId,
            _that.customLocation,
            _that.latitude,
            _that.longitude,
            _that.startTime,
            _that.endTime,
            _that.maxPlayers,
            _that.minPlayers,
            _that.currentPlayers,
            _that.isFree,
            _that.costPerPlayer,
            _that.status,
            _that.skillLevel,
            _that.isPublic,
            _that.organizerId,
            _that.organizerName,
            _that.createdAt,
            _that.distanceKm,
            _that.spotsRemaining);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            int id,
            String title,
            String? description,
            String sport,
            int? venueId,
            String? customLocation,
            double? latitude,
            double? longitude,
            DateTime startTime,
            DateTime endTime,
            int maxPlayers,
            int minPlayers,
            int currentPlayers,
            bool isFree,
            double? costPerPlayer,
            String status,
            String skillLevel,
            bool isPublic,
            int organizerId,
            String organizerName,
            DateTime createdAt,
            double? distanceKm,
            int? spotsRemaining)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Event() when $default != null:
        return $default(
            _that.id,
            _that.title,
            _that.description,
            _that.sport,
            _that.venueId,
            _that.customLocation,
            _that.latitude,
            _that.longitude,
            _that.startTime,
            _that.endTime,
            _that.maxPlayers,
            _that.minPlayers,
            _that.currentPlayers,
            _that.isFree,
            _that.costPerPlayer,
            _that.status,
            _that.skillLevel,
            _that.isPublic,
            _that.organizerId,
            _that.organizerName,
            _that.createdAt,
            _that.distanceKm,
            _that.spotsRemaining);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Event implements Event {
  const _Event(
      {required this.id,
      required this.title,
      this.description,
      required this.sport,
      this.venueId,
      this.customLocation,
      this.latitude,
      this.longitude,
      required this.startTime,
      required this.endTime,
      required this.maxPlayers,
      required this.minPlayers,
      required this.currentPlayers,
      required this.isFree,
      this.costPerPlayer,
      required this.status,
      required this.skillLevel,
      required this.isPublic,
      required this.organizerId,
      required this.organizerName,
      required this.createdAt,
      this.distanceKm,
      this.spotsRemaining});
  factory _Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final String? description;
  @override
  final String sport;
  @override
  final int? venueId;
  @override
  final String? customLocation;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final DateTime startTime;
  @override
  final DateTime endTime;
  @override
  final int maxPlayers;
  @override
  final int minPlayers;
  @override
  final int currentPlayers;
  @override
  final bool isFree;
  @override
  final double? costPerPlayer;
  @override
  final String status;
  @override
  final String skillLevel;
  @override
  final bool isPublic;
  @override
  final int organizerId;
  @override
  final String organizerName;
  @override
  final DateTime createdAt;
  @override
  final double? distanceKm;
  @override
  final int? spotsRemaining;

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$EventCopyWith<_Event> get copyWith =>
      __$EventCopyWithImpl<_Event>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$EventToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Event &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.sport, sport) || other.sport == sport) &&
            (identical(other.venueId, venueId) || other.venueId == venueId) &&
            (identical(other.customLocation, customLocation) ||
                other.customLocation == customLocation) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.maxPlayers, maxPlayers) ||
                other.maxPlayers == maxPlayers) &&
            (identical(other.minPlayers, minPlayers) ||
                other.minPlayers == minPlayers) &&
            (identical(other.currentPlayers, currentPlayers) ||
                other.currentPlayers == currentPlayers) &&
            (identical(other.isFree, isFree) || other.isFree == isFree) &&
            (identical(other.costPerPlayer, costPerPlayer) ||
                other.costPerPlayer == costPerPlayer) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.skillLevel, skillLevel) ||
                other.skillLevel == skillLevel) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic) &&
            (identical(other.organizerId, organizerId) ||
                other.organizerId == organizerId) &&
            (identical(other.organizerName, organizerName) ||
                other.organizerName == organizerName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.distanceKm, distanceKm) ||
                other.distanceKm == distanceKm) &&
            (identical(other.spotsRemaining, spotsRemaining) ||
                other.spotsRemaining == spotsRemaining));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        title,
        description,
        sport,
        venueId,
        customLocation,
        latitude,
        longitude,
        startTime,
        endTime,
        maxPlayers,
        minPlayers,
        currentPlayers,
        isFree,
        costPerPlayer,
        status,
        skillLevel,
        isPublic,
        organizerId,
        organizerName,
        createdAt,
        distanceKm,
        spotsRemaining
      ]);

  @override
  String toString() {
    return 'Event(id: $id, title: $title, description: $description, sport: $sport, venueId: $venueId, customLocation: $customLocation, latitude: $latitude, longitude: $longitude, startTime: $startTime, endTime: $endTime, maxPlayers: $maxPlayers, minPlayers: $minPlayers, currentPlayers: $currentPlayers, isFree: $isFree, costPerPlayer: $costPerPlayer, status: $status, skillLevel: $skillLevel, isPublic: $isPublic, organizerId: $organizerId, organizerName: $organizerName, createdAt: $createdAt, distanceKm: $distanceKm, spotsRemaining: $spotsRemaining)';
  }
}

/// @nodoc
abstract mixin class _$EventCopyWith<$Res> implements $EventCopyWith<$Res> {
  factory _$EventCopyWith(_Event value, $Res Function(_Event) _then) =
      __$EventCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      String title,
      String? description,
      String sport,
      int? venueId,
      String? customLocation,
      double? latitude,
      double? longitude,
      DateTime startTime,
      DateTime endTime,
      int maxPlayers,
      int minPlayers,
      int currentPlayers,
      bool isFree,
      double? costPerPlayer,
      String status,
      String skillLevel,
      bool isPublic,
      int organizerId,
      String organizerName,
      DateTime createdAt,
      double? distanceKm,
      int? spotsRemaining});
}

/// @nodoc
class __$EventCopyWithImpl<$Res> implements _$EventCopyWith<$Res> {
  __$EventCopyWithImpl(this._self, this._then);

  final _Event _self;
  final $Res Function(_Event) _then;

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? sport = null,
    Object? venueId = freezed,
    Object? customLocation = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? startTime = null,
    Object? endTime = null,
    Object? maxPlayers = null,
    Object? minPlayers = null,
    Object? currentPlayers = null,
    Object? isFree = null,
    Object? costPerPlayer = freezed,
    Object? status = null,
    Object? skillLevel = null,
    Object? isPublic = null,
    Object? organizerId = null,
    Object? organizerName = null,
    Object? createdAt = null,
    Object? distanceKm = freezed,
    Object? spotsRemaining = freezed,
  }) {
    return _then(_Event(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      sport: null == sport
          ? _self.sport
          : sport // ignore: cast_nullable_to_non_nullable
              as String,
      venueId: freezed == venueId
          ? _self.venueId
          : venueId // ignore: cast_nullable_to_non_nullable
              as int?,
      customLocation: freezed == customLocation
          ? _self.customLocation
          : customLocation // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      startTime: null == startTime
          ? _self.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: null == endTime
          ? _self.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      maxPlayers: null == maxPlayers
          ? _self.maxPlayers
          : maxPlayers // ignore: cast_nullable_to_non_nullable
              as int,
      minPlayers: null == minPlayers
          ? _self.minPlayers
          : minPlayers // ignore: cast_nullable_to_non_nullable
              as int,
      currentPlayers: null == currentPlayers
          ? _self.currentPlayers
          : currentPlayers // ignore: cast_nullable_to_non_nullable
              as int,
      isFree: null == isFree
          ? _self.isFree
          : isFree // ignore: cast_nullable_to_non_nullable
              as bool,
      costPerPlayer: freezed == costPerPlayer
          ? _self.costPerPlayer
          : costPerPlayer // ignore: cast_nullable_to_non_nullable
              as double?,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      skillLevel: null == skillLevel
          ? _self.skillLevel
          : skillLevel // ignore: cast_nullable_to_non_nullable
              as String,
      isPublic: null == isPublic
          ? _self.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      organizerId: null == organizerId
          ? _self.organizerId
          : organizerId // ignore: cast_nullable_to_non_nullable
              as int,
      organizerName: null == organizerName
          ? _self.organizerName
          : organizerName // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      distanceKm: freezed == distanceKm
          ? _self.distanceKm
          : distanceKm // ignore: cast_nullable_to_non_nullable
              as double?,
      spotsRemaining: freezed == spotsRemaining
          ? _self.spotsRemaining
          : spotsRemaining // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

// dart format on
