import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'Vakit'**
  String get appTitle;

  /// No description provided for @homeGreeting.
  ///
  /// In tr, this message translates to:
  /// **'Hoş geldin'**
  String get homeGreeting;

  /// No description provided for @homeGreetingSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Huzurlu bir gün dileriz'**
  String get homeGreetingSubtitle;

  /// No description provided for @tabHome.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfa'**
  String get tabHome;

  /// No description provided for @tabCities.
  ///
  /// In tr, this message translates to:
  /// **'Şehirler'**
  String get tabCities;

  /// No description provided for @tabMyPrayers.
  ///
  /// In tr, this message translates to:
  /// **'Namazlarım'**
  String get tabMyPrayers;

  /// No description provided for @tabQuran.
  ///
  /// In tr, this message translates to:
  /// **'Kuran'**
  String get tabQuran;

  /// No description provided for @tabSettings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get tabSettings;

  /// No description provided for @locationLoading.
  ///
  /// In tr, this message translates to:
  /// **'Konum alınıyor...'**
  String get locationLoading;

  /// No description provided for @locationError.
  ///
  /// In tr, this message translates to:
  /// **'Konum hatası'**
  String get locationError;

  /// No description provided for @genericError.
  ///
  /// In tr, this message translates to:
  /// **'Bir şeyler ters gitti'**
  String get genericError;

  /// No description provided for @nextPrayerLabel.
  ///
  /// In tr, this message translates to:
  /// **'Bir sonraki namaz'**
  String get nextPrayerLabel;

  /// No description provided for @remainingLabel.
  ///
  /// In tr, this message translates to:
  /// **'kaldı'**
  String get remainingLabel;

  /// No description provided for @locationsHeader.
  ///
  /// In tr, this message translates to:
  /// **'Takip edilen konumlar'**
  String get locationsHeader;

  /// No description provided for @locationsSubhead.
  ///
  /// In tr, this message translates to:
  /// **'3 konuma kadar ekleyebilir ve hepsini aynı anda görebilirsin.'**
  String get locationsSubhead;

  /// No description provided for @addLocation.
  ///
  /// In tr, this message translates to:
  /// **'Konum ekle'**
  String get addLocation;

  /// No description provided for @currentLocation.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut Konum'**
  String get currentLocation;

  /// No description provided for @manualLocation.
  ///
  /// In tr, this message translates to:
  /// **'Manuel Konum'**
  String get manualLocation;

  /// Warns user when max tracked locations reached
  ///
  /// In tr, this message translates to:
  /// **'En fazla {count} konum kaydedebilirsin.'**
  String maxLocationsReached(int count);

  /// No description provided for @addLocationTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni konum ekle'**
  String get addLocationTitle;

  /// No description provided for @addLocationDescription.
  ///
  /// In tr, this message translates to:
  /// **'Şehir, ilçe veya tam adres girerek konum ekleyebilirsin.'**
  String get addLocationDescription;

  /// No description provided for @addressFieldLabel.
  ///
  /// In tr, this message translates to:
  /// **'Adres veya şehir'**
  String get addressFieldLabel;

  /// No description provided for @addressFieldHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn. Adana Seyhan'**
  String get addressFieldHint;

  /// No description provided for @labelFieldLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kart adı (isteğe bağlı)'**
  String get labelFieldLabel;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @setActive.
  ///
  /// In tr, this message translates to:
  /// **'Aktif yap'**
  String get setActive;

  /// No description provided for @active.
  ///
  /// In tr, this message translates to:
  /// **'Aktif'**
  String get active;

  /// No description provided for @delete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// No description provided for @locationSaved.
  ///
  /// In tr, this message translates to:
  /// **'Konum kaydedildi.'**
  String get locationSaved;

  /// No description provided for @locationDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Konum silindi.'**
  String get locationDeleted;

  /// No description provided for @locationSearchFailed.
  ///
  /// In tr, this message translates to:
  /// **'Adres bulunamadı. Lütfen farklı bir ifade deneyin.'**
  String get locationSearchFailed;

  /// No description provided for @languageTitle.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama Dili'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe, İngilizce ve Arapça arasında geçiş yap.'**
  String get languageSubtitle;

  /// No description provided for @languageTurkish.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get languageTurkish;

  /// No description provided for @languageEnglish.
  ///
  /// In tr, this message translates to:
  /// **'İngilizce'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In tr, this message translates to:
  /// **'Arapça'**
  String get languageArabic;

  /// No description provided for @languageChanged.
  ///
  /// In tr, this message translates to:
  /// **'Dil güncellendi.'**
  String get languageChanged;

  /// No description provided for @citiesScreenTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şehir paneli'**
  String get citiesScreenTitle;

  /// No description provided for @citiesRefreshAction.
  ///
  /// In tr, this message translates to:
  /// **'Namaz özetlerini yenile'**
  String get citiesRefreshAction;

  /// No description provided for @citiesDeleteConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu şehri listeden kaldırmak istiyor musun?'**
  String get citiesDeleteConfirm;

  /// No description provided for @citiesCardSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu konuma ait sonraki namazı takip et.'**
  String get citiesCardSubtitle;

  /// No description provided for @citiesEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Henüz şehir yok'**
  String get citiesEmptyTitle;

  /// No description provided for @citiesEmptyDescription.
  ///
  /// In tr, this message translates to:
  /// **'Manuel şehir ekleyerek veya GPS\'i yenileyerek başlayabilirsin.'**
  String get citiesEmptyDescription;

  /// No description provided for @citiesManageButton.
  ///
  /// In tr, this message translates to:
  /// **'Şehir panelini aç'**
  String get citiesManageButton;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In tr, this message translates to:
  /// **'Konum izni reddedildi. Lütfen ayarlardan aktif edin.'**
  String get locationPermissionDenied;

  /// No description provided for @gpsRefresh.
  ///
  /// In tr, this message translates to:
  /// **'Konumu yenile'**
  String get gpsRefresh;

  /// No description provided for @gpsRefreshing.
  ///
  /// In tr, this message translates to:
  /// **'Konum güncelleniyor...'**
  String get gpsRefreshing;

  /// No description provided for @emptyTrackedLocations.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kayıtlı konum yok.'**
  String get emptyTrackedLocations;

  /// No description provided for @addressRequired.
  ///
  /// In tr, this message translates to:
  /// **'Adres alanı boş bırakılamaz.'**
  String get addressRequired;

  /// No description provided for @settingsLoadingMessage.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar yükleniyor...'**
  String get settingsLoadingMessage;

  /// No description provided for @locationPermissionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Konum izni gerekli'**
  String get locationPermissionTitle;

  /// No description provided for @locationPermissionDeniedBody.
  ///
  /// In tr, this message translates to:
  /// **'Namaz vakitleri için konum erişimi vermeli ya da manuel şehir seçmelisiniz.'**
  String get locationPermissionDeniedBody;

  /// No description provided for @locationPermissionPermanentBody.
  ///
  /// In tr, this message translates to:
  /// **'Konum izni kalıcı olarak reddedildi. Lütfen ayarlardan izin verin veya manuel seçim yapın.'**
  String get locationPermissionPermanentBody;

  /// No description provided for @locationUpdatedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Konum güncellendi'**
  String get locationUpdatedTitle;

  /// No description provided for @locationUpdatedBodyAuto.
  ///
  /// In tr, this message translates to:
  /// **'Namaz vakitleri yeni GPS konumunuza göre güncellenecek.'**
  String get locationUpdatedBodyAuto;

  /// No description provided for @locationUpdatedBodyManual.
  ///
  /// In tr, this message translates to:
  /// **'{location} için namaz vakitleri güncellenecek.'**
  String locationUpdatedBodyManual(String location);

  /// No description provided for @errorGenericTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bir hata oluştu'**
  String get errorGenericTitle;

  /// No description provided for @locationFetchError.
  ///
  /// In tr, this message translates to:
  /// **'Konum yenilenemedi. Lütfen manuel şehir seçmeyi deneyin.'**
  String get locationFetchError;

  /// No description provided for @locationSelectCityError.
  ///
  /// In tr, this message translates to:
  /// **'Konumu güncellemeden önce bir şehir seçin.'**
  String get locationSelectCityError;

  /// No description provided for @locationUpdateError.
  ///
  /// In tr, this message translates to:
  /// **'Manuel konum güncellenirken bir hata oluştu.'**
  String get locationUpdateError;

  /// No description provided for @notificationPermissionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim izni'**
  String get notificationPermissionTitle;

  /// No description provided for @notificationPermissionBody.
  ///
  /// In tr, this message translates to:
  /// **'Namaz hatırlatmaları almak için bildirim iznini açın.'**
  String get notificationPermissionBody;

  /// No description provided for @languageChangeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Dil güncellendi'**
  String get languageChangeTitle;

  /// No description provided for @languageChangeDescription.
  ///
  /// In tr, this message translates to:
  /// **'Tam çeviri için uygulamayı yeniden başlatmanız gerekebilir.'**
  String get languageChangeDescription;

  /// No description provided for @settingsResetDialogTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ayarları sıfırla'**
  String get settingsResetDialogTitle;

  /// No description provided for @settingsResetDialogBody.
  ///
  /// In tr, this message translates to:
  /// **'Tüm ayarları varsayılan değerlerine sıfırlamak istediğinize emin misiniz?'**
  String get settingsResetDialogBody;

  /// No description provided for @settingsResetDialogConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Sıfırla'**
  String get settingsResetDialogConfirm;

  /// No description provided for @settingsResetSuccessTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlandı'**
  String get settingsResetSuccessTitle;

  /// No description provided for @settingsResetSuccessBody.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar varsayılan değerlere döndürüldü.'**
  String get settingsResetSuccessBody;

  /// No description provided for @settingsResetError.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar sıfırlanırken bir hata oluştu.'**
  String get settingsResetError;

  /// No description provided for @dialogOk.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get dialogOk;

  /// No description provided for @settingsLocationSection.
  ///
  /// In tr, this message translates to:
  /// **'Konum'**
  String get settingsLocationSection;

  /// No description provided for @settingsNotificationsSection.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get settingsNotificationsSection;

  /// No description provided for @settingsInterfaceSection.
  ///
  /// In tr, this message translates to:
  /// **'Arayüz'**
  String get settingsInterfaceSection;

  /// No description provided for @settingsLocationMethodLabel.
  ///
  /// In tr, this message translates to:
  /// **'Konum nasıl belirlensin?'**
  String get settingsLocationMethodLabel;

  /// No description provided for @settingsLocationMethodAuto.
  ///
  /// In tr, this message translates to:
  /// **'Otomatik'**
  String get settingsLocationMethodAuto;

  /// No description provided for @settingsLocationMethodManual.
  ///
  /// In tr, this message translates to:
  /// **'Manuel'**
  String get settingsLocationMethodManual;

  /// No description provided for @settingsUpdateLocation.
  ///
  /// In tr, this message translates to:
  /// **'Konumu güncelle'**
  String get settingsUpdateLocation;

  /// No description provided for @settingsSelectCityPlaceholder.
  ///
  /// In tr, this message translates to:
  /// **'İl seçin'**
  String get settingsSelectCityPlaceholder;

  /// No description provided for @settingsDistrictHint.
  ///
  /// In tr, this message translates to:
  /// **'İlçe (opsiyonel)'**
  String get settingsDistrictHint;

  /// No description provided for @settingsCurrentLocationLabel.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut konum: {label}'**
  String settingsCurrentLocationLabel(String label);

  /// No description provided for @settingsCurrentLocationGps.
  ///
  /// In tr, this message translates to:
  /// **'GPS Koordinatları'**
  String get settingsCurrentLocationGps;

  /// No description provided for @settingsLatitudeLongitude.
  ///
  /// In tr, this message translates to:
  /// **'Enlem: {lat}, Boylam: {lon}'**
  String settingsLatitudeLongitude(String lat, String lon);

  /// No description provided for @settingsNotificationsToggle.
  ///
  /// In tr, this message translates to:
  /// **'Namaz vakti bildirimleri'**
  String get settingsNotificationsToggle;

  /// No description provided for @settingsNotificationLeadTime.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler ne kadar önce gelsin?'**
  String get settingsNotificationLeadTime;

  /// No description provided for @settingsNotificationMinutesSuffix.
  ///
  /// In tr, this message translates to:
  /// **'dakika'**
  String get settingsNotificationMinutesSuffix;

  /// No description provided for @settingsNotificationSound.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim sesi'**
  String get settingsNotificationSound;

  /// No description provided for @settingsNotificationVibration.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim titreşimi'**
  String get settingsNotificationVibration;

  /// No description provided for @settingsShowArabicText.
  ///
  /// In tr, this message translates to:
  /// **'Arapça metinleri göster'**
  String get settingsShowArabicText;

  /// No description provided for @settingsShowHijriDate.
  ///
  /// In tr, this message translates to:
  /// **'Hicri tarihi göster'**
  String get settingsShowHijriDate;

  /// No description provided for @settingsShowGregorianDate.
  ///
  /// In tr, this message translates to:
  /// **'Miladi tarihi göster'**
  String get settingsShowGregorianDate;

  /// No description provided for @settingsResetButton.
  ///
  /// In tr, this message translates to:
  /// **'Tüm ayarları sıfırla'**
  String get settingsResetButton;

  /// No description provided for @settingsAppVersionLabel.
  ///
  /// In tr, this message translates to:
  /// **'Namaz Vakti v{version}'**
  String settingsAppVersionLabel(String version);

  /// No description provided for @settingsAppCopyright.
  ///
  /// In tr, this message translates to:
  /// **'© 2025 Tüm hakları saklıdır'**
  String get settingsAppCopyright;

  /// No description provided for @settingsCityPickerTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şehir seçin'**
  String get settingsCityPickerTitle;

  /// No description provided for @settingsCitySearchHint.
  ///
  /// In tr, this message translates to:
  /// **'Şehir ara...'**
  String get settingsCitySearchHint;

  /// No description provided for @themePaletteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tema Paleti'**
  String get themePaletteTitle;

  /// No description provided for @themePaletteSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Hoşunuza giden renk ailesini ve yumuşaklık seviyesini seçin.'**
  String get themePaletteSubtitle;

  /// No description provided for @themeSofteningLabel.
  ///
  /// In tr, this message translates to:
  /// **'Renk Yumuşatma'**
  String get themeSofteningLabel;

  /// No description provided for @themeSofteningValue.
  ///
  /// In tr, this message translates to:
  /// **'%{percent}'**
  String themeSofteningValue(int percent);

  /// No description provided for @themeSofteningDescription.
  ///
  /// In tr, this message translates to:
  /// **'Arka plan tonlarını yumuşatarak daha parlak veya kontrastlı bir arayüz seçebilirsiniz.'**
  String get themeSofteningDescription;

  /// No description provided for @themePaletteOliveName.
  ///
  /// In tr, this message translates to:
  /// **'Zeytin Yeşili'**
  String get themePaletteOliveName;

  /// No description provided for @themePaletteOliveDescription.
  ///
  /// In tr, this message translates to:
  /// **'Klasik Vakit görünümü'**
  String get themePaletteOliveDescription;

  /// No description provided for @themePaletteDesertName.
  ///
  /// In tr, this message translates to:
  /// **'Çöl Günbatımı'**
  String get themePaletteDesertName;

  /// No description provided for @themePaletteDesertDescription.
  ///
  /// In tr, this message translates to:
  /// **'Sıcak kum ve amber tonları'**
  String get themePaletteDesertDescription;

  /// No description provided for @themePaletteMidnightName.
  ///
  /// In tr, this message translates to:
  /// **'Gece Mavisi'**
  String get themePaletteMidnightName;

  /// No description provided for @themePaletteMidnightDescription.
  ///
  /// In tr, this message translates to:
  /// **'Serin gece ve ay ışığı'**
  String get themePaletteMidnightDescription;

  /// No description provided for @prayerImsak.
  ///
  /// In tr, this message translates to:
  /// **'İmsak'**
  String get prayerImsak;

  /// No description provided for @prayerSunrise.
  ///
  /// In tr, this message translates to:
  /// **'Güneş'**
  String get prayerSunrise;

  /// No description provided for @prayerDhuhr.
  ///
  /// In tr, this message translates to:
  /// **'Öğle'**
  String get prayerDhuhr;

  /// No description provided for @prayerAsr.
  ///
  /// In tr, this message translates to:
  /// **'İkindi'**
  String get prayerAsr;

  /// No description provided for @prayerMaghrib.
  ///
  /// In tr, this message translates to:
  /// **'Akşam'**
  String get prayerMaghrib;

  /// No description provided for @prayerIsha.
  ///
  /// In tr, this message translates to:
  /// **'Yatsı'**
  String get prayerIsha;

  /// No description provided for @prayerFajr.
  ///
  /// In tr, this message translates to:
  /// **'Sabah'**
  String get prayerFajr;

  /// No description provided for @dailyPrayers.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Namazlar'**
  String get dailyPrayers;

  /// No description provided for @todaysDate.
  ///
  /// In tr, this message translates to:
  /// **'Bugünün Tarihi'**
  String get todaysDate;

  /// No description provided for @todaysProgress.
  ///
  /// In tr, this message translates to:
  /// **'Bugünün İlerlemesi'**
  String get todaysProgress;

  /// No description provided for @keepUpGoodWork.
  ///
  /// In tr, this message translates to:
  /// **'Böyle devam et!'**
  String get keepUpGoodWork;

  /// No description provided for @complete.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlandı'**
  String get complete;

  /// No description provided for @completed.
  ///
  /// In tr, this message translates to:
  /// **'TAMAMLANDI'**
  String get completed;

  /// No description provided for @missed.
  ///
  /// In tr, this message translates to:
  /// **'KAÇIRILDI'**
  String get missed;

  /// No description provided for @pending.
  ///
  /// In tr, this message translates to:
  /// **'BEKLİYOR'**
  String get pending;

  /// No description provided for @done.
  ///
  /// In tr, this message translates to:
  /// **'Kılındı'**
  String get done;

  /// No description provided for @missedPrayer.
  ///
  /// In tr, this message translates to:
  /// **'Kaçırıldı'**
  String get missedPrayer;

  /// No description provided for @remaining.
  ///
  /// In tr, this message translates to:
  /// **'kaldı'**
  String get remaining;

  /// No description provided for @nextPrayer.
  ///
  /// In tr, this message translates to:
  /// **'Bir sonraki namaz'**
  String get nextPrayer;

  /// No description provided for @qadaTracking.
  ///
  /// In tr, this message translates to:
  /// **'Kaza Takibi'**
  String get qadaTracking;

  /// No description provided for @qadaTrackingOn.
  ///
  /// In tr, this message translates to:
  /// **'Kaza takibi açık'**
  String get qadaTrackingOn;

  /// No description provided for @qadaTrackingOff.
  ///
  /// In tr, this message translates to:
  /// **'Kaza takibi kapalı'**
  String get qadaTrackingOff;

  /// No description provided for @noPendingQada.
  ///
  /// In tr, this message translates to:
  /// **'Harika! Bekleyen kaza namazın yok.'**
  String get noPendingQada;

  /// No description provided for @pendingQadaMessage.
  ///
  /// In tr, this message translates to:
  /// **'{count} vakit bekliyor. Tamamladıkça işaretle.'**
  String pendingQadaMessage(int count);

  /// No description provided for @table.
  ///
  /// In tr, this message translates to:
  /// **'Tablo'**
  String get table;

  /// No description provided for @widget.
  ///
  /// In tr, this message translates to:
  /// **'Widget'**
  String get widget;

  /// No description provided for @pendingQadaPrayers.
  ///
  /// In tr, this message translates to:
  /// **'Bekleyen Kaza Namazları'**
  String get pendingQadaPrayers;

  /// No description provided for @noRecordsYet.
  ///
  /// In tr, this message translates to:
  /// **'Şu an bekleyen kayıt yok.'**
  String get noRecordsYet;

  /// No description provided for @date.
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get date;

  /// No description provided for @prayerTime.
  ///
  /// In tr, this message translates to:
  /// **'Vakit'**
  String get prayerTime;

  /// No description provided for @recorded.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedildi'**
  String get recorded;

  /// No description provided for @completedDate.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlandı'**
  String get completedDate;

  /// No description provided for @shareCSV.
  ///
  /// In tr, this message translates to:
  /// **'CSV paylaş'**
  String get shareCSV;

  /// No description provided for @copyToClipboard.
  ///
  /// In tr, this message translates to:
  /// **'Panoya kopyala'**
  String get copyToClipboard;

  /// No description provided for @tableCopied.
  ///
  /// In tr, this message translates to:
  /// **'Tablo panoya kopyalandı'**
  String get tableCopied;

  /// No description provided for @qadaTable.
  ///
  /// In tr, this message translates to:
  /// **'Kaza namazı tablosu'**
  String get qadaTable;

  /// No description provided for @currentQadaSummary.
  ///
  /// In tr, this message translates to:
  /// **'Güncel kaza namazı özetim'**
  String get currentQadaSummary;

  /// No description provided for @editProfile.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get editProfile;

  /// No description provided for @ageYears.
  ///
  /// In tr, this message translates to:
  /// **'yaş'**
  String get ageYears;

  /// No description provided for @hijriAge.
  ///
  /// In tr, this message translates to:
  /// **'Hicri'**
  String get hijriAge;

  /// No description provided for @profileSetupSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel tercihlerini ekle, kaza ve nafile ibadetlerini takip et.'**
  String get profileSetupSubtitle;

  /// No description provided for @profileName.
  ///
  /// In tr, this message translates to:
  /// **'İsim'**
  String get profileName;

  /// No description provided for @profileNameRequired.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen adını yaz'**
  String get profileNameRequired;

  /// No description provided for @profileNameMinLength.
  ///
  /// In tr, this message translates to:
  /// **'İsim en az 2 karakter olmalı'**
  String get profileNameMinLength;

  /// No description provided for @profileBirthDate.
  ///
  /// In tr, this message translates to:
  /// **'Doğum Tarihi'**
  String get profileBirthDate;

  /// No description provided for @profileBirthDateHelp.
  ///
  /// In tr, this message translates to:
  /// **'Doğum Tarihinizi Seçin'**
  String get profileBirthDateHelp;

  /// No description provided for @profileSelectDate.
  ///
  /// In tr, this message translates to:
  /// **'Tarih seçin'**
  String get profileSelectDate;

  /// No description provided for @profileBirthDateRequired.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen doğum tarihinizi seçin'**
  String get profileBirthDateRequired;

  /// No description provided for @profileGender.
  ///
  /// In tr, this message translates to:
  /// **'Cinsiyet'**
  String get profileGender;

  /// No description provided for @profileGenderMale.
  ///
  /// In tr, this message translates to:
  /// **'Erkek'**
  String get profileGenderMale;

  /// No description provided for @profileGenderFemale.
  ///
  /// In tr, this message translates to:
  /// **'Kadın'**
  String get profileGenderFemale;

  /// No description provided for @profileGenderUnspecified.
  ///
  /// In tr, this message translates to:
  /// **'Belirtmek istemiyorum'**
  String get profileGenderUnspecified;

  /// No description provided for @qadaTrackingSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kaçırdığın vakitleri otomatik kaydedelim.'**
  String get qadaTrackingSubtitle;

  /// No description provided for @extraPrayerNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Nafile Hatırlatmaları'**
  String get extraPrayerNotifications;

  /// No description provided for @extraPrayerNotificationsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Duha, İşrak ve diğerlerini bildirim olarak al.'**
  String get extraPrayerNotificationsSubtitle;

  /// No description provided for @profileStart.
  ///
  /// In tr, this message translates to:
  /// **'Başla'**
  String get profileStart;

  /// No description provided for @profileSetupTitle.
  ///
  /// In tr, this message translates to:
  /// **'Namaz Takibini Başlat'**
  String get profileSetupTitle;

  /// No description provided for @profileUpdate.
  ///
  /// In tr, this message translates to:
  /// **'Profilini Güncelle'**
  String get profileUpdate;

  /// No description provided for @extraPrayers.
  ///
  /// In tr, this message translates to:
  /// **'Ekstra İbadetler'**
  String get extraPrayers;

  /// No description provided for @prayerDuha.
  ///
  /// In tr, this message translates to:
  /// **'Duha (Kuşluk)'**
  String get prayerDuha;

  /// No description provided for @prayerIshraq.
  ///
  /// In tr, this message translates to:
  /// **'İşrak'**
  String get prayerIshraq;

  /// No description provided for @prayerTahajjud.
  ///
  /// In tr, this message translates to:
  /// **'Teheccüd'**
  String get prayerTahajjud;

  /// No description provided for @prayerAwwabin.
  ///
  /// In tr, this message translates to:
  /// **'Evvabin'**
  String get prayerAwwabin;

  /// No description provided for @prayerDuhaDesc.
  ///
  /// In tr, this message translates to:
  /// **'Güneş doğduktan sonra 20 dakika içinde'**
  String get prayerDuhaDesc;

  /// No description provided for @prayerIshraqDesc.
  ///
  /// In tr, this message translates to:
  /// **'Güneş doğduktan 15 dakika içinde'**
  String get prayerIshraqDesc;

  /// No description provided for @prayerTahajjudDesc.
  ///
  /// In tr, this message translates to:
  /// **'Gece yarısından seher vaktine kadar'**
  String get prayerTahajjudDesc;

  /// No description provided for @prayerAwwabinDesc.
  ///
  /// In tr, this message translates to:
  /// **'Akşam ile yatsı arası sessiz vakit'**
  String get prayerAwwabinDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
