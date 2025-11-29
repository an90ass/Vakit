// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Vakit';

  @override
  String get homeGreeting => 'Hoş geldin';

  @override
  String get homeGreetingSubtitle => 'Huzurlu bir gün dileriz';

  @override
  String get tabHome => 'Ana Sayfa';

  @override
  String get tabCities => 'Şehirler';

  @override
  String get tabMyPrayers => 'Namazlarım';

  @override
  String get tabQuran => 'Kuran';

  @override
  String get tabSettings => 'Ayarlar';

  @override
  String get locationLoading => 'Konum alınıyor...';

  @override
  String get locationError => 'Konum hatası';

  @override
  String get genericError => 'Bir şeyler ters gitti';

  @override
  String get nextPrayerLabel => 'Bir sonraki namaz';

  @override
  String get remainingLabel => 'kaldı';

  @override
  String get locationsHeader => 'Takip edilen konumlar';

  @override
  String get locationsSubhead =>
      '3 konuma kadar ekleyebilir ve hepsini aynı anda görebilirsin.';

  @override
  String get addLocation => 'Konum ekle';

  @override
  String get currentLocation => 'Mevcut Konum';

  @override
  String get manualLocation => 'Manuel Konum';

  @override
  String maxLocationsReached(int count) {
    return 'En fazla $count konum kaydedebilirsin.';
  }

  @override
  String get addLocationTitle => 'Yeni konum ekle';

  @override
  String get addLocationDescription =>
      'Şehir, ilçe veya tam adres girerek konum ekleyebilirsin.';

  @override
  String get addressFieldLabel => 'Adres veya şehir';

  @override
  String get addressFieldHint => 'Örn. Adana Seyhan';

  @override
  String get labelFieldLabel => 'Kart adı (isteğe bağlı)';

  @override
  String get cancel => 'İptal';

  @override
  String get save => 'Kaydet';

  @override
  String get setActive => 'Aktif yap';

  @override
  String get active => 'Aktif';

  @override
  String get delete => 'Sil';

  @override
  String get locationSaved => 'Konum kaydedildi.';

  @override
  String get locationDeleted => 'Konum silindi.';

  @override
  String get locationSearchFailed =>
      'Adres bulunamadı. Lütfen farklı bir ifade deneyin.';

  @override
  String get languageTitle => 'Uygulama Dili';

  @override
  String get languageSubtitle =>
      'Türkçe, İngilizce ve Arapça arasında geçiş yap.';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageEnglish => 'İngilizce';

  @override
  String get languageArabic => 'Arapça';

  @override
  String get languageChanged => 'Dil güncellendi.';

  @override
  String get citiesScreenTitle => 'Şehir paneli';

  @override
  String get citiesRefreshAction => 'Namaz özetlerini yenile';

  @override
  String get citiesDeleteConfirm =>
      'Bu şehri listeden kaldırmak istiyor musun?';

  @override
  String get citiesCardSubtitle => 'Bu konuma ait sonraki namazı takip et.';

  @override
  String get citiesEmptyTitle => 'Henüz şehir yok';

  @override
  String get citiesEmptyDescription =>
      'Manuel şehir ekleyerek veya GPS\'i yenileyerek başlayabilirsin.';

  @override
  String get citiesManageButton => 'Şehir panelini aç';

  @override
  String get locationPermissionDenied =>
      'Konum izni reddedildi. Lütfen ayarlardan aktif edin.';

  @override
  String get gpsRefresh => 'Konumu yenile';

  @override
  String get gpsRefreshing => 'Konum güncelleniyor...';

  @override
  String get emptyTrackedLocations => 'Henüz kayıtlı konum yok.';

  @override
  String get addressRequired => 'Adres alanı boş bırakılamaz.';

  @override
  String get settingsLoadingMessage => 'Ayarlar yükleniyor...';

  @override
  String get locationPermissionTitle => 'Konum izni gerekli';

  @override
  String get locationPermissionDeniedBody =>
      'Namaz vakitleri için konum erişimi vermeli ya da manuel şehir seçmelisiniz.';

  @override
  String get locationPermissionPermanentBody =>
      'Konum izni kalıcı olarak reddedildi. Lütfen ayarlardan izin verin veya manuel seçim yapın.';

  @override
  String get locationUpdatedTitle => 'Konum güncellendi';

  @override
  String get locationUpdatedBodyAuto =>
      'Namaz vakitleri yeni GPS konumunuza göre güncellenecek.';

  @override
  String locationUpdatedBodyManual(String location) {
    return '$location için namaz vakitleri güncellenecek.';
  }

  @override
  String get errorGenericTitle => 'Bir hata oluştu';

  @override
  String get locationFetchError =>
      'Konum yenilenemedi. Lütfen manuel şehir seçmeyi deneyin.';

  @override
  String get locationSelectCityError =>
      'Konumu güncellemeden önce bir şehir seçin.';

  @override
  String get locationUpdateError =>
      'Manuel konum güncellenirken bir hata oluştu.';

  @override
  String get notificationPermissionTitle => 'Bildirim izni';

  @override
  String get notificationPermissionBody =>
      'Namaz hatırlatmaları almak için bildirim iznini açın.';

  @override
  String get languageChangeTitle => 'Dil güncellendi';

  @override
  String get languageChangeDescription =>
      'Tam çeviri için uygulamayı yeniden başlatmanız gerekebilir.';

  @override
  String get settingsResetDialogTitle => 'Ayarları sıfırla';

  @override
  String get settingsResetDialogBody =>
      'Tüm ayarları varsayılan değerlerine sıfırlamak istediğinize emin misiniz?';

  @override
  String get settingsResetDialogConfirm => 'Sıfırla';

  @override
  String get settingsResetSuccessTitle => 'Tamamlandı';

  @override
  String get settingsResetSuccessBody =>
      'Ayarlar varsayılan değerlere döndürüldü.';

  @override
  String get settingsResetError => 'Ayarlar sıfırlanırken bir hata oluştu.';

  @override
  String get dialogOk => 'Tamam';

  @override
  String get settingsLocationSection => 'Konum';

  @override
  String get settingsNotificationsSection => 'Bildirimler';

  @override
  String get settingsInterfaceSection => 'Arayüz';

  @override
  String get settingsLocationMethodLabel => 'Konum nasıl belirlensin?';

  @override
  String get settingsLocationMethodAuto => 'Otomatik';

  @override
  String get settingsLocationMethodManual => 'Manuel';

  @override
  String get settingsUpdateLocation => 'Konumu güncelle';

  @override
  String get settingsSelectCityPlaceholder => 'İl seçin';

  @override
  String get settingsDistrictHint => 'İlçe (opsiyonel)';

  @override
  String settingsCurrentLocationLabel(String label) {
    return 'Mevcut konum: $label';
  }

  @override
  String get settingsCurrentLocationGps => 'GPS Koordinatları';

  @override
  String settingsLatitudeLongitude(String lat, String lon) {
    return 'Enlem: $lat, Boylam: $lon';
  }

  @override
  String get settingsNotificationsToggle => 'Namaz vakti bildirimleri';

  @override
  String get settingsNotificationLeadTime =>
      'Bildirimler ne kadar önce gelsin?';

  @override
  String get settingsNotificationMinutesSuffix => 'dakika';

  @override
  String get settingsNotificationSound => 'Bildirim sesi';

  @override
  String get settingsNotificationVibration => 'Bildirim titreşimi';

  @override
  String get settingsShowArabicText => 'Arapça metinleri göster';

  @override
  String get settingsShowHijriDate => 'Hicri tarihi göster';

  @override
  String get settingsShowGregorianDate => 'Miladi tarihi göster';

  @override
  String get settingsResetButton => 'Tüm ayarları sıfırla';

  @override
  String settingsAppVersionLabel(String version) {
    return 'Namaz Vakti v$version';
  }

  @override
  String get settingsAppCopyright => '© 2025 Tüm hakları saklıdır';

  @override
  String get settingsCityPickerTitle => 'Şehir seçin';

  @override
  String get settingsCitySearchHint => 'Şehir ara...';

  @override
  String get themePaletteTitle => 'Tema Paleti';

  @override
  String get themePaletteSubtitle =>
      'Hoşunuza giden renk ailesini ve yumuşaklık seviyesini seçin.';

  @override
  String get themeSofteningLabel => 'Renk Yumuşatma';

  @override
  String themeSofteningValue(int percent) {
    return '%$percent';
  }

  @override
  String get themeSofteningDescription =>
      'Arka plan tonlarını yumuşatarak daha parlak veya kontrastlı bir arayüz seçebilirsiniz.';

  @override
  String get themePaletteOliveName => 'Zeytin Yeşili';

  @override
  String get themePaletteOliveDescription => 'Klasik Vakit görünümü';

  @override
  String get themePaletteDesertName => 'Çöl Günbatımı';

  @override
  String get themePaletteDesertDescription => 'Sıcak kum ve amber tonları';

  @override
  String get themePaletteMidnightName => 'Gece Mavisi';

  @override
  String get themePaletteMidnightDescription => 'Serin gece ve ay ışığı';

  @override
  String get prayerImsak => 'İmsak';

  @override
  String get prayerSunrise => 'Güneş';

  @override
  String get prayerDhuhr => 'Öğle';

  @override
  String get prayerAsr => 'İkindi';

  @override
  String get prayerMaghrib => 'Akşam';

  @override
  String get prayerIsha => 'Yatsı';

  @override
  String get prayerFajr => 'Sabah';

  @override
  String get dailyPrayers => 'Günlük Namazlar';

  @override
  String get todaysDate => 'Bugünün Tarihi';

  @override
  String get todaysProgress => 'Bugünün İlerlemesi';

  @override
  String get keepUpGoodWork => 'Böyle devam et!';

  @override
  String get complete => 'Tamamlandı';

  @override
  String get completed => 'TAMAMLANDI';

  @override
  String get missed => 'KAÇIRILDI';

  @override
  String get pending => 'BEKLİYOR';

  @override
  String get done => 'Kılındı';

  @override
  String get missedPrayer => 'Kaçırıldı';

  @override
  String get remaining => 'kaldı';

  @override
  String get nextPrayer => 'Bir sonraki namaz';

  @override
  String get qadaTracking => 'Kaza Takibi';

  @override
  String get qadaTrackingOn => 'Kaza takibi açık';

  @override
  String get qadaTrackingOff => 'Kaza takibi kapalı';

  @override
  String get noPendingQada => 'Harika! Bekleyen kaza namazın yok.';

  @override
  String pendingQadaMessage(int count) {
    return '$count vakit bekliyor. Tamamladıkça işaretle.';
  }

  @override
  String get table => 'Tablo';

  @override
  String get widget => 'Widget';

  @override
  String get pendingQadaPrayers => 'Bekleyen Kaza Namazları';

  @override
  String get noRecordsYet => 'Şu an bekleyen kayıt yok.';

  @override
  String get date => 'Tarih';

  @override
  String get prayerTime => 'Vakit';

  @override
  String get recorded => 'Kaydedildi';

  @override
  String get completedDate => 'Tamamlandı';

  @override
  String get shareCSV => 'CSV paylaş';

  @override
  String get copyToClipboard => 'Panoya kopyala';

  @override
  String get tableCopied => 'Tablo panoya kopyalandı';

  @override
  String get qadaTable => 'Kaza namazı tablosu';

  @override
  String get currentQadaSummary => 'Güncel kaza namazı özetim';

  @override
  String get editProfile => 'Düzenle';

  @override
  String get ageYears => 'yaş';

  @override
  String get hijriAge => 'Hicri';

  @override
  String get profileSetupSubtitle =>
      'Kişisel tercihlerini ekle, kaza ve nafile ibadetlerini takip et.';

  @override
  String get profileName => 'İsim';

  @override
  String get profileNameRequired => 'Lütfen adını yaz';

  @override
  String get profileNameMinLength => 'İsim en az 2 karakter olmalı';

  @override
  String get profileBirthDate => 'Doğum Tarihi';

  @override
  String get profileBirthDateHelp => 'Doğum Tarihinizi Seçin';

  @override
  String get profileSelectDate => 'Tarih seçin';

  @override
  String get profileBirthDateRequired => 'Lütfen doğum tarihinizi seçin';

  @override
  String get profileGender => 'Cinsiyet';

  @override
  String get profileGenderMale => 'Erkek';

  @override
  String get profileGenderFemale => 'Kadın';

  @override
  String get profileGenderUnspecified => 'Belirtmek istemiyorum';

  @override
  String get qadaTrackingSubtitle =>
      'Kaçırdığın vakitleri otomatik kaydedelim.';

  @override
  String get extraPrayerNotifications => 'Nafile Hatırlatmaları';

  @override
  String get extraPrayerNotificationsSubtitle =>
      'Duha, İşrak ve diğerlerini bildirim olarak al.';

  @override
  String get profileStart => 'Başla';

  @override
  String get profileSetupTitle => 'Namaz Takibini Başlat';

  @override
  String get profileUpdate => 'Profilini Güncelle';

  @override
  String get extraPrayers => 'Ekstra İbadetler';

  @override
  String get prayerDuha => 'Duha (Kuşluk)';

  @override
  String get prayerIshraq => 'İşrak';

  @override
  String get prayerTahajjud => 'Teheccüd';

  @override
  String get prayerAwwabin => 'Evvabin';

  @override
  String get prayerDuhaDesc => 'Guneş doğduktan sonra 20 dakika icinde';

  @override
  String get prayerIshraqDesc => 'Guneş doğduktan 15 dakika icinde';

  @override
  String get prayerTahajjudDesc => 'Gece yarısından seher vaktine kadar';

  @override
  String get prayerAwwabinDesc => 'Akşam ile yatsı arası sessiz vakit';

  @override
  String get tabQibla => 'Kıble';

  @override
  String get qiblaCompassTitle => 'Kıble Pusulası';

  @override
  String get qiblaCompassSubtitle =>
      'Cihazınızı düz tutun ve kıble yönüne dönün';

  @override
  String get qiblaFacingCorrect => 'Kıble Yönünde!';

  @override
  String get qiblaYourLocation => 'Konumunuz';

  @override
  String get qiblaKaabaDirection => 'Kabe Yönü';

  @override
  String get qiblaLoading => 'Pusula yükleniyor...';

  @override
  String get qiblaLocationPermissionRequired =>
      'Kıble yönünü hesaplamak için konum izni gerekli.';

  @override
  String get qiblaLocationServiceDisabled =>
      'Konum servisleri kapalı. Lütfen açın.';

  @override
  String get qiblaLocationFetchError =>
      'Konum alınamadı. Lütfen tekrar deneyin.';

  @override
  String get qiblaGenericError => 'Bir hata oluştu. Lütfen tekrar deneyin.';

  @override
  String get qiblaRetry => 'Tekrar Dene';

  @override
  String get qiblaOpenSettings => 'Ayarları Aç';

  @override
  String get directionNorth => 'Kuzey';

  @override
  String get directionNorthEast => 'Kuzeydoğu';

  @override
  String get directionEast => 'Doğu';

  @override
  String get directionSouthEast => 'Güneydoğu';

  @override
  String get directionSouth => 'Güney';

  @override
  String get directionSouthWest => 'Güneybatı';

  @override
  String get directionWest => 'Batı';

  @override
  String get directionNorthWest => 'Kuzeybatı';

  @override
  String get profileSettings => 'Profil Ayarları';

  @override
  String get profileSave => 'Kaydet';

  @override
  String get profileSaved => 'Profil kaydedildi';

  @override
  String get profilePersonalInfo => 'Kişisel Bilgiler';

  @override
  String get qadaSettings => 'Kaza Ayarları';

  @override
  String get appPurposeDescription =>
      'Bu uygulama namaz vakitlerini takip etmenize, namazlarınızı işaretlemenize ve kaza namazlarınızı yönetmenize yardımcı olur.';

  @override
  String get share => 'Paylaş';

  @override
  String get exportExcel => 'Excel Olarak Kaydet';

  @override
  String get excelExported => 'Excel dosyası kaydedildi';

  @override
  String get excelExportError => 'Excel dosyası kaydedilirken hata oluştu';

  @override
  String get qadaDetailTitle => 'Kaza Detayı';

  @override
  String get qadaDetailDate => 'Tarih';

  @override
  String get qadaDetailPrayer => 'Namaz Vakti';

  @override
  String get qadaDetailMissedAt => 'Kaçırılma Zamanı';

  @override
  String get qadaDetailStatus => 'Durum';

  @override
  String get qadaStatusPending => 'Bekliyor';

  @override
  String get qadaStatusCompleted => 'Tamamlandı';

  @override
  String get qiblaCalibrationTitle => 'Pusula Kalibrasyonu';

  @override
  String get qiblaCalibrationMessage =>
      'Pusulayı kalibre etmek için telefonunuzu 8 şeklinde hareket ettirin.';

  @override
  String get qiblaCalibrationButton => 'Kalibre Et';

  @override
  String get qiblaCameraMode => 'Kamera Modu';

  @override
  String get qiblaCompassMode => 'Pusula Modu';

  @override
  String get qiblaCameraPermissionRequired => 'Kamera izni gerekli';

  @override
  String get cameraPermissionDenied => 'Kamera izni reddedildi';

  @override
  String get calibrateCompass => 'Kalibre';

  @override
  String get calibrateCompassDesc =>
      'Daha doğru sonuçlar için telefonunuzu 8 şeklinde hareket ettirin.';

  @override
  String get arMode => 'AR';

  @override
  String get holdVertical => 'Telefonu dik tutun ve Kıble\'ye doğrultun';

  @override
  String get compassCalibrating => 'Pusula Kalibre Ediliyor...';
}
