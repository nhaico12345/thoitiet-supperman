part of 'location_bloc.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object> get props => [];
}

class LoadSavedLocations extends LocationEvent {
  const LoadSavedLocations();
}

class SearchLocation extends LocationEvent {
  final String query;
  const SearchLocation(this.query);
}

class AddLocation extends LocationEvent {
  final LocationEntity location;
  const AddLocation(this.location);
}

class RemoveLocation extends LocationEvent {
  final LocationEntity location;
  const RemoveLocation(this.location);
}

class SelectLocation extends LocationEvent {
  final LocationEntity location;
  const SelectLocation(this.location);
}

class GetCurrentLocationEvent extends LocationEvent {
  const GetCurrentLocationEvent();
}
