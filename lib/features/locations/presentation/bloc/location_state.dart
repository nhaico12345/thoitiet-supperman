part of 'location_bloc.dart';

abstract class LocationState extends Equatable {
  const LocationState();
  
  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {
  const LocationInitial();
}

class LocationLoading extends LocationState {}

class LocationLoaded extends LocationState {
  final List<LocationEntity> savedLocations;
  const LocationLoaded({required this.savedLocations});
  
  @override
  List<Object?> get props => [savedLocations];
}

class LocationSearchSuccess extends LocationState {
  final List<LocationEntity> searchResults;
  const LocationSearchSuccess(this.searchResults);

  @override
  List<Object?> get props => [searchResults];
}

class LocationSelected extends LocationState {
  final LocationEntity location;
  const LocationSelected(this.location);

  @override
  List<Object?> get props => [location];
}

class LocationError extends LocationState {
  final Exception error;
  const LocationError(this.error);

  @override
  List<Object?> get props => [error];
}
