import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakit/bloc/app_language/app_language_cubit.dart';
import 'package:vakit/bloc/theme/theme_cubit.dart';
import 'package:vakit/bloc/theme/theme_state.dart';
import 'package:vakit/l10n/generated/app_localizations.dart';
import 'package:vakit/theme/vakit_palette.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Position? _location;
  String _locationMethod = 'auto';
  bool _isLoading = true;
  String _selectedCity = '';
  String _selectedDistrict = '';
  bool _cityModalVisible = false;
  List<String> _filteredCities = [];
  bool _notificationsEnabled = true;
  String _notificationBeforeMinutes = '30';
  bool _notificationSound = true;
  bool _notificationVibration = true;
  bool _showArabicText = true;
  bool _showHijriDate = true;
  bool _showGregorianDate = true;
  String _appLanguage = 'tr';
  static const String _appVersion = '1.0.0';

  final List<String> _turkishCities = [
    'Adana',
    'Adıyaman',
    'Afyonkarahisar',
    'Ağrı',
    'Amasya',
    'Ankara',
    'Antalya',
    'Artvin',
    'Aydın',
    'Balıkesir',
    'Bilecik',
    'Bingöl',
    'Bitlis',
    'Bolu',
    'Burdur',
    'Bursa',
    'Çanakkale',
    'Çankırı',
    'Çorum',
    'Denizli',
    'Diyarbakır',
    'Edirne',
    'Elazığ',
    'Erzincan',
    'Erzurum',
    'Eskişehir',
    'Gaziantep',
    'Giresun',
    'Gümüşhane',
    'Hakkari',
    'Hatay',
    'Isparta',
    'Mersin',
    'İstanbul',
    'İzmir',
    'Kars',
    'Kastamonu',
    'Kayseri',
    'Kırklareli',
    'Kırşehir',
    'Kocaeli',
    'Konya',
    'Kütahya',
    'Malatya',
    'Manisa',
    'Kahramanmaraş',
    'Mardin',
    'Muğla',
    'Muş',
    'Nevşehir',
    'Niğde',
    'Ordu',
    'Rize',
    'Sakarya',
    'Samsun',
    'Siirt',
    'Sinop',
    'Sivas',
    'Tekirdağ',
    'Tokat',
    'Trabzon',
    'Tunceli',
    'Şanlıurfa',
    'Uşak',
    'Van',
    'Yozgat',
    'Zonguldak',
    'Aksaray',
    'Bayburt',
    'Karaman',
    'Kırıkkale',
    'Batman',
    'Şırnak',
    'Bartın',
    'Ardahan',
    'Iğdır',
    'Yalova',
    'Karabük',
    'Kilis',
    'Osmaniye',
    'Düzce',
  ];

  @override
  void initState() {
    super.initState();
    _filteredCities = List.from(_turkishCities);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();

      setState(() {
        _locationMethod = prefs.getString('locationMethod') ?? 'auto';
        _selectedCity = prefs.getString('selectedCity') ?? '';
        _selectedDistrict = prefs.getString('selectedDistrict') ?? '';
        _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
        _notificationBeforeMinutes =
            prefs.getString('notificationBeforeMinutes') ?? '30';
        _notificationSound = prefs.getBool('notificationSound') ?? true;
        _notificationVibration = prefs.getBool('notificationVibration') ?? true;
        _showArabicText = prefs.getBool('showArabicText') ?? true;
        _showHijriDate = prefs.getBool('showHijriDate') ?? true;
        _showGregorianDate = prefs.getBool('showGregorianDate') ?? true;
        _appLanguage = prefs.getString('appLanguage') ?? 'tr';
      });

      final savedLatitude = prefs.getDouble('userLatitude');
      final savedLongitude = prefs.getDouble('userLongitude');

      if (savedLatitude != null && savedLongitude != null) {
        _location = Position(
          latitude: savedLatitude,
          longitude: savedLongitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      print('Ayarlar yüklenirken hata: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _requestLocationPermission() async {
    try {
      final localization = AppLocalizations.of(context)!;
      setState(() {
        _isLoading = true;
      });

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorDialog(
            localization.locationPermissionTitle,
            localization.locationPermissionDeniedBody,
          );
          setState(() {
            _locationMethod = 'manual';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showErrorDialog(
          localization.locationPermissionTitle,
          localization.locationPermissionPermanentBody,
        );
        setState(() {
          _locationMethod = 'manual';
          _isLoading = false;
        });
        return;
      }

      final currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      setState(() {
        _location = currentLocation;
        _locationMethod = 'auto';
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('userLatitude', currentLocation.latitude);
      await prefs.setDouble('userLongitude', currentLocation.longitude);
      await prefs.setString('locationMethod', 'auto');

      setState(() {
        _isLoading = false;
      });

      _showSuccessDialog(
        localization.locationUpdatedTitle,
        localization.locationUpdatedBodyAuto,
      );
    } catch (error) {
      print('Konum alınamadı: $error');
      _showErrorDialog(
        AppLocalizations.of(context)!.errorGenericTitle,
        AppLocalizations.of(context)!.locationFetchError,
      );
      setState(() {
        _locationMethod = 'manual';
        _isLoading = false;
      });
    }
  }

  void _searchCities(String text) {
    setState(() {
      if (text.trim().isEmpty) {
        _filteredCities = List.from(_turkishCities);
      } else {
        _filteredCities =
            _turkishCities
                .where(
                  (city) => city.toLowerCase().contains(text.toLowerCase()),
                )
                .toList();
      }
    });
  }

  Future<void> _selectCity(String city) async {
    setState(() {
      _selectedCity = city;
      _cityModalVisible = false;
      _selectedDistrict = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedCity', city);
      await prefs.setString('selectedDistrict', '');
      await prefs.setString('locationMethod', 'manual');
      setState(() {
        _locationMethod = 'manual';
      });
    } catch (error) {
      print('Şehir kaydedilirken hata: $error');
    }
  }

  Future<void> _updateManualLocation() async {
    if (_selectedCity.isEmpty) {
      final localization = AppLocalizations.of(context)!;
      _showErrorDialog(
        localization.errorGenericTitle,
        localization.locationSelectCityError,
      );
      return;
    }

    try {
      final localization = AppLocalizations.of(context)!;
      setState(() {
        _isLoading = true;
      });

      // Basit koordinat eşleştirmesi
      Map<String, List<double>> cityCoordinates = {
        'İstanbul': [41.0082, 28.9784],
        'İzmir': [38.4237, 27.1428],
        'Ankara': [39.9334, 32.8597],
        'Bursa': [40.1826, 29.0665],
        'Antalya': [36.8969, 30.7133],
        'Adana': [37.0000, 35.3213],
        'Konya': [37.8667, 32.4833],
        'Gaziantep': [37.0662, 37.3833],
        'Kayseri': [38.7312, 35.4787],
        'Eskişehir': [39.7767, 30.5206],
      };

      List<double> coordinates =
          cityCoordinates[_selectedCity] ?? [39.9334, 32.8597];

      final newLocation = Position(
        latitude: coordinates[0],
        longitude: coordinates[1],
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

      setState(() {
        _location = newLocation;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('userLatitude', coordinates[0]);
      await prefs.setDouble('userLongitude', coordinates[1]);

      setState(() {
        _isLoading = false;
      });

      _showSuccessDialog(
        localization.locationUpdatedTitle,
        localization.locationUpdatedBodyManual(
          _selectedDistrict.isNotEmpty
              ? '$_selectedCity - $_selectedDistrict'
              : _selectedCity,
        ),
      );
    } catch (error) {
      print('Manuel konum güncellenirken hata: $error');
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(
        AppLocalizations.of(context)!.errorGenericTitle,
        AppLocalizations.of(context)!.locationUpdateError,
      );
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      final localization = AppLocalizations.of(context)!;
      final status = await Permission.notification.request();
      if (!status.isGranted) {
        _showErrorDialog(
          localization.notificationPermissionTitle,
          localization.notificationPermissionBody,
        );
        return;
      }
    }

    setState(() {
      _notificationsEnabled = value;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
  }

  Future<void> _handleNotificationMinutesChange(String text) async {
    final numericValue = text.replaceAll(RegExp(r'[^0-9]'), '');
    setState(() {
      _notificationBeforeMinutes = numericValue;
    });

    if (numericValue.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('notificationBeforeMinutes', numericValue);
    }
  }

  Future<void> _toggleNotificationSound(bool value) async {
    setState(() {
      _notificationSound = value;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationSound', value);
  }

  Future<void> _toggleNotificationVibration(bool value) async {
    setState(() {
      _notificationVibration = value;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationVibration', value);
  }

  Future<void> _toggleArabicText(bool value) async {
    setState(() {
      _showArabicText = value;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showArabicText', value);
  }

  Future<void> _toggleHijriDate(bool value) async {
    setState(() {
      _showHijriDate = value;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showHijriDate', value);
  }

  Future<void> _toggleGregorianDate(bool value) async {
    setState(() {
      _showGregorianDate = value;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showGregorianDate', value);
  }

  Future<void> _changeLanguage(String language) async {
    context.read<AppLanguageCubit>().updateLocale(Locale(language));

    setState(() {
      _appLanguage = language;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final localization = AppLocalizations.of(context)!;

      _showSuccessDialog(
        localization.languageChangeTitle,
        localization.languageChangeDescription,
      );
    });
  }

  void _resetSettings() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final localization = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
          title: Text(localization.settingsResetDialogTitle),
          content: Text(localization.settingsResetDialogBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(localization.cancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _performReset();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(localization.settingsResetDialogConfirm),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performReset() async {
    try {
      final localization = AppLocalizations.of(context)!;
      setState(() {
        _isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      setState(() {
        _locationMethod = 'auto';
        _location = null;
        _selectedCity = '';
        _selectedDistrict = '';
        _notificationsEnabled = true;
        _notificationBeforeMinutes = '30';
        _notificationSound = true;
        _notificationVibration = true;
        _showArabicText = true;
        _showHijriDate = true;
        _showGregorianDate = true;
        _appLanguage = 'tr';
        _isLoading = false;
      });

      _showSuccessDialog(
        localization.settingsResetSuccessTitle,
        localization.settingsResetSuccessBody,
      );
    } catch (error) {
      print('Ayarlar sıfırlanırken hata: $error');
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(
        AppLocalizations.of(context)!.errorGenericTitle,
        AppLocalizations.of(context)!.settingsResetError,
      );
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final localization = AppLocalizations.of(dialogContext)!;
        final theme = Theme.of(dialogContext);

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surface.withOpacity(0.95),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      localization.dialogOk,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final localization = AppLocalizations.of(dialogContext)!;
        final theme = Theme.of(dialogContext);

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surface.withOpacity(0.95),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline_rounded,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      localization.dialogOk,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: Colors.black87),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildOptionRow(String title, Widget trailing) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildPaletteCard({
    required VakitPalette palette,
    required bool isSelected,
    required VoidCallback onTap,
    required String title,
    required String description,
  }) {
    final cardWidth = (MediaQuery.of(context).size.width - 64) / 2;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: cardWidth,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? palette.primary.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? palette.primary : Colors.grey.shade300,
            width: isSelected ? 1.6 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildColorSegment(palette.primary),
                _buildColorSegment(palette.primaryLight),
                _buildColorSegment(palette.accent),
                _buildColorSegment(palette.background),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? palette.primary : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(description, style: TextStyle(color: Colors.grey.shade600)),
            if (isSelected)
              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.check_circle,
                  color: palette.accent,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSegment(Color color) {
    return Expanded(
      child: Container(
        height: 6,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  String _paletteTitle(AppLocalizations localization, String paletteId) {
    switch (paletteId) {
      case 'desert':
        return localization.themePaletteDesertName;
      case 'midnight':
        return localization.themePaletteMidnightName;
      case 'olive':
      default:
        return localization.themePaletteOliveName;
    }
  }

  String _paletteDescription(AppLocalizations localization, String paletteId) {
    switch (paletteId) {
      case 'desert':
        return localization.themePaletteDesertDescription;
      case 'midnight':
        return localization.themePaletteMidnightDescription;
      case 'olive':
      default:
        return localization.themePaletteOliveDescription;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                localization.settingsLoadingMessage,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(localization.tabSettings),

            // Konum Ayarları
            _buildSection(
              localization.settingsLocationSection,
              Icons.location_on,
              [
                _buildOptionRow(
                  localization.settingsLocationMethodLabel,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Radio<String>(
                            value: 'auto',
                            groupValue: _locationMethod,
                            onChanged: (value) {
                              if (value != null) {
                                _requestLocationPermission();
                              }
                            },
                            activeColor: Theme.of(context).colorScheme.primary,
                          ),
                          Text(localization.settingsLocationMethodAuto),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'manual',
                            groupValue: _locationMethod,
                            onChanged: (value) async {
                              if (value != null) {
                                setState(() {
                                  _locationMethod = value;
                                });
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setString('locationMethod', value);
                              }
                            },
                            activeColor: Theme.of(context).colorScheme.primary,
                          ),
                          Text(localization.settingsLocationMethodManual),
                        ],
                      ),
                    ],
                  ),
                ),

                if (_locationMethod == 'auto')
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _requestLocationPermission,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[800],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          localization.settingsUpdateLocation,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),

                if (_locationMethod == 'manual') ...[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () => setState(() => _cityModalVisible = true),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _selectedCity.isEmpty
                                      ? localization
                                          .settingsSelectCityPlaceholder
                                      : _selectedCity,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        _selectedCity.isEmpty
                                            ? Colors.grey
                                            : Colors.black87,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        TextField(
                          decoration: InputDecoration(
                            hintText: localization.settingsDistrictHint,
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (text) async {
                            setState(() {
                              _selectedDistrict = text;
                            });
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString('selectedDistrict', text);
                          },
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _updateManualLocation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1e63b4),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              localization.settingsUpdateLocation,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (_location != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F4FE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localization.settingsCurrentLocationLabel(
                            _locationMethod == 'auto'
                                ? localization.settingsCurrentLocationGps
                                : _selectedDistrict.isNotEmpty
                                ? '$_selectedCity - $_selectedDistrict'
                                : _selectedCity,
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        if (_locationMethod == 'auto')
                          Text(
                            localization.settingsLatitudeLongitude(
                              _location!.latitude.toString(),
                              _location!.longitude.toString(),
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),

            // Bildirim Ayarları
            _buildSection(
              localization.settingsNotificationsSection,
              Icons.notifications,
              [
                _buildOptionRow(
                  localization.settingsNotificationsToggle,
                  Switch(
                    value: _notificationsEnabled,
                    onChanged: _toggleNotifications,
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ),

                if (_notificationsEnabled) ...[
                  _buildOptionRow(
                    localization.settingsNotificationLeadTime,
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 60,
                          child: TextField(
                            controller: TextEditingController(
                              text: _notificationBeforeMinutes,
                            ),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                            ),
                            onChanged: _handleNotificationMinutesChange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(localization.settingsNotificationMinutesSuffix),
                      ],
                    ),
                  ),

                  _buildOptionRow(
                    localization.settingsNotificationSound,
                    Switch(
                      value: _notificationSound,
                      onChanged: _toggleNotificationSound,
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  _buildOptionRow(
                    localization.settingsNotificationVibration,
                    Switch(
                      value: _notificationVibration,
                      onChanged: _toggleNotificationVibration,
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),

            // Arayüz Ayarları
            _buildSection(
              localization.settingsInterfaceSection,
              Icons.settings,
              [
                _buildOptionRow(
                  localization.settingsShowArabicText,
                  Switch(
                    value: _showArabicText,
                    onChanged: _toggleArabicText,
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ),

                _buildOptionRow(
                  localization.settingsShowHijriDate,
                  Switch(
                    value: _showHijriDate,
                    onChanged: _toggleHijriDate,
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ),

                _buildOptionRow(
                  localization.settingsShowGregorianDate,
                  Switch(
                    value: _showGregorianDate,
                    onChanged: _toggleGregorianDate,
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 8),
                BlocBuilder<ThemeCubit, VakitThemeState>(
                  builder: (context, themeState) {
                    final localization = AppLocalizations.of(context)!;
                    final themeCubit = context.read<ThemeCubit>();
                    final softnessPercent =
                        ((themeState.softness / 0.5) * 100).round();
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localization.themePaletteTitle,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            localization.themePaletteSubtitle,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children:
                                VakitPalettes.all.map((palette) {
                                  final title = _paletteTitle(
                                    localization,
                                    palette.id,
                                  );
                                  final description = _paletteDescription(
                                    localization,
                                    palette.id,
                                  );
                                  return _buildPaletteCard(
                                    palette: palette,
                                    isSelected:
                                        palette.id == themeState.palette.id,
                                    onTap:
                                        () => themeCubit.selectPalette(
                                          palette.id,
                                        ),
                                    title: title,
                                    description: description,
                                  );
                                }).toList(),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                localization.themeSofteningLabel,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                localization.themeSofteningValue(
                                  softnessPercent,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: themeState.softness,
                            min: 0,
                            max: 0.5,
                            divisions: 5,
                            activeColor: themeState.palette.primary,
                            label: localization.themeSofteningValue(
                              softnessPercent,
                            ),
                            onChanged: themeCubit.updateSoftness,
                          ),
                          Text(
                            localization.themeSofteningDescription,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),

            // Dil Ayarları
            _buildSection(localization.languageTitle, Icons.language, [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLanguageButton(
                      code: 'tr',
                      label: localization.languageTurkish,
                    ),
                    const SizedBox(width: 12),
                    _buildLanguageButton(
                      code: 'en',
                      label: localization.languageEnglish,
                    ),
                    const SizedBox(width: 12),
                    _buildLanguageButton(code: 'ar', label: 'العربية'),
                  ],
                ),
              ),
            ]),
            // Sıfırlama Butonu
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 20),
              child: ElevatedButton.icon(
                onPressed: _resetSettings,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: Text(
                  localization.settingsResetButton,
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            // Uygulama Bilgileri
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    localization.settingsAppVersionLabel(_appVersion),
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    localization.settingsAppCopyright,
                    style: const TextStyle(fontSize: 12, color: Colors.black38),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Şehir seçim modalı
      bottomSheet:
          _cityModalVisible
              ? Container(
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey, width: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            localization.settingsCityPickerTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed:
                                () => setState(() => _cityModalVisible = false),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: localization.settingsCitySearchHint,
                          prefixIcon: const Icon(Icons.search),
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: _searchCities,
                      ),
                    ),

                    Expanded(
                      child: ListView.builder(
                        itemCount: _filteredCities.length,
                        itemBuilder: (context, index) {
                          final city = _filteredCities[index];
                          return ListTile(
                            title: Text(city),
                            onTap: () => _selectCity(city),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
              : null,
    );
  }

  Widget _buildLanguageButton({required String code, required String label}) {
    final theme = Theme.of(context);
    final isSelected = _appLanguage == code;

    return Expanded(
      child: ElevatedButton(
        onPressed: () => _changeLanguage(code),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceVariant,
          foregroundColor:
              isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isSelected ? 2 : 0,
        ),
        child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Text(
        title,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: Colors.black45,
          fontSize: 20,
        ),
      ),
    );
  }
}
