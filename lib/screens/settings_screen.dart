import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

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
  String _searchCity = '';
  bool _notificationsEnabled = true;
  String _notificationBeforeMinutes = '30';
  bool _notificationSound = true;
  bool _notificationVibration = true;
  bool _showArabicText = true;
  bool _showHijriDate = true;
  bool _showGregorianDate = true;
  String _appLanguage = 'tr';

  final List<String> _turkishCities = [
    'Adana', 'Adıyaman', 'Afyonkarahisar', 'Ağrı', 'Amasya', 'Ankara', 'Antalya',
    'Artvin', 'Aydın', 'Balıkesir', 'Bilecik', 'Bingöl', 'Bitlis', 'Bolu',
    'Burdur', 'Bursa', 'Çanakkale', 'Çankırı', 'Çorum', 'Denizli', 'Diyarbakır',
    'Edirne', 'Elazığ', 'Erzincan', 'Erzurum', 'Eskişehir', 'Gaziantep', 'Giresun',
    'Gümüşhane', 'Hakkari', 'Hatay', 'Isparta', 'Mersin', 'İstanbul', 'İzmir',
    'Kars', 'Kastamonu', 'Kayseri', 'Kırklareli', 'Kırşehir', 'Kocaeli', 'Konya',
    'Kütahya', 'Malatya', 'Manisa', 'Kahramanmaraş', 'Mardin', 'Muğla', 'Muş',
    'Nevşehir', 'Niğde', 'Ordu', 'Rize', 'Sakarya', 'Samsun', 'Siirt', 'Sinop',
    'Sivas', 'Tekirdağ', 'Tokat', 'Trabzon', 'Tunceli', 'Şanlıurfa', 'Uşak',
    'Van', 'Yozgat', 'Zonguldak', 'Aksaray', 'Bayburt', 'Karaman', 'Kırıkkale',
    'Batman', 'Şırnak', 'Bartın', 'Ardahan', 'Iğdır', 'Yalova', 'Karabük',
    'Kilis', 'Osmaniye', 'Düzce'
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
        _notificationBeforeMinutes = prefs.getString('notificationBeforeMinutes') ?? '30';
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
      setState(() {
        _isLoading = true;
      });

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorDialog(
            'Konum izni gerekli',
            'Konum izni verilmediği için namaz vakitleri için manuel il ve ilçe seçimi yapmalısınız.',
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
          'Konum izni gerekli',
          'Konum izni kalıcı olarak reddedildi. Lütfen ayarlardan izin verin veya manuel konum seçin.',
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
        'Konum Güncellendi',
        'Konumunuz başarıyla güncellendi. Namaz vakitleri yeni konuma göre güncellenecek.',
      );
    } catch (error) {
      print('Konum alınamadı: $error');
      _showErrorDialog(
        'Hata',
        'Konum alınırken bir hata oluştu. Lütfen manuel konum seçimine geçin.',
      );
      setState(() {
        _locationMethod = 'manual';
        _isLoading = false;
      });
    }
  }

  void _searchCities(String text) {
    setState(() {
      _searchCity = text;
      if (text.trim().isEmpty) {
        _filteredCities = List.from(_turkishCities);
      } else {
        _filteredCities = _turkishCities
            .where((city) => city.toLowerCase().contains(text.toLowerCase()))
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
      _showErrorDialog('Hata', 'Lütfen bir şehir seçin.');
      return;
    }

    try {
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

      List<double> coordinates = cityCoordinates[_selectedCity] ?? [39.9334, 32.8597];

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
        'Konum Güncellendi',
        '$_selectedCity ${_selectedDistrict.isNotEmpty ? '- $_selectedDistrict' : ''} için namaz vakitleri güncellenecek.',
      );
    } catch (error) {
      print('Manuel konum güncellenirken hata: $error');
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Hata', 'Konum güncellenirken bir hata oluştu.');
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      final status = await Permission.notification.request();
      if (!status.isGranted) {
        _showErrorDialog(
          'Bildirim İzni Gerekli',
          'Namaz vakitleri için bildirim almak istiyorsanız bildirim izni vermeniz gerekiyor.',
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
    setState(() {
      _appLanguage = language;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('appLanguage', language);

    _showSuccessDialog(
      'Dil Değişikliği',
      'Dil değişikliğinin tam olarak uygulanması için uygulamayı yeniden başlatmanız gerekebilir.',
    );
  }

  void _resetSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayarları Sıfırla'),
        content: const Text(
          'Tüm ayarları varsayılan değerlerine sıfırlamak istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _performReset();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sıfırla'),
          ),
        ],
      ),
    );
  }

  Future<void> _performReset() async {
    try {
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
        'Başarılı',
        'Tüm ayarlar varsayılan değerlerine sıfırlandı.',
      );
    } catch (error) {
      print('Ayarlar sıfırlanırken hata: $error');
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Hata', 'Ayarlar sıfırlanırken bir hata oluştu.');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
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
              border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF1e63b4)),
              SizedBox(height: 16),
              Text('Ayarlar yükleniyor...', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Konum Ayarları
            _buildSection(
              'Konum Ayarları',
              Icons.location_on,
              [
                _buildOptionRow(
                  'Konum belirleme yöntemi',
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
                            activeColor: const Color(0xFF1e63b4),
                          ),
                          const Text('Otomatik'),
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
                                final prefs = await SharedPreferences.getInstance();
                                await prefs.setString('locationMethod', value);
                              }
                            },
                            activeColor: const Color(0xFF1e63b4),
                          ),
                          const Text('Manuel'),
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
                          backgroundColor: const Color(0xFF1e63b4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Konumu Güncelle', style: TextStyle(color: Colors.white)),
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
                                  _selectedCity.isEmpty ? 'İl Seçin' : _selectedCity,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _selectedCity.isEmpty ? Colors.grey : Colors.black87,
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down, color: Colors.black54),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        TextField(
                          decoration: const InputDecoration(
                            hintText: 'İlçe (opsiyonel)',
                            border: OutlineInputBorder(),
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
                            child: const Text('Konumu Güncelle', style: TextStyle(color: Colors.white)),
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
                          'Mevcut Konum: ${_locationMethod == 'auto' ? 'GPS Koordinatları' : '$_selectedCity ${_selectedDistrict.isNotEmpty ? '- $_selectedDistrict' : ''}'}',
                          style: const TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        if (_locationMethod == 'auto')
                          Text(
                            'Enlem: ${_location!.latitude.toString()}, Boylam: ${_location!.longitude.toString()}',
                            style: const TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
            
            // Bildirim Ayarları
            _buildSection(
              'Bildirim Ayarları',
              Icons.notifications,
              [
                _buildOptionRow(
                  'Namaz vakti bildirimleri',
                  Switch(
                    value: _notificationsEnabled,
                    onChanged: _toggleNotifications,
                    activeColor: const Color(0xFF1e63b4),
                  ),
                ),
                
                if (_notificationsEnabled) ...[
                  _buildOptionRow(
                    'Bildirimler ne kadar önce gelsin?',
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 60,
                          child: TextField(
                            controller: TextEditingController(text: _notificationBeforeMinutes),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                            onChanged: _handleNotificationMinutesChange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('dakika'),
                      ],
                    ),
                  ),
                  
                  _buildOptionRow(
                    'Bildirim sesi',
                    Switch(
                      value: _notificationSound,
                      onChanged: _toggleNotificationSound,
                      activeColor: const Color(0xFF1e63b4),
                    ),
                  ),
                  
                  _buildOptionRow(
                    'Bildirim titreşimi',
                    Switch(
                      value: _notificationVibration,
                      onChanged: _toggleNotificationVibration,
                      activeColor: const Color(0xFF1e63b4),
                    ),
                  ),
                ],
              ],
            ),
            
            // Arayüz Ayarları
            _buildSection(
              'Arayüz Ayarları',
              Icons.settings,
              [
                _buildOptionRow(
                  'Arapça metinleri göster',
                  Switch(
                    value: _showArabicText,
                    onChanged: _toggleArabicText,
                    activeColor: const Color(0xFF1e63b4),
                  ),
                ),
                
                _buildOptionRow(
                  'Hicri tarihi göster',
                  Switch(
                    value: _showHijriDate,
                    onChanged: _toggleHijriDate,
                    activeColor: const Color(0xFF1e63b4),
                  ),
                ),
                
                _buildOptionRow(
                  'Miladi tarihi göster',
                  Switch(
                    value: _showGregorianDate,
                    onChanged: _toggleGregorianDate,
                    activeColor: const Color(0xFF1e63b4),
                  ),
                ),
              ],
            ),
            
            // Dil Ayarları
            _buildSection(
              'Dil Ayarları',
              Icons.language,
              [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _changeLanguage('tr'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _appLanguage == 'tr' 
                                ? const Color(0xFF1e63b4) 
                                : Colors.grey.shade200,
                            foregroundColor: _appLanguage == 'tr' 
                                ? Colors.white 
                                : Colors.black87,
                          ),
                          child: const Text('Türkçe'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _changeLanguage('en'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _appLanguage == 'en' 
                                ? const Color(0xFF1e63b4) 
                                : Colors.grey.shade200,
                            foregroundColor: _appLanguage == 'en' 
                                ? Colors.white 
                                : Colors.black87,
                          ),
                          child: const Text('English'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Sıfırlama Butonu
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 20),
              child: ElevatedButton.icon(
                onPressed: _resetSettings,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text('Tüm Ayarları Sıfırla', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            
            // Uygulama Bilgileri
            Container(
              padding: const EdgeInsets.all(16),
              child: const Column(
                children: [
                  Text(
                    'Namaz Vakti Uygulaması v1.0.0',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '© 2025 Tüm Hakları Saklıdır',
                    style: TextStyle(fontSize: 12, color: Colors.black38),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      
      // Şehir seçim modalı
      bottomSheet: _cityModalVisible ? Container(
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
                border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Şehir Seçin',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _cityModalVisible = false),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Şehir Ara...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
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
      ) : null,
    );
  }
}