import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vakit/bloc/myPrayers/my_prayers_event.dart';
import 'package:vakit/bloc/myPrayers/my_prayers_state.dart';
import 'package:vakit/storage/prayer_storage.dart';

class MyPrayersBloc extends Bloc<MyPrayersEvent, MyPrayersState> {
  MyPrayersBloc() : super(MyPrayersInitial()) {
    on<LoadMyPrayers>((event, emit) async {
      await _getPrayerDay(event.dateKey, emit);
    });

    on<UpdatePrayerStatus>((event, emit) async {
      
     await _updatePrayerDay(event,emit);
    });
  }

 Future<void> _getPrayerDay(String dateKey, Emitter<MyPrayersState> emit) async {
  emit(MyPrayersLoading());
  print('Loading prayer data for $dateKey');
  try {
    final prayerDay = PrayerStorage.getPrayerDay(dateKey);
    if (prayerDay != null) {
      print('Prayer data found: $prayerDay');
      emit(MyPrayersLoaded(prayerDay));
    } else {
      print('No data found for $dateKey');
      emit(MyPrayersError('No data found for $dateKey'));
    }
  } catch (e) {
    print('Error loading prayer data: $e');
    emit(MyPrayersError('Failed to load prayer data'));
  }
}

  
  Future<void>  _updatePrayerDay(UpdatePrayerStatus event, Emitter<MyPrayersState> emit)async {
     final currentState = state;

      if (currentState is MyPrayersLoaded) {
        try {
          await PrayerStorage.updatePrayerStatus(event.dateKey, event.prayerName, event.status);
          final updatedPrayerDay = PrayerStorage.getPrayerDay(event.dateKey);

          if (updatedPrayerDay != null) {
            emit(MyPrayersLoaded(updatedPrayerDay));
          } else {
            emit(MyPrayersError('Failed to update prayer data'));
          }
        } catch (e) {
          emit(MyPrayersError('Failed to update prayer data'));
        }
      }
  }
}
