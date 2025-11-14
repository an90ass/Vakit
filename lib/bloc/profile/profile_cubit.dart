import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vakit/bloc/profile/profile_state.dart';
import 'package:vakit/models/extra_prayer_type.dart';
import 'package:vakit/models/prayer_times_model.dart';
import 'package:vakit/models/user_profile.dart';
import 'package:vakit/repositories/profile_repository.dart';
import 'package:vakit/services/extra_prayer_notification_service.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required ProfileRepository repository,
    required ExtraPrayerNotificationService notificationService,
  }) : _repository = repository,
       _notificationService = notificationService,
       super(const ProfileState());

  final ProfileRepository _repository;
  final ExtraPrayerNotificationService _notificationService;
  String? _lastScheduledHash;

  Future<void> loadProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final profile = await _repository.loadProfile();
      if (profile == null) {
        emit(state.copyWith(status: ProfileStatus.needsSetup));
      } else {
        emit(state.copyWith(status: ProfileStatus.ready, profile: profile));
      }
    } catch (error) {
      emit(state.copyWith(status: ProfileStatus.error, errorMessage: '$error'));
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    emit(state.copyWith(status: ProfileStatus.saving));
    try {
      final saved = await _repository.saveProfile(profile);
      emit(state.copyWith(status: ProfileStatus.ready, profile: saved));
    } catch (error) {
      emit(state.copyWith(status: ProfileStatus.error, errorMessage: '$error'));
    }
  }

  Future<void> toggleQadaMode(bool enabled) async {
    final current = state.profile;
    if (current == null) return;
    final updated = current.copyWith(qadaModeEnabled: enabled);
    await saveProfile(updated);
  }

  Future<void> updateExtraPrayers(
    List<ExtraPrayerType> selected,
    bool notifications,
  ) async {
    final current = state.profile;
    if (current == null) return;
    final updated = current.copyWith(
      extraPrayers: selected.map((e) => e.id).toList(),
      extraPrayerNotifications: notifications,
    );
    await saveProfile(updated);
  }

  Future<void> scheduleRemindersIfNeeded(
    PrayerTimes? times, {
    bool force = false,
  }) async {
    final profile = state.profile;
    if (profile == null || times == null) return;
    if (!profile.extraPrayerNotifications || profile.extraPrayers.isEmpty) {
      await _notificationService.cancelExtraPrayerNotifications();
      _lastScheduledHash = null;
      return;
    }
    final hash = _hashTimings(times);
    if (!force && hash == _lastScheduledHash) {
      return;
    }
    await _notificationService.scheduleExtraPrayers(
      profile.extraPrayers,
      times,
    );
    _lastScheduledHash = hash;
  }

  String _hashTimings(PrayerTimes times) {
    final buffer = StringBuffer();
    final keys = times.timings.keys.toList()..sort();
    for (final key in keys) {
      buffer.write(key);
      buffer.write(':');
      buffer.write(times.timings[key]);
      buffer.write('|');
    }
    return buffer.toString();
  }
}
