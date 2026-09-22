// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'venue.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Venue {
  int get id;
  String get name;
  String? get description;
  String get address;
  String get city;
  double get latitude;
  double get longitude;
  List<String> get sports;
  bool get hasLights;
  bool get hasChangingRoom;
  bool get hasParking;
  bool get isFree;
  double? get pricePerHour;
  double get rating;
  int get reviewCount;
  String? get phone;
  String? get website;
  List<String> get imageUrls;
  double? get distanceKm;

  /// Create a copy of Venue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VenueCopyWith<Venue> get copyWith =>
      _$VenueCopyWithImpl<Venue>(this as Venue, _$identity);

  /// Serializes this Venue to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Venue &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            const DeepCollectionEquality().equals(other.sports, sports) &&
            (identical(other.hasLights, hasLights) ||
                other.hasLights == hasLights) &&
            (identical(other.hasChangingRoom, hasChangingRoom) ||
                other.hasChangingRoom == hasChangingRoom) &&
            (identical(other.hasParking, hasParking) ||
                other.hasParking == hasParking) &&
            (identical(other.isFree, isFree) || other.isFree == isFree) &&
            (identical(other.pricePerHour, pricePerHour) ||
                other.pricePerHour == pricePerHour) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.website, website) || other.website == website) &&
            const DeepCollectionEquality().equals(other.imageUrls, imageUrls) &&
            (identical(other.distanceKm, distanceKm) ||
                other.distanceKm == distanceKm));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        description,
        address,
        city,
        latitude,
        longitude,
        const DeepCollectionEquality().hash(sports),
        hasLights,
        hasChangingRoom,
        hasParking,
        isFree,
        pricePerHour,
        rating,
        reviewCount,
        phone,
        website,
        const DeepCollectionEquality().hash(imageUrls),
        distanceKm
      ]);

  @override
  String toString() {
    return 'Venue(id: $id, name: $name, description: $description, address: $address, city: $city, latitude: $latitude, longitude: $longitude, sports: $sports, hasLights: $hasLights, hasChangingRoom: $hasChangingRoom, hasParking: $hasParking, isFree: $isFree, pricePerHour: $pricePerHour, rating: $rating, reviewCount: $reviewCount, phone: $phone, website: $website, imageUrls: $imageUrls, distanceKm: $distanceKm)';
  }
}

/// @nodoc
abstract mixin class $VenueCopyWith<$Res> {
  factory $VenueCopyWith(Venue value, $Res Function(Venue) _then) =
      _$VenueCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      String name,
      String? description,
      String address,
      String city,
      double latitude,
      double longitude,
      List<String> sports,
      bool hasLights,
      bool hasChangingRoom,
      bool hasParking,
      bool isFree,
      double? pricePerHour,
      double rating,
      int reviewCount,
      String? phone,
      String? website,
      List<String> imageUrls,
      double? distanceKm});
}

/// @nodoc
class _$VenueCopyWithImpl<$Res> implements $VenueCopyWith<$Res> {
  _$VenueCopyWithImpl(this._self, this._then);

  final Venue _self;
  final $Res Function(Venue) _then;

  /// Create a copy of Venue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? address = null,
    Object? city = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? sports = null,
    Object? hasLights = null,
    Object? hasChangingRoom = null,
    Object? hasParking = null,
    Object? isFree = null,
    Object? pricePerHour = freezed,
    Object? rating = null,
    Object? reviewCount = null,
    Object? phone = freezed,
    Object? website = freezed,
    Object? imageUrls = null,
    Object? distanceKm = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      address: null == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      city: null == city
          ? _self.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      sports: null == sports
          ? _self.sports
          : sports // ignore: cast_nullable_to_non_nullable
              as List<String>,
      hasLights: null == hasLights
          ? _self.hasLights
          : hasLights // ignore: cast_nullable_to_non_nullable
              as bool,
      hasChangingRoom: null == hasChangingRoom
          ? _self.hasChangingRoom
          : hasChangingRoom // ignore: cast_nullable_to_non_nullable
              as bool,
      hasParking: null == hasParking
          ? _self.hasParking
          : hasParking // ignore: cast_nullable_to_non_nullable
              as bool,
      isFree: null == isFree
          ? _self.isFree
          : isFree // ignore: cast_nullable_to_non_nullable
              as bool,
      pricePerHour: freezed == pricePerHour
          ? _self.pricePerHour
          : pricePerHour // ignore: cast_nullable_to_non_nullable
              as double?,
      rating: null == rating
          ? _self.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      reviewCount: null == reviewCount
          ? _self.reviewCount
          : reviewCount // ignore: cast_nullable_to_non_nullable
              as int,
      phone: freezed == phone
          ? _self.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      website: freezed == website
          ? _self.website
          : website // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrls: null == imageUrls
          ? _self.imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      distanceKm: freezed == distanceKm
          ? _self.distanceKm
          : distanceKm // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// Adds pattern-matching-related methods to [Venue].
extension VenuePatterns on Venue {
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
    TResult Function(_Venue value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Venue() when $default != null:
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
    TResult Function(_Venue value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Venue():
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
    TResult? Function(_Venue value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Venue() when $default != null:
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
            String name,
            String? description,
            String address,
            String city,
            double latitude,
            double longitude,
            List<String> sports,
            bool hasLights,
            bool hasChangingRoom,
            bool hasParking,
            bool isFree,
            double? pricePerHour,
            double rating,
            int reviewCount,
            String? phone,
            String? website,
            List<String> imageUrls,
            double? distanceKm)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Venue() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.description,
            _that.address,
            _that.city,
            _that.latitude,
            _that.longitude,
            _that.sports,
            _that.hasLights,
            _that.hasChangingRoom,
            _that.hasParking,
            _that.isFree,
            _that.pricePerHour,
            _that.rating,
            _that.reviewCount,
            _that.phone,
            _that.website,
            _that.imageUrls,
            _that.distanceKm);
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
            String name,
            String? description,
            String address,
            String city,
            double latitude,
            double longitude,
            List<String> sports,
            bool hasLights,
            bool hasChangingRoom,
            bool hasParking,
            bool isFree,
            double? pricePerHour,
            double rating,
            int reviewCount,
            String? phone,
            String? website,
            List<String> imageUrls,
            double? distanceKm)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Venue():
        return $default(
            _that.id,
            _that.name,
            _that.description,
            _that.address,
            _that.city,
            _that.latitude,
            _that.longitude,
            _that.sports,
            _that.hasLights,
            _that.hasChangingRoom,
            _that.hasParking,
            _that.isFree,
            _that.pricePerHour,
            _that.rating,
            _that.reviewCount,
            _that.phone,
            _that.website,
            _that.imageUrls,
            _that.distanceKm);
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
            String name,
            String? description,
            String address,
            String city,
            double latitude,
            double longitude,
            List<String> sports,
            bool hasLights,
            bool hasChangingRoom,
            bool hasParking,
            bool isFree,
            double? pricePerHour,
            double rating,
            int reviewCount,
            String? phone,
            String? website,
            List<String> imageUrls,
            double? distanceKm)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Venue() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.description,
            _that.address,
            _that.city,
            _that.latitude,
            _that.longitude,
            _that.sports,
            _that.hasLights,
            _that.hasChangingRoom,
            _that.hasParking,
            _that.isFree,
            _that.pricePerHour,
            _that.rating,
            _that.reviewCount,
            _that.phone,
            _that.website,
            _that.imageUrls,
            _that.distanceKm);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Venue implements Venue {
  const _Venue(
      {required this.id,
      required this.name,
      this.description,
      required this.address,
      required this.city,
      required this.latitude,
      required this.longitude,
      required final List<String> sports,
      this.hasLights = false,
      this.hasChangingRoom = false,
      this.hasParking = false,
      this.isFree = true,
      this.pricePerHour,
      this.rating = 0.0,
      this.reviewCount = 0,
      this.phone,
      this.website,
      final List<String> imageUrls = const [],
      this.distanceKm})
      : _sports = sports,
        _imageUrls = imageUrls;
  factory _Venue.fromJson(Map<String, dynamic> json) => _$VenueFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String address;
  @override
  final String city;
  @override
  final double latitude;
  @override
  final double longitude;
  final List<String> _sports;
  @override
  List<String> get sports {
    if (_sports is EqualUnmodifiableListView) return _sports;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sports);
  }

  @override
  @JsonKey()
  final bool hasLights;
  @override
  @JsonKey()
  final bool hasChangingRoom;
  @override
  @JsonKey()
  final bool hasParking;
  @override
  @JsonKey()
  final bool isFree;
  @override
  final double? pricePerHour;
  @override
  @JsonKey()
  final double rating;
  @override
  @JsonKey()
  final int reviewCount;
  @override
  final String? phone;
  @override
  final String? website;
  final List<String> _imageUrls;
  @override
  @JsonKey()
  List<String> get imageUrls {
    if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_imageUrls);
  }

  @override
  final double? distanceKm;

  /// Create a copy of Venue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$VenueCopyWith<_Venue> get copyWith =>
      __$VenueCopyWithImpl<_Venue>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$VenueToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Venue &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            const DeepCollectionEquality().equals(other._sports, _sports) &&
            (identical(other.hasLights, hasLights) ||
                other.hasLights == hasLights) &&
            (identical(other.hasChangingRoom, hasChangingRoom) ||
                other.hasChangingRoom == hasChangingRoom) &&
            (identical(other.hasParking, hasParking) ||
                other.hasParking == hasParking) &&
            (identical(other.isFree, isFree) || other.isFree == isFree) &&
            (identical(other.pricePerHour, pricePerHour) ||
                other.pricePerHour == pricePerHour) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.website, website) || other.website == website) &&
            const DeepCollectionEquality()
                .equals(other._imageUrls, _imageUrls) &&
            (identical(other.distanceKm, distanceKm) ||
                other.distanceKm == distanceKm));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        description,
        address,
        city,
        latitude,
        longitude,
        const DeepCollectionEquality().hash(_sports),
        hasLights,
        hasChangingRoom,
        hasParking,
        isFree,
        pricePerHour,
        rating,
        reviewCount,
        phone,
        website,
        const DeepCollectionEquality().hash(_imageUrls),
        distanceKm
      ]);

  @override
  String toString() {
    return 'Venue(id: $id, name: $name, description: $description, address: $address, city: $city, latitude: $latitude, longitude: $longitude, sports: $sports, hasLights: $hasLights, hasChangingRoom: $hasChangingRoom, hasParking: $hasParking, isFree: $isFree, pricePerHour: $pricePerHour, rating: $rating, reviewCount: $reviewCount, phone: $phone, website: $website, imageUrls: $imageUrls, distanceKm: $distanceKm)';
  }
}

/// @nodoc
abstract mixin class _$VenueCopyWith<$Res> implements $VenueCopyWith<$Res> {
  factory _$VenueCopyWith(_Venue value, $Res Function(_Venue) _then) =
      __$VenueCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String? description,
      String address,
      String city,
      double latitude,
      double longitude,
      List<String> sports,
      bool hasLights,
      bool hasChangingRoom,
      bool hasParking,
      bool isFree,
      double? pricePerHour,
      double rating,
      int reviewCount,
      String? phone,
      String? website,
      List<String> imageUrls,
      double? distanceKm});
}

/// @nodoc
class __$VenueCopyWithImpl<$Res> implements _$VenueCopyWith<$Res> {
  __$VenueCopyWithImpl(this._self, this._then);

  final _Venue _self;
  final $Res Function(_Venue) _then;

  /// Create a copy of Venue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? address = null,
    Object? city = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? sports = null,
    Object? hasLights = null,
    Object? hasChangingRoom = null,
    Object? hasParking = null,
    Object? isFree = null,
    Object? pricePerHour = freezed,
    Object? rating = null,
    Object? reviewCount = null,
    Object? phone = freezed,
    Object? website = freezed,
    Object? imageUrls = null,
    Object? distanceKm = freezed,
  }) {
    return _then(_Venue(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      address: null == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      city: null == city
          ? _self.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      sports: null == sports
          ? _self._sports
          : sports // ignore: cast_nullable_to_non_nullable
              as List<String>,
      hasLights: null == hasLights
          ? _self.hasLights
          : hasLights // ignore: cast_nullable_to_non_nullable
              as bool,
      hasChangingRoom: null == hasChangingRoom
          ? _self.hasChangingRoom
          : hasChangingRoom // ignore: cast_nullable_to_non_nullable
              as bool,
      hasParking: null == hasParking
          ? _self.hasParking
          : hasParking // ignore: cast_nullable_to_non_nullable
              as bool,
      isFree: null == isFree
          ? _self.isFree
          : isFree // ignore: cast_nullable_to_non_nullable
              as bool,
      pricePerHour: freezed == pricePerHour
          ? _self.pricePerHour
          : pricePerHour // ignore: cast_nullable_to_non_nullable
              as double?,
      rating: null == rating
          ? _self.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      reviewCount: null == reviewCount
          ? _self.reviewCount
          : reviewCount // ignore: cast_nullable_to_non_nullable
              as int,
      phone: freezed == phone
          ? _self.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      website: freezed == website
          ? _self.website
          : website // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrls: null == imageUrls
          ? _self._imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      distanceKm: freezed == distanceKm
          ? _self.distanceKm
          : distanceKm // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

// dart format on
