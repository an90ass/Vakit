import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:namaz/repositories/prayer_repository.dart';
import 'prayer_event.dart';
import 'prayer_state.dart';

class PrayerBloc extends Bloc<PrayerEvent, PrayerState> {
  final PrayerRepository repository;

  PrayerBloc({required this.repository}) : super(PrayerInitial()) {
    on<LoadPrayerData>(_onLoadPrayerData);
    on<CalculateNextPrayer>(_onCalculateNextPrayer);
  }

  Future<void> _onLoadPrayerData(
      LoadPrayerData event, Emitter<PrayerState> emit) async {
    try {
      emit(PrayerLoading());

      final prayerTimes = await repository.fetchPrayerTimes(event.location);
      final hijriDate = await repository.fetchHijriDate();
      print('Response data: ${prayerTimes.timings}');
      final result = _calculateNextPrayer(prayerTimes.toMap());

      emit(PrayerLoaded(
        prayerTimes: prayerTimes,
        hijriDate: hijriDate,
        nextPrayer: result['name'],
        timeRemaining: result['remaining'],
      ));
    } catch (e) {
      emit(PrayerError(e.toString()));
    }
  }

  void _onCalculateNextPrayer(
      CalculateNextPrayer event, Emitter<PrayerState> emit) {
    if (state is PrayerLoaded) {
      final current = state as PrayerLoaded;
      final result = _calculateNextPrayer(event.prayerTimes);

      emit(PrayerLoaded(
        prayerTimes: current.prayerTimes,
        hijriDate: current.hijriDate,
        nextPrayer: result['name'],
        timeRemaining: result['remaining'],
      ));
    }
  }

  Map<String, dynamic> _calculateNextPrayer(Map<String, String> times) {
    final now = DateTime.now();
    String? nextPrayer;
    Duration? minDiff;

    times.forEach((name, time) {
      final parts = time.split(':');
      final prayerTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      final diff = prayerTime.difference(now);
      if (diff.inSeconds >= 0 && (minDiff == null || diff < minDiff!)) {
        minDiff = diff;
        nextPrayer = name;
      }
    });

    return {
      'name': nextPrayer ?? '',
      'remaining': minDiff ?? Duration.zero,
    };
  }
}
