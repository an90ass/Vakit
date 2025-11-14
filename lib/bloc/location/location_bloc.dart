import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vakit/bloc/location/location_event.dart';
import 'package:vakit/bloc/location/location_state.dart';
import 'package:vakit/services/LocationService.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationService _locationService;

  LocationBloc(this._locationService) : super(LocationInitial()) {
    on<LocationLoad>(_onLocationLoad);
    on<LocationUpdate>(_onLocationUpdate);
  }

  Future<void> _onLocationLoad(LocationLoad event, Emitter<LocationState> emit) async {
    print("loading");
    emit(LocationLoading());
    try {
      final position = await _locationService.loadLocationData();
          print("loading ==> ${position}");

      emit(LocationLoaded(position.latitude, position.longitude));
    } catch (e) {
      print(e);
      emit(LocationError(e.toString()));
    }
  }

  void _onLocationUpdate(LocationUpdate event, Emitter<LocationState> emit) {
    emit(LocationLoaded(event.latitude, event.longitude));
  }
}
