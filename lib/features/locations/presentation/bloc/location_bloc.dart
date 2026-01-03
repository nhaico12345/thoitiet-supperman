// File: location_bloc.dart
// Mô tả: BLoC quản lý danh sách vị trí yêu thích và tìm kiếm.
// Xử lý tải, tìm, thêm, xóa vị trí và lấy vị trí hiện tại qua GPS.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/location.dart';
import '../../domain/repositories/location_repository.dart';
import '../../../../core/resources/data_state.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRepository _locationRepository;

  LocationBloc(this._locationRepository) : super(const LocationInitial()) {
    on<LoadSavedLocations>(_onLoadSavedLocations);
    on<SearchLocation>(_onSearchLocation);
    on<AddLocation>(_onAddLocation);
    on<RemoveLocation>(_onRemoveLocation);
    on<SelectLocation>(_onSelectLocation);
    on<GetCurrentLocationEvent>(_onGetCurrentLocation);
  }

  void _onLoadSavedLocations(
    LoadSavedLocations event,
    Emitter<LocationState> emit,
  ) {
    final saved = _locationRepository.getSavedLocations();
    emit(LocationLoaded(savedLocations: saved));
  }

  Future<void> _onSearchLocation(
    SearchLocation event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    final result = await _locationRepository.searchLocation(event.query);
    if (result is DataSuccess) {
      emit(LocationSearchSuccess(result.data!));
    } else {
      emit(LocationError(result.error!));
    }
    // Reload saved locations after search done to show list again?
    // Or keep search state? Usually search is transient.
    // For simplicity, let's keep it separate or handle in UI.
  }

  Future<void> _onAddLocation(
    AddLocation event,
    Emitter<LocationState> emit,
  ) async {
    await _locationRepository.saveLocation(event.location);
    add(const LoadSavedLocations());
  }

  Future<void> _onRemoveLocation(
    RemoveLocation event,
    Emitter<LocationState> emit,
  ) async {
    await _locationRepository.removeLocation(event.location);
    add(const LoadSavedLocations());
  }

  Future<void> _onSelectLocation(
    SelectLocation event,
    Emitter<LocationState> emit,
  ) async {
    await _locationRepository.selectLocation(event.location);
    emit(LocationSelected(event.location));
    add(const LoadSavedLocations());
  }

  Future<void> _onGetCurrentLocation(
    GetCurrentLocationEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    final result = await _locationRepository.getCurrentLocation();
    if (result is DataSuccess) {
      await _locationRepository.selectLocation(result.data!);
      emit(LocationSelected(result.data!));
      add(const LoadSavedLocations());
    } else {
      emit(LocationError(result.error!));
      add(const LoadSavedLocations());
    }
  }
}
