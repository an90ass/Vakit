import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class LifeWeeksScreen extends StatefulWidget {
  const LifeWeeksScreen({super.key});

  @override
  State<LifeWeeksScreen> createState() => _LifeWeeksScreenState();
}

class _LifeWeeksScreenState extends State<LifeWeeksScreen> {
  final TextEditingController _birthDateController = TextEditingController();
  List<List<bool>> _lifeWeeks = [];
  int? _remainingWeeks;
  int _totalWeeksLived = 0;
  bool _loading = true;
  bool _showInfo = false;
  
  static const int lifeYears = 63;

  @override
  void initState() {
    super.initState();
    _initializeWeeks();
    _loadSavedData();
  }

  void _initializeWeeks() {
    _lifeWeeks = List.generate(
      lifeYears,
      (index) => List.generate(52, (index) => false),
    );
  }

  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedBirthDate = prefs.getString('birthDate');
      
      if (savedBirthDate != null) {
        _birthDateController.text = savedBirthDate;
        await _calculateWeeks(savedBirthDate);
      }
      
      setState(() {
        _loading = false;
      });
    } catch (error) {
      print('Veri yüklenirken hata: $error');
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _calculateWeeks(String dateStr) async {
    try {
      final birthDate = DateFormat('dd.MM.yyyy').parseStrict(dateStr);
      final today = DateTime.now();
      int totalWeeks = 0;
      
      final updatedWeeks = _lifeWeeks.asMap().entries.map((yearEntry) {
        final yearIndex = yearEntry.key;
        final year = yearEntry.value;
        
        return year.asMap().entries.map((weekEntry) {
          final weekIndex = weekEntry.key;
          final weekDate = birthDate.add(Duration(days: (yearIndex * 52 + weekIndex) * 7));
          final isPastWeek = weekDate.isBefore(today);
          
          if (isPastWeek) totalWeeks++;
          return isPastWeek;
        }).toList();
      }).toList();
      
      setState(() {
        _lifeWeeks = updatedWeeks;
        _remainingWeeks = lifeYears * 52 - totalWeeks;
        _totalWeeksLived = totalWeeks;
      });
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('birthDate', dateStr);
    } catch (error) {
      _showErrorDialog('Geçersiz Tarih', 'Lütfen geçerli bir doğum tarihi girin (DD.MM.YYYY formatında).');
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

  void _handleCalculate() {
    if (_birthDateController.text.isNotEmpty) {
      _calculateWeeks(_birthDateController.text);
    }
  }

  void _formatInput(String text) {
    String formatted = text.replaceAll(RegExp(r'[^0-9.]'), '');
    
    if (formatted.length > 2 && !formatted.contains('.')) {
      formatted = '${formatted.substring(0, 2)}.${formatted.substring(2)}';
    }
    if (formatted.length > 5 && formatted.indexOf('.') == 2) {
      final parts = formatted.split('.');
      if (parts.length >= 2 && parts[1].length > 2) {
        formatted = '${parts[0]}.${parts[1].substring(0, 2)}.${parts[1].substring(2, parts[1].length > 6 ? 6 : parts[1].length)}';
      }
    }
    
    if (formatted.length > 10) {
      formatted = formatted.substring(0, 10);
    }
    
    _birthDateController.text = formatted;
    _birthDateController.selection = TextSelection.fromPosition(
      TextPosition(offset: formatted.length),
    );
  }

  Color _getBoxColor(bool isPastWeek, int yearIndex) {
    if (!isPastWeek) return Colors.grey.shade300;
    
    if (yearIndex < 7) return const Color(0xFF4FC3F7);
    if (yearIndex < 18) return const Color(0xFF81C784);
    if (yearIndex < 40) return const Color(0xFFFFD54F);
    if (yearIndex < 60) return const Color(0xFFFF8A65);
    return const Color(0xFFB39DDB);
  }

  Widget _buildWeekBoxes() {
    final screenWidth = MediaQuery.of(context).size.width;
    final boxSize = ((screenWidth - 70) / 52).clamp(5.0, 10.0);
    
    return Column(
      children: _lifeWeeks.asMap().entries.map((yearEntry) {
        final yearIndex = yearEntry.key;
        final year = yearEntry.value;
        
        return Row(
          children: [
            if (yearIndex % 5 == 0)
              SizedBox(
                width: 25,
                child: Text(
                  '$yearIndex',
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              )
            else
              const SizedBox(width: 25),
            Expanded(
              child: Wrap(
                children: year.asMap().entries.map((weekEntry) {
                  final weekIndex = weekEntry.key;
                  final isPastWeek = weekEntry.value;
                  
                  return Container(
                    width: boxSize,
                    height: boxSize,
                    margin: const EdgeInsets.all(0.5),
                    decoration: BoxDecoration(
                      color: _getBoxColor(isPastWeek, yearIndex),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildLegend() {
    final legendItems = [
      {'color': const Color(0xFF4FC3F7), 'text': 'Çocukluk (0-7)'},
      {'color': const Color(0xFF81C784), 'text': 'Gençlik (7-18)'},
      {'color': const Color(0xFFFFD54F), 'text': 'Yetişkinlik (18-40)'},
      {'color': const Color(0xFFFF8A65), 'text': 'Orta yaş (40-60)'},
      {'color': const Color(0xFFB39DDB), 'text': 'Yaşlılık (60+)'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: legendItems.map((item) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: item['color'] as Color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            item['text'] as String,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      )).toList(),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4FD),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: const Color(0xFF1e63b4), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF1e63b4)),
              SizedBox(height: 16),
              Text('Yükleniyor...', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hayatımın Haftaları'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showInfo ? Icons.info : Icons.info_outline),
            onPressed: () => setState(() => _showInfo = !_showInfo),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_showInfo) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F4FD),
                  borderRadius: BorderRadius.circular(8),
                  border: const Border(
                    left: BorderSide(color: Color(0xFF1e63b4), width: 4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bu tablo, Hz. Muhammed (S.A.V.)\'in yaşadığı 63 yıl süresince her hafta için bir kutu gösterir. '
                      'Geçmiş haftalar renkli, gelecekteki haftalar gri olarak görünür. '
                      'Doğum tarihinizi girerek yaşamınızdaki geçen ve kalan haftaları görebilirsiniz.',
                      style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    _buildLegend(),
                  ],
                ),
              ),
            ],
            
            // Doğum tarihi girişi
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _birthDateController,
                    decoration: const InputDecoration(
                      hintText: 'Doğum Tarihi (DD.MM.YYYY)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    onChanged: _formatInput,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _handleCalculate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1e63b4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  child: const Text('Hesapla', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Hafta kutuları
            _buildWeekBoxes(),
            
            const SizedBox(height: 20),
            
            // İstatistikler
            if (_remainingWeeks != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
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
                  children: [
                    _buildStatCard(
                      Icons.access_time,
                      '$_totalWeeksLived',
                      'Hafta Yaşadınız',
                    ),
                    _buildStatCard(
                      Icons.hourglass_empty,
                      '$_remainingWeeks',
                      'Hafta Kaldı',
                    ),
                    _buildStatCard(
                      Icons.calendar_today,
                      '${_totalWeeksLived ~/ 52}y ${_totalWeeksLived % 52}h',
                      'Yaşadığınız Süre',
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
