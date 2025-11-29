// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Vakit';

  @override
  String get homeGreeting => 'Welcome';

  @override
  String get homeGreetingSubtitle => 'Wishing you a peaceful day';

  @override
  String get tabHome => 'Home';

  @override
  String get tabCities => 'Cities';

  @override
  String get tabMyPrayers => 'My Prayers';

  @override
  String get tabQuran => 'Quran';

  @override
  String get tabSettings => 'Settings';

  @override
  String get locationLoading => 'Fetching your location...';

  @override
  String get locationError => 'Location error';

  @override
  String get genericError => 'Something went wrong';

  @override
  String get nextPrayerLabel => 'Next prayer';

  @override
  String get remainingLabel => 'remaining';

  @override
  String get locationsHeader => 'Tracked locations';

  @override
  String get locationsSubhead =>
      'Track up to 3 places and view them side by side.';

  @override
  String get addLocation => 'Add location';

  @override
  String get currentLocation => 'Current Location';

  @override
  String get manualLocation => 'Manual Location';

  @override
  String maxLocationsReached(int count) {
    return 'You can store up to $count locations.';
  }

  @override
  String get addLocationTitle => 'Add a new location';

  @override
  String get addLocationDescription =>
      'Type a city, district, or full address to add it to your list.';

  @override
  String get addressFieldLabel => 'Address or city';

  @override
  String get addressFieldHint => 'e.g. Adana Seyhan';

  @override
  String get labelFieldLabel => 'Card label (optional)';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get setActive => 'Set active';

  @override
  String get active => 'Active';

  @override
  String get delete => 'Delete';

  @override
  String get locationSaved => 'Location saved.';

  @override
  String get locationDeleted => 'Location removed.';

  @override
  String get locationSearchFailed =>
      'We couldn\'t find that address. Please try something else.';

  @override
  String get languageTitle => 'App Language';

  @override
  String get languageSubtitle => 'Switch between Turkish, English, and Arabic.';

  @override
  String get languageTurkish => 'Turkish';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get languageChanged => 'Language updated.';

  @override
  String get citiesScreenTitle => 'City dashboard';

  @override
  String get citiesRefreshAction => 'Refresh prayer summaries';

  @override
  String get citiesDeleteConfirm => 'Remove this city from your list?';

  @override
  String get citiesCardSubtitle =>
      'Stay updated with this city\'s next prayer.';

  @override
  String get citiesEmptyTitle => 'No cities yet';

  @override
  String get citiesEmptyDescription =>
      'Add a manual city or refresh GPS to start tracking.';

  @override
  String get citiesManageButton => 'Open city dashboard';

  @override
  String get locationPermissionDenied =>
      'Location permission is denied. Please enable it from Settings.';

  @override
  String get gpsRefresh => 'Refresh GPS';

  @override
  String get gpsRefreshing => 'Updating location...';

  @override
  String get emptyTrackedLocations => 'No tracked locations yet.';

  @override
  String get addressRequired => 'Address field cannot be empty.';

  @override
  String get settingsLoadingMessage => 'Loading settings...';

  @override
  String get locationPermissionTitle => 'Location permission needed';

  @override
  String get locationPermissionDeniedBody =>
      'We need access to your location or you can switch to manual city selection.';

  @override
  String get locationPermissionPermanentBody =>
      'Location access is permanently denied. Please enable it in Settings or choose a city manually.';

  @override
  String get locationUpdatedTitle => 'Location updated';

  @override
  String get locationUpdatedBodyAuto =>
      'Your namaz times will refresh for the new GPS position.';

  @override
  String locationUpdatedBodyManual(String location) {
    return 'Prayer times will refresh for $location.';
  }

  @override
  String get errorGenericTitle => 'Something went wrong';

  @override
  String get locationFetchError =>
      'We could not refresh your position. Please try selecting a city manually.';

  @override
  String get locationSelectCityError =>
      'Please pick a city before updating the location.';

  @override
  String get locationUpdateError =>
      'There was a problem while updating the manual location.';

  @override
  String get notificationPermissionTitle => 'Notification permission';

  @override
  String get notificationPermissionBody =>
      'Enable notifications to receive namaz reminders.';

  @override
  String get languageChangeTitle => 'Language updated';

  @override
  String get languageChangeDescription =>
      'Restart may be required for the full translation to apply.';

  @override
  String get settingsResetDialogTitle => 'Reset settings';

  @override
  String get settingsResetDialogBody =>
      'Are you sure you want to reset everything back to defaults?';

  @override
  String get settingsResetDialogConfirm => 'Reset';

  @override
  String get settingsResetSuccessTitle => 'All set';

  @override
  String get settingsResetSuccessBody =>
      'Settings have been restored to their defaults.';

  @override
  String get settingsResetError =>
      'An error occurred while resetting your settings.';

  @override
  String get dialogOk => 'OK';

  @override
  String get settingsLocationSection => 'Location';

  @override
  String get settingsNotificationsSection => 'Notifications';

  @override
  String get settingsInterfaceSection => 'Interface';

  @override
  String get settingsLocationMethodLabel =>
      'How should we detect your location?';

  @override
  String get settingsLocationMethodAuto => 'Automatic';

  @override
  String get settingsLocationMethodManual => 'Manual';

  @override
  String get settingsUpdateLocation => 'Update location';

  @override
  String get settingsSelectCityPlaceholder => 'Select city';

  @override
  String get settingsDistrictHint => 'District (optional)';

  @override
  String settingsCurrentLocationLabel(String label) {
    return 'Current location: $label';
  }

  @override
  String get settingsCurrentLocationGps => 'GPS coordinates';

  @override
  String settingsLatitudeLongitude(String lat, String lon) {
    return 'Lat: $lat, Lon: $lon';
  }

  @override
  String get settingsNotificationsToggle => 'Prayer notifications';

  @override
  String get settingsNotificationLeadTime =>
      'How early should reminders arrive?';

  @override
  String get settingsNotificationMinutesSuffix => 'minutes';

  @override
  String get settingsNotificationSound => 'Sound';

  @override
  String get settingsNotificationVibration => 'Vibration';

  @override
  String get settingsShowArabicText => 'Show Arabic text';

  @override
  String get settingsShowHijriDate => 'Show Hijri date';

  @override
  String get settingsShowGregorianDate => 'Show Gregorian date';

  @override
  String get settingsResetButton => 'Reset all settings';

  @override
  String settingsAppVersionLabel(String version) {
    return 'Vakit app v$version';
  }

  @override
  String get settingsAppCopyright => '© 2025 All rights reserved';

  @override
  String get settingsCityPickerTitle => 'Select city';

  @override
  String get settingsCitySearchHint => 'Search city...';

  @override
  String get themePaletteTitle => 'Theme palette';

  @override
  String get themePaletteSubtitle =>
      'Choose the color family and softness that fits your eye.';

  @override
  String get themeSofteningLabel => 'Color softening';

  @override
  String themeSofteningValue(int percent) {
    return '$percent%';
  }

  @override
  String get themeSofteningDescription =>
      'Soften the backgrounds for a brighter feel or keep it low for higher contrast.';

  @override
  String get themePaletteOliveName => 'Olive Grove';

  @override
  String get themePaletteOliveDescription =>
      'Balanced greens with gentle gold accents.';

  @override
  String get themePaletteDesertName => 'Desert Sunset';

  @override
  String get themePaletteDesertDescription =>
      'Warm sand tones with amber highlights.';

  @override
  String get themePaletteMidnightName => 'Midnight Blue';

  @override
  String get themePaletteMidnightDescription =>
      'Cool night blues with moonlit accents.';

  @override
  String get prayerImsak => 'Fajr';

  @override
  String get prayerSunrise => 'Sunrise';

  @override
  String get prayerDhuhr => 'Dhuhr';

  @override
  String get prayerAsr => 'Asr';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerIsha => 'Isha';

  @override
  String get prayerFajr => 'Fajr';

  @override
  String get dailyPrayers => 'Daily Prayers';

  @override
  String get todaysDate => 'Today\'s Date';

  @override
  String get todaysProgress => 'Today\'s Progress';

  @override
  String get keepUpGoodWork => 'Keep up the good work!';

  @override
  String get complete => 'Complete';

  @override
  String get completed => 'COMPLETED';

  @override
  String get missed => 'MISSED';

  @override
  String get pending => 'PENDING';

  @override
  String get done => 'Done';

  @override
  String get missedPrayer => 'Missed';

  @override
  String get remaining => 'remaining';

  @override
  String get nextPrayer => 'Next prayer';

  @override
  String get qadaTracking => 'Qada Tracking';

  @override
  String get qadaTrackingOn => 'Qada tracking enabled';

  @override
  String get qadaTrackingOff => 'Qada tracking disabled';

  @override
  String get noPendingQada => 'Great! No pending qada prayers.';

  @override
  String pendingQadaMessage(int count) {
    return '$count prayers pending. Mark as you complete.';
  }

  @override
  String get table => 'Table';

  @override
  String get widget => 'Widget';

  @override
  String get pendingQadaPrayers => 'Pending Qada Prayers';

  @override
  String get noRecordsYet => 'No pending records yet.';

  @override
  String get date => 'Date';

  @override
  String get prayerTime => 'Prayer';

  @override
  String get recorded => 'Recorded';

  @override
  String get completedDate => 'Completed';

  @override
  String get shareCSV => 'Share CSV';

  @override
  String get copyToClipboard => 'Copy to clipboard';

  @override
  String get tableCopied => 'Table copied to clipboard';

  @override
  String get qadaTable => 'Qada prayer table';

  @override
  String get currentQadaSummary => 'My current qada summary';

  @override
  String get editProfile => 'Edit';

  @override
  String get ageYears => 'years';

  @override
  String get hijriAge => 'Hijri';

  @override
  String get profileSetupSubtitle =>
      'Add your personal preferences, track qada and extra prayers.';

  @override
  String get profileName => 'Name';

  @override
  String get profileNameRequired => 'Please enter your name';

  @override
  String get profileNameMinLength => 'Name must be at least 2 characters';

  @override
  String get profileBirthDate => 'Birth Date';

  @override
  String get profileBirthDateHelp => 'Select Your Birth Date';

  @override
  String get profileSelectDate => 'Select date';

  @override
  String get profileBirthDateRequired => 'Please select your birth date';

  @override
  String get profileGender => 'Gender';

  @override
  String get profileGenderMale => 'Male';

  @override
  String get profileGenderFemale => 'Female';

  @override
  String get profileGenderUnspecified => 'Prefer not to say';

  @override
  String get qadaTrackingSubtitle => 'Automatically record missed prayers.';

  @override
  String get extraPrayerNotifications => 'Extra Prayer Reminders';

  @override
  String get extraPrayerNotificationsSubtitle =>
      'Get notifications for Duha, Ishraq and others.';

  @override
  String get profileStart => 'Start';

  @override
  String get profileSetupTitle => 'Start Prayer Tracking';

  @override
  String get profileUpdate => 'Update Profile';

  @override
  String get extraPrayers => 'Extra Prayers';

  @override
  String get prayerDuha => 'Duha (Forenoon)';

  @override
  String get prayerIshraq => 'Ishraq';

  @override
  String get prayerTahajjud => 'Tahajjud';

  @override
  String get prayerAwwabin => 'Awwabin';

  @override
  String get prayerDuhaDesc => '20 minutes after sunrise';

  @override
  String get prayerIshraqDesc => '15 minutes after sunrise';

  @override
  String get prayerTahajjudDesc => 'From midnight to dawn';

  @override
  String get prayerAwwabinDesc => 'Between Maghrib and Isha';

  @override
  String get tabQibla => 'Qibla';

  @override
  String get qiblaCompassTitle => 'Qibla Compass';

  @override
  String get qiblaCompassSubtitle =>
      'Hold your device flat and face the Qibla direction';

  @override
  String get qiblaFacingCorrect => 'Facing Qibla!';

  @override
  String get qiblaYourLocation => 'Your Location';

  @override
  String get qiblaKaabaDirection => 'Kaaba Direction';

  @override
  String get qiblaLoading => 'Loading compass...';

  @override
  String get qiblaLocationPermissionRequired =>
      'Location permission is required to calculate Qibla direction.';

  @override
  String get qiblaLocationServiceDisabled =>
      'Location services are disabled. Please enable them.';

  @override
  String get qiblaLocationFetchError =>
      'Could not get location. Please try again.';

  @override
  String get qiblaGenericError => 'An error occurred. Please try again.';

  @override
  String get qiblaRetry => 'Retry';

  @override
  String get qiblaOpenSettings => 'Open Settings';

  @override
  String get directionNorth => 'North';

  @override
  String get directionNorthEast => 'Northeast';

  @override
  String get directionEast => 'East';

  @override
  String get directionSouthEast => 'Southeast';

  @override
  String get directionSouth => 'South';

  @override
  String get directionSouthWest => 'Southwest';

  @override
  String get directionWest => 'West';

  @override
  String get directionNorthWest => 'Northwest';

  @override
  String get profileSettings => 'Profile Settings';

  @override
  String get profileSave => 'Save';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get profilePersonalInfo => 'Personal Information';

  @override
  String get qadaSettings => 'Qada Settings';

  @override
  String get appPurposeDescription =>
      'This app helps you track prayer times, mark your prayers, and manage your qada prayers.';

  @override
  String get share => 'Share';

  @override
  String get exportExcel => 'Export as Excel';

  @override
  String get excelExported => 'Excel file saved';

  @override
  String get excelExportError => 'Error saving Excel file';

  @override
  String get qadaDetailTitle => 'Qada Detail';

  @override
  String get qadaDetailDate => 'Date';

  @override
  String get qadaDetailPrayer => 'Prayer Time';

  @override
  String get qadaDetailMissedAt => 'Missed At';

  @override
  String get qadaDetailStatus => 'Status';

  @override
  String get qadaStatusPending => 'Pending';

  @override
  String get qadaStatusCompleted => 'Completed';

  @override
  String get qiblaCalibrationTitle => 'Compass Calibration';

  @override
  String get qiblaCalibrationMessage =>
      'Move your phone in a figure-8 motion to calibrate the compass.';

  @override
  String get qiblaCalibrationButton => 'Calibrate';

  @override
  String get qiblaCameraMode => 'Camera Mode';

  @override
  String get qiblaCompassMode => 'Compass Mode';

  @override
  String get qiblaCameraPermissionRequired => 'Camera permission required';

  @override
  String get cameraPermissionDenied => 'Camera permission denied';

  @override
  String get calibrateCompass => 'Calibrate';

  @override
  String get calibrateCompassDesc =>
      'Move your phone in a figure-8 motion for more accurate results.';

  @override
  String get arMode => 'AR';

  @override
  String get holdVertical => 'Hold phone vertically and point to Qibla';

  @override
  String get compassCalibrating => 'Calibrating Compass...';
}
