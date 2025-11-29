// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'وقت';

  @override
  String get homeGreeting => 'مرحبًا';

  @override
  String get homeGreetingSubtitle => 'نتمنى لك يومًا هادئًا';

  @override
  String get tabHome => 'الرئيسية';

  @override
  String get tabCities => 'المدن';

  @override
  String get tabMyPrayers => 'صلواتي';

  @override
  String get tabQuran => 'القرآن';

  @override
  String get tabSettings => 'الإعدادات';

  @override
  String get locationLoading => 'جارٍ جلب الموقع...';

  @override
  String get locationError => 'خطأ في الموقع';

  @override
  String get genericError => 'حدث خطأ ما';

  @override
  String get nextPrayerLabel => 'الصلاة القادمة';

  @override
  String get remainingLabel => 'متبقي';

  @override
  String get locationsHeader => 'المواقع المتابعة';

  @override
  String get locationsSubhead => 'تابع حتى ٣ أماكن وشاهدها معًا.';

  @override
  String get addLocation => 'أضف موقعًا';

  @override
  String get currentLocation => 'الموقع الحالي';

  @override
  String get manualLocation => 'موقع يدوي';

  @override
  String maxLocationsReached(int count) {
    return 'يمكنك حفظ ما يصل إلى $count مواقع.';
  }

  @override
  String get addLocationTitle => 'إضافة موقع جديد';

  @override
  String get addLocationDescription => 'اكتب مدينة أو عنوانًا كاملاً لإضافته.';

  @override
  String get addressFieldLabel => 'العنوان أو المدينة';

  @override
  String get addressFieldHint => 'مثال: أضنة سيهان';

  @override
  String get labelFieldLabel => 'اسم البطاقة (اختياري)';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get setActive => 'اجعله نشطًا';

  @override
  String get active => 'نشط';

  @override
  String get delete => 'حذف';

  @override
  String get locationSaved => 'تم حفظ الموقع.';

  @override
  String get locationDeleted => 'تم حذف الموقع.';

  @override
  String get locationSearchFailed => 'تعذر إيجاد العنوان. جرّب عبارة مختلفة.';

  @override
  String get languageTitle => 'لغة التطبيق';

  @override
  String get languageSubtitle => 'بدّل بين التركية والإنجليزية والعربية.';

  @override
  String get languageTurkish => 'التركية';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageChanged => 'تم تحديث اللغة.';

  @override
  String get citiesScreenTitle => 'لوحة المدن';

  @override
  String get citiesRefreshAction => 'تحديث ملخصات الصلوات';

  @override
  String get citiesDeleteConfirm => 'هل تريد إزالة هذه المدينة من قائمتك؟';

  @override
  String get citiesCardSubtitle => 'تابع الصلاة القادمة لهذه المدينة.';

  @override
  String get citiesEmptyTitle => 'لا توجد مدن بعد';

  @override
  String get citiesEmptyDescription => 'أضف مدينة يدويًا أو حدّث GPS للبدء.';

  @override
  String get citiesManageButton => 'افتح لوحة المدن';

  @override
  String get locationPermissionDenied =>
      'تم رفض إذن الموقع. فعّله من الإعدادات.';

  @override
  String get gpsRefresh => 'تحديث GPS';

  @override
  String get gpsRefreshing => 'جارٍ تحديث الموقع...';

  @override
  String get emptyTrackedLocations => 'لا توجد مواقع محفوظة بعد.';

  @override
  String get addressRequired => 'حقل العنوان لا يمكن أن يكون فارغًا.';

  @override
  String get settingsLoadingMessage => 'جارٍ تحميل الإعدادات...';

  @override
  String get locationPermissionTitle => 'يلزم إذن الموقع';

  @override
  String get locationPermissionDeniedBody =>
      'يجب منح إذن الموقع أو اختيار المدينة يدويًا للحصول على أوقات الصلاة.';

  @override
  String get locationPermissionPermanentBody =>
      'تم رفض إذن الموقع بشكل دائم. فعّله من الإعدادات أو اختر مدينة يدويًا.';

  @override
  String get locationUpdatedTitle => 'تم تحديث الموقع';

  @override
  String get locationUpdatedBodyAuto =>
      'سيتم تحديث أوقات الصلاة حسب موقع GPS الجديد.';

  @override
  String locationUpdatedBodyManual(String location) {
    return 'سيتم تحديث أوقات الصلاة لـ $location.';
  }

  @override
  String get errorGenericTitle => 'حدث خطأ';

  @override
  String get locationFetchError =>
      'تعذّر تحديث الموقع. جرّب اختيار مدينة يدويًا.';

  @override
  String get locationSelectCityError => 'يُرجى اختيار مدينة قبل تحديث الموقع.';

  @override
  String get locationUpdateError => 'حدث خطأ أثناء تحديث الموقع اليدوي.';

  @override
  String get notificationPermissionTitle => 'إذن الإشعارات';

  @override
  String get notificationPermissionBody =>
      'فعّل الإشعارات لتلقي تذكيرات الصلاة.';

  @override
  String get languageChangeTitle => 'تم تحديث اللغة';

  @override
  String get languageChangeDescription =>
      'قد تحتاج إلى إعادة تشغيل التطبيق لتطبيق الترجمة بالكامل.';

  @override
  String get settingsResetDialogTitle => 'إعادة تعيين الإعدادات';

  @override
  String get settingsResetDialogBody =>
      'هل أنت متأكد من إعادة جميع الإعدادات إلى الوضع الافتراضي؟';

  @override
  String get settingsResetDialogConfirm => 'إعادة';

  @override
  String get settingsResetSuccessTitle => 'تم';

  @override
  String get settingsResetSuccessBody =>
      'تمت إعادة الإعدادات إلى القيم الافتراضية.';

  @override
  String get settingsResetError => 'حدث خطأ أثناء إعادة الإعدادات.';

  @override
  String get dialogOk => 'حسنًا';

  @override
  String get settingsLocationSection => 'الموقع';

  @override
  String get settingsNotificationsSection => 'الإشعارات';

  @override
  String get settingsInterfaceSection => 'الواجهة';

  @override
  String get settingsLocationMethodLabel => 'كيف تريد تحديد الموقع؟';

  @override
  String get settingsLocationMethodAuto => 'تلقائي';

  @override
  String get settingsLocationMethodManual => 'يدوي';

  @override
  String get settingsUpdateLocation => 'تحديث الموقع';

  @override
  String get settingsSelectCityPlaceholder => 'اختر مدينة';

  @override
  String get settingsDistrictHint => 'الحي (اختياري)';

  @override
  String settingsCurrentLocationLabel(String label) {
    return 'الموقع الحالي: $label';
  }

  @override
  String get settingsCurrentLocationGps => 'إحداثيات GPS';

  @override
  String settingsLatitudeLongitude(String lat, String lon) {
    return 'خط العرض: $lat، خط الطول: $lon';
  }

  @override
  String get settingsNotificationsToggle => 'إشعارات أوقات الصلاة';

  @override
  String get settingsNotificationLeadTime => 'كم قبل الوقت تريد وصول التذكير؟';

  @override
  String get settingsNotificationMinutesSuffix => 'دقائق';

  @override
  String get settingsNotificationSound => 'الصوت';

  @override
  String get settingsNotificationVibration => 'الاهتزاز';

  @override
  String get settingsShowArabicText => 'عرض النص العربي';

  @override
  String get settingsShowHijriDate => 'عرض التاريخ الهجري';

  @override
  String get settingsShowGregorianDate => 'عرض التاريخ الميلادي';

  @override
  String get settingsResetButton => 'إعادة ضبط جميع الإعدادات';

  @override
  String settingsAppVersionLabel(String version) {
    return 'تطبيق وقت الإصدار v$version';
  }

  @override
  String get settingsAppCopyright => '© 2025 جميع الحقوق محفوظة';

  @override
  String get settingsCityPickerTitle => 'اختر مدينة';

  @override
  String get settingsCitySearchHint => 'ابحث عن مدينة...';

  @override
  String get themePaletteTitle => 'لوحة الألوان';

  @override
  String get themePaletteSubtitle =>
      'اختر عائلة الألوان ودرجة النعومة التي تناسبك.';

  @override
  String get themeSofteningLabel => 'تنعيم الألوان';

  @override
  String themeSofteningValue(int percent) {
    return '٪$percent';
  }

  @override
  String get themeSofteningDescription =>
      'يمكنك تنعيم الخلفيات للحصول على مظهر أكثر إشراقًا أو تركها منخفضة لتباين أعلى.';

  @override
  String get themePaletteOliveName => 'أخضر الزيتون';

  @override
  String get themePaletteOliveDescription =>
      'أخضر متوازن مع لمسات ذهبية هادئة.';

  @override
  String get themePaletteDesertName => 'غروب الصحراء';

  @override
  String get themePaletteDesertDescription =>
      'درجات الرمال الدافئة مع أضواء كهرمانية.';

  @override
  String get themePaletteMidnightName => 'أزرق منتصف الليل';

  @override
  String get themePaletteMidnightDescription =>
      'زرقة الليل الباردة مع لمسات ضوء القمر.';

  @override
  String get prayerImsak => 'الفجر';

  @override
  String get prayerSunrise => 'الشروق';

  @override
  String get prayerDhuhr => 'الظهر';

  @override
  String get prayerAsr => 'العصر';

  @override
  String get prayerMaghrib => 'المغرب';

  @override
  String get prayerIsha => 'العشاء';

  @override
  String get prayerFajr => 'الفجر';

  @override
  String get dailyPrayers => 'الصلوات اليومية';

  @override
  String get todaysDate => 'تاريخ اليوم';

  @override
  String get todaysProgress => 'تقدم اليوم';

  @override
  String get keepUpGoodWork => 'استمر في العمل الجيد!';

  @override
  String get complete => 'مكتمل';

  @override
  String get completed => 'مكتمل';

  @override
  String get missed => 'فائت';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get done => 'تم';

  @override
  String get missedPrayer => 'فائت';

  @override
  String get remaining => 'متبقي';

  @override
  String get nextPrayer => 'الصلاة القادمة';

  @override
  String get qadaTracking => 'تتبع القضاء';

  @override
  String get qadaTrackingOn => 'تتبع القضاء مفعل';

  @override
  String get qadaTrackingOff => 'تتبع القضاء معطل';

  @override
  String get noPendingQada => 'رائع! لا توجد صلوات قضاء معلقة.';

  @override
  String pendingQadaMessage(int count) {
    return '$count صلاة معلقة. ضع علامة عند الإكمال.';
  }

  @override
  String get table => 'جدول';

  @override
  String get widget => 'ودجت';

  @override
  String get pendingQadaPrayers => 'صلوات القضاء المعلقة';

  @override
  String get noRecordsYet => 'لا توجد سجلات معلقة حتى الآن.';

  @override
  String get date => 'التاريخ';

  @override
  String get prayerTime => 'الصلاة';

  @override
  String get recorded => 'مسجل';

  @override
  String get completedDate => 'مكتمل';

  @override
  String get shareCSV => 'مشاركة CSV';

  @override
  String get copyToClipboard => 'نسخ إلى الحافظة';

  @override
  String get tableCopied => 'تم نسخ الجدول إلى الحافظة';

  @override
  String get qadaTable => 'جدول صلاة القضاء';

  @override
  String get currentQadaSummary => 'ملخص القضاء الحالي';

  @override
  String get editProfile => 'تعديل';

  @override
  String get ageYears => 'سنة';

  @override
  String get hijriAge => 'هجري';

  @override
  String get profileSetupSubtitle =>
      'أضف تفضيلاتك الشخصية، تتبع صلاة القضاء والنوافل.';

  @override
  String get profileName => 'الاسم';

  @override
  String get profileNameRequired => 'الرجاء إدخال اسمك';

  @override
  String get profileNameMinLength => 'يجب أن يكون الاسم حرفين على الأقل';

  @override
  String get profileBirthDate => 'تاريخ الميلاد';

  @override
  String get profileBirthDateHelp => 'اختر تاريخ ميلادك';

  @override
  String get profileSelectDate => 'اختر التاريخ';

  @override
  String get profileBirthDateRequired => 'الرجاء اختيار تاريخ ميلادك';

  @override
  String get profileGender => 'الجنس';

  @override
  String get profileGenderMale => 'ذكر';

  @override
  String get profileGenderFemale => 'أنثى';

  @override
  String get profileGenderUnspecified => 'أفضل عدم الإفصاح';

  @override
  String get qadaTrackingSubtitle => 'سجل الصلوات الفائتة تلقائياً.';

  @override
  String get extraPrayerNotifications => 'تذكيرات النوافل';

  @override
  String get extraPrayerNotificationsSubtitle =>
      'احصل على إشعارات للضحى والإشراق وغيرها.';

  @override
  String get profileStart => 'ابدأ';

  @override
  String get profileSetupTitle => 'ابدأ تتبع الصلاة';

  @override
  String get profileUpdate => 'تحديث الملف الشخصي';

  @override
  String get extraPrayers => 'صلوات إضافية';

  @override
  String get prayerDuha => 'الضحى';

  @override
  String get prayerIshraq => 'الإشراق';

  @override
  String get prayerTahajjud => 'التهجد';

  @override
  String get prayerAwwabin => 'الأوابين';

  @override
  String get prayerDuhaDesc => 'بعد 20 دقيقة من شروق الشمس';

  @override
  String get prayerIshraqDesc => 'بعد 15 دقيقة من شروق الشمس';

  @override
  String get prayerTahajjudDesc => 'من منتصف الليل إلى الفجر';

  @override
  String get prayerAwwabinDesc => 'بين المغرب والعشاء';

  @override
  String get tabQibla => 'القبلة';

  @override
  String get qiblaCompassTitle => 'بوصلة القبلة';

  @override
  String get qiblaCompassSubtitle => 'امسك جهازك بشكل مستوٍ واتجه نحو القبلة';

  @override
  String get qiblaFacingCorrect => 'أنت تواجه القبلة!';

  @override
  String get qiblaYourLocation => 'موقعك';

  @override
  String get qiblaKaabaDirection => 'اتجاه الكعبة';

  @override
  String get qiblaLoading => 'جاري تحميل البوصلة...';

  @override
  String get qiblaLocationPermissionRequired =>
      'إذن الموقع مطلوب لحساب اتجاه القبلة.';

  @override
  String get qiblaLocationServiceDisabled =>
      'خدمات الموقع معطلة. الرجاء تفعيلها.';

  @override
  String get qiblaLocationFetchError =>
      'تعذر الحصول على الموقع. حاول مرة أخرى.';

  @override
  String get qiblaGenericError => 'حدث خطأ. حاول مرة أخرى.';

  @override
  String get qiblaRetry => 'إعادة المحاولة';

  @override
  String get qiblaOpenSettings => 'فتح الإعدادات';

  @override
  String get directionNorth => 'الشمال';

  @override
  String get directionNorthEast => 'الشمال الشرقي';

  @override
  String get directionEast => 'الشرق';

  @override
  String get directionSouthEast => 'الجنوب الشرقي';

  @override
  String get directionSouth => 'الجنوب';

  @override
  String get directionSouthWest => 'الجنوب الغربي';

  @override
  String get directionWest => 'الغرب';

  @override
  String get directionNorthWest => 'الشمال الغربي';

  @override
  String get profileSettings => 'إعدادات الملف الشخصي';

  @override
  String get profileSave => 'حفظ';

  @override
  String get profileSaved => 'تم حفظ الملف الشخصي';

  @override
  String get profilePersonalInfo => 'المعلومات الشخصية';

  @override
  String get qadaSettings => 'إعدادات القضاء';

  @override
  String get appPurposeDescription =>
      'يساعدك هذا التطبيق على تتبع أوقات الصلاة وتسجيل صلواتك وإدارة صلوات القضاء.';

  @override
  String get share => 'مشاركة';

  @override
  String get exportExcel => 'تصدير كملف Excel';

  @override
  String get excelExported => 'تم حفظ ملف Excel';

  @override
  String get excelExportError => 'خطأ في حفظ ملف Excel';

  @override
  String get qadaDetailTitle => 'تفاصيل القضاء';

  @override
  String get qadaDetailDate => 'التاريخ';

  @override
  String get qadaDetailPrayer => 'وقت الصلاة';

  @override
  String get qadaDetailMissedAt => 'وقت الفوات';

  @override
  String get qadaDetailStatus => 'الحالة';

  @override
  String get qadaStatusPending => 'معلق';

  @override
  String get qadaStatusCompleted => 'مكتمل';

  @override
  String get qiblaCalibrationTitle => 'معايرة البوصلة';

  @override
  String get qiblaCalibrationMessage =>
      'حرك هاتفك على شكل رقم 8 لمعايرة البوصلة.';

  @override
  String get qiblaCalibrationButton => 'معايرة';

  @override
  String get qiblaCameraMode => 'وضع الكاميرا';

  @override
  String get qiblaCompassMode => 'وضع البوصلة';

  @override
  String get qiblaCameraPermissionRequired => 'إذن الكاميرا مطلوب';

  @override
  String get cameraPermissionDenied => 'تم رفض إذن الكاميرا';

  @override
  String get calibrateCompass => 'معايرة';

  @override
  String get calibrateCompassDesc =>
      'حرك هاتفك على شكل رقم 8 للحصول على نتائج أكثر دقة.';

  @override
  String get arMode => 'AR';

  @override
  String get holdVertical => 'أمسك الهاتف عموديًا ووجهه نحو القبلة';

  @override
  String get compassCalibrating => 'جاري معايرة البوصلة...';
}
