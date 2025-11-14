import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//nasılsın

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  Map<String, String>? prayerTimes; // İmsak, Güneş, Öğle, İkindi, Akşam, Yatsı
  final List<String> prayerNames = const [
    'İmsak',
    'Güneş',
    'Öğle',
    'İkindi',
    'Akşam',
    'Yatsı',
  ];

  DateTime now = DateTime.now();
  Timer? _ticker;
  String? hijriTr;
  String? hijriAr;

  // RN'deki overlay animasyonuna denk
  late final AnimationController _overlayCtr;
  // Gece yarısı Hicrî tarihi yenilemek için timer
  Timer? _midnightTimer;
  // RN'deki minute-level tetiklemeye daha yakın: aynı dakika içinde tekrar tetiklemeyi engelle
  int? _lastOverlayMinute;
  String? _lastOverlayPrayer;

  @override
  void initState() {
    super.initState();
    _overlayCtr = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _updateHijriDate();
    _scheduleHijriMidnightUpdate();
  }

  // Geliştirilmiş bildirim akışı
  // Basit uyarı metinleri (ayet/hadis anlamlı ikazlar)

  Future<void> _updateHijriDate() async {
    final d = DateTime.now().add(const Duration(days: 1));
    final url = Uri.parse(
      'https://api.aladhan.com/v1/gToH?date=${d.day}-${d.month}-${d.year}',
    );
    try {
      final res = await http.get(url);
      final data = jsonDecode(res.body);
      final hijri = data['data']['hijri'];
      final day = hijri['day'];
      final year = hijri['year'];
      final monthAr = hijri['month']['ar'];
      const map = {
        'محرم': 'Muharrem',
        'صفر': 'Safer',
        'ربيع الأول': 'Rebiülevvel',
        'رَبيع الثاني': 'Rebiülahir',
        'جمادى الأولى': 'Cemaziyelevvel',
        'جمادى الآخرة': 'Cemaziyelahir',
        'رجب': 'Recep',
        'شعبان': 'Şaban',
        'رمضان': 'Ramazan',
        'شوال': 'Şevval',
        'ذو القعدة': 'Zilkade',
        'ذو الحجة': 'Zilhicce',
      };
      setState(() {
        hijriAr = _toArabicDigits('$day $monthAr $year');
        hijriTr = '$day ${map[monthAr] ?? monthAr} $year';
      });
    } catch (_) {
      setState(() {
        hijriAr = 'تاريخ هجري غير معروف';
        hijriTr = 'Bilinmeyen Hicri Tarih';
      });
    }
  }

  String _toArabicDigits(String input) {
    const map = {
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩',
    };
    return input.replaceAllMapped(RegExp(r'[0-9]'), (m) => map[m.group(0)]!);
  }

  DateTime _parseToday(String hhmm) {
    final parts = hhmm.split(':');
    final d = DateTime.now();
    return DateTime(
      d.year,
      d.month,
      d.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  (String, DateTime)? _nextPrayer() {
    if (prayerTimes == null) return null;
    final items = <(String, DateTime)>[];
    for (final name in prayerNames) {
      final t = _parseToday(prayerTimes![name]!);
      items.add((name, t));
      items.add((name, t.add(const Duration(days: 1))));
    }
    items.sort((a, b) => a.$2.compareTo(b.$2));
    for (final it in items) {
      if (it.$2.isAfter(now)) return it;
    }
    return null;
  }

  // Akşam referanslı açı (RN ile aynı mantık)
  double _angleFromAksam(DateTime t) {
    if (prayerTimes == null) return 0;
    final aksam = _parseToday(prayerTimes!['Akşam']!);
    const dayMin = 24 * 60;
    int diff = t.difference(aksam).inMinutes;
    if (diff < 0) diff += dayMin;
    return (diff / dayMin) * 2 * math.pi; // radians
  }

  // Her vaktin açısı (Akşam referanslı) — sadece farzlar
  List<double> _angles() {
    if (prayerTimes == null) return [];
    final dayStart = DateTime(now.year, now.month, now.day);
    final aksamMins =
        _parseToday(prayerTimes!['Akşam']!).difference(dayStart).inMinutes;
    const total = 24 * 60;

    return prayerNames.map((n) {
      final mins = _parseToday(prayerTimes![n]!).difference(dayStart).inMinutes;
      final diff =
          mins >= aksamMins ? mins - aksamMins : total + mins - aksamMins;
      return (diff / total) * 2 * math.pi; // radians
    }).toList();
  }

  // Yardımcılar: gece uzunluğu ve bölümleri, gün aşımı orta nokta vb.
  Duration _frac(Duration d, double f) =>
      Duration(milliseconds: (d.inMilliseconds * f).round());

  DateTime _midAcrossDays(DateTime start, DateTime end) {
    // end < start ise ertesi güne taşı
    if (!end.isAfter(start)) end = end.add(const Duration(days: 1));
    final half = _frac(end.difference(start), 0.5);
    return start.add(half);
  }

  Map<String, double> _computeNafileAngles() {
    final res = <String, double>{};
    if (prayerTimes == null) return res;

    final imsakToday = _parseToday(prayerTimes!['İmsak']!);
    final sunrise = _parseToday(prayerTimes!['Güneş']!);
    final dhuhr = _parseToday(prayerTimes!['Öğle']!);
    final asr = _parseToday(prayerTimes!['İkindi']!);
    final maghrib = _parseToday(prayerTimes!['Akşam']!);
    final isha = _parseToday(prayerTimes!['Yatsı']!);

    final imsakNext = imsakToday.add(const Duration(days: 1));
    final nightLen = imsakNext.difference(
      isha.isAfter(maghrib) ? isha : isha,
    ); // isha bugün

    DateTime midDuha() {
      final start = sunrise.add(const Duration(minutes: 45));
      final end = dhuhr.subtract(const Duration(minutes: 15));
      return _midAcrossDays(start, end);
    }

    DateTime midTeheccud() {
      // Gecenin son üçte biri: orta noktası 5/6 oranında
      final startNight = isha;
      final mid = startNight.add(_frac(nightLen, 5 / 6));
      return mid;
    }

    DateTime midEvvabin() {
      final start = maghrib.add(const Duration(minutes: 10));
      final end = isha.subtract(const Duration(minutes: 10));
      return _midAcrossDays(start, end);
    }

    DateTime midIstihare() {
      // Gecenin ilk üçte birinin ortası: 1/6
      final startNight = isha;
      return startNight.add(_frac(nightLen, 1 / 6));
    }

    DateTime midHacet() {
      // Öğle-Asr aralığında pratik bir orta
      final start = dhuhr.add(const Duration(hours: 1));
      final end = asr.subtract(const Duration(minutes: 30));
      return _midAcrossDays(start, end);
    }

    DateTime midTesbih() {
      // Gün içinde geniş: İkindi-Akşam ortası
      return _midAcrossDays(asr, maghrib);
    }

    DateTime pickMid(String name) {
      switch (name) {
        case 'Duha (Kuşluk)':
          return midDuha();
        case 'Teheccüd':
          return midTeheccud();
        case 'Evvabin':
          return midEvvabin();
        case 'İstihare':
          return midIstihare();
        case 'Hacet':
          return midHacet();
        case 'Tesbih':
          return midTesbih();
      }
      // bilmezse öğle ortası
      return _midAcrossDays(dhuhr, asr);
    }

    return res;
  }

  void _scheduleHijriMidnightUpdate() {
    _midnightTimer?.cancel();
    final n = DateTime.now();
    final nextMidnight = DateTime(
      n.year,
      n.month,
      n.day,
    ).add(const Duration(days: 1));
    final wait = nextMidnight.difference(n);
    _midnightTimer = Timer(wait, () {
      if (!mounted) return;
      _updateHijriDate();
      _scheduleHijriMidnightUpdate(); // tekrar kur
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _midnightTimer?.cancel();
    _overlayCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final farzAngles = _angles();
    final next = _nextPrayer();
    final nafileAngles = _computeNafileAngles();

    // Ekran boyutuna göre dinamik çember
    final size = MediaQuery.of(context).size;
    final diameter =
        math.min(size.width, size.height) * 0.86; // biraz daha büyük yap
    final circleRadius = diameter / 2;
    final innerRadius = circleRadius * 0.95;

    // RN'e daha yakın: dakika bazlı tetikleme (aynı dakika içinde sadece 1 kez)
    if (next != null) {
      final d = next.$2.difference(now);
      final sameMinute = d.inMinutes == 0 && !d.isNegative; // bu dakika içinde
      if (sameMinute) {
        if (_lastOverlayPrayer != next.$1 || _lastOverlayMinute != now.minute) {
          _lastOverlayPrayer = next.$1;
          _lastOverlayMinute = now.minute;
          if (!_overlayCtr.isAnimating) {
            _overlayCtr.forward(from: 0);
            Future.delayed(const Duration(seconds: 4), () {
              if (mounted) _overlayCtr.value = 0;
            });
          }
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Hicrî Tarih (üstte, daha belirgin)
              Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      hijriAr ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hijriTr ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              // Çember ve boyalı alan
              SizedBox(
                width: diameter,
                height: diameter,
                child: CustomPaint(
                  painter: PrayerCirclePainter(
                    angles: farzAngles,
                    prayerNames: prayerNames,
                    nowAngle: _angleFromAksam(now),
                    kerahatMarkers: [
                      (_timeAngleWithOffset('Güneş', 45), 'Kerahat'),
                      (_timeAngleWithOffset('Öğle', -45), 'Kerahat'),
                      (_timeAngleWithOffset('Akşam', -45), 'Kerahat'),
                    ],
                    circleRadius: circleRadius,
                  ),
                ),
              ),

              // Geri sayım çemberin ortasında
              if (prayerTimes != null && next != null)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Bir sonraki namaz',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      next.$1,
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.black87,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Builder(
                      builder: (_) {
                        final d = next.$2.difference(now);
                        final dur = d.isNegative ? const Duration() : d;
                        final hhmmss = _fmt(dur);
                        return Column(
                          children: [
                            Text(
                              hhmmss,
                              style: const TextStyle(
                                fontSize: 34,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _toArabicDigits(hhmmss),
                              style: const TextStyle(
                                fontSize: 42,
                                color: Colors.black87,
                                fontFamily: 'Arial',
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'kaldı',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),

              // Farz kutucuklar
              if (farzAngles.isNotEmpty)
                ...List.generate(farzAngles.length, (i) {
                  final x = innerRadius * math.cos(farzAngles[i] - math.pi / 2);
                  final y = innerRadius * math.sin(farzAngles[i] - math.pi / 2);
                  return Transform.translate(
                    offset: Offset(x, y),
                    child: _PrayerBox(label: prayerNames[i]),
                  );
                }),

              // Nafile kutucuklar
              if (nafileAngles.isNotEmpty)
                ...nafileAngles.entries.map((e) {
                  final ang = e.value;
                  final x = innerRadius * math.cos(ang - math.pi / 2);
                  final y = innerRadius * math.sin(ang - math.pi / 2);
                  return Transform.translate(
                    key: ValueKey('nafile-${e.key}'),
                    offset: Offset(x, y),
                    child: _PrayerBox(label: e.key),
                  );
                }),

              // Overlay animasyonu
              AnimatedBuilder(
                animation: _overlayCtr,
                builder: (context, _) {
                  if (_overlayCtr.value == 0) return const SizedBox.shrink();
                  final scale = 1 + 0.2 * _overlayCtr.value;
                  return Opacity(
                    opacity: _overlayCtr.value,
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.black54,
                        alignment: Alignment.center,
                        child: Text(
                          '${_nextPrayer()?.$1} vakti!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final h = d.inHours.remainder(24).toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  // Kerahat için (prayer + offset dakika → angle)
  double _timeAngleWithOffset(String prayer, int offsetMin) {
    if (prayerTimes == null) return 0;
    final base = _parseToday(prayerTimes![prayer]!);
    final withOffset = base.add(Duration(minutes: offsetMin));
    return _angleFromAksam(withOffset);
  }
}

class _PrayerBox extends StatefulWidget {
  final String label;
  const _PrayerBox({required this.label});

  @override
  State<_PrayerBox> createState() => _PrayerBoxState();
}

class _PrayerBoxState extends State<_PrayerBox> {
  bool expanded = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => expanded = !expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: expanded ? 70 : 30,
        height: expanded ? 70 : 30,
        decoration: BoxDecoration(
          color: _boxColorFor(widget.label),
          borderRadius: BorderRadius.circular(expanded ? 10 : 15),
        ),
        alignment: Alignment.center,
        child:
            expanded
                ? Text(
                  widget.label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
                : null,
      ),
    );
  }

  // RN kutucuk renkleri birebir
  Color _boxColorFor(String name) {
    switch (name) {
      case 'Akşam':
        return const Color(0xFF6F4C3E);
      case 'Yatsı':
        return const Color(0xFF295e9c);
      case 'İmsak':
        return const Color(0xFFA3C1DA);
      case 'Güneş':
        return const Color(0xFF9CB86B);
      case 'Öğle':
        return const Color(0xFFFFD700);
      case 'İkindi':
        return const Color(0xFFFFA07A);
    }
    return Colors.grey;
  }
}

class PrayerCirclePainter extends CustomPainter {
  final List<double> angles; // radians, Akşam referanslı
  final double nowAngle; // radians
  final List<String> prayerNames;
  final List<(double, String)> kerahatMarkers; // (angle, label)
  final double circleRadius; // dynamic

  const PrayerCirclePainter({
    required this.angles,
    required this.prayerNames,
    required this.nowAngle,
    required this.kerahatMarkers,
    required this.circleRadius,
  });

  // RN'deki gradient paletleri birebir
  List<Color> _gradientFor(String name) {
    switch (name) {
      case 'Yatsı':
        return const [
          Color(0xFF3E2723),
          Color(0xFF5C4033),
          Color(0xFF654321),
          Color(0xFF8B4513),
          Color(0xFFA0522D),
        ];
      case 'İmsak':
        return const [
          Color(0xFF85929E),
          Color(0xFF5D6D7E),
          Color(0xFF2C3E50),
          Color(0xFF34495E),
          Color(0xFF1F2A37),
        ];
      case 'Güneş':
        return const [
          Color(0xFFF6DDCC),
          Color(0xFFFDEBD0),
          Color(0xFFF9E79F),
          Color(0xFFF4D03F),
          Color(0xFFF0E68C),
        ];
      case 'Öğle':
        return const [
          Color(0xFF98d038),
          Color(0xFFb4f544),
          Color(0xFFb4f544),
          Color(0xFFBDB76B),
          Color(0xFFFFD700),
        ];
      case 'İkindi':
        return const [
          Color(0xFFFFC0CB),
          Color(0xFFFF7C41),
          Color(0xFFFC7E4B),
          Color(0xFFF76328),
          Color(0xFFF6510F),
        ];
      case 'Akşam':
        return const [
          Color(0xFFFFDAB9),
          Color(0xFFF4A460),
          Color(0xFFD2691E),
          Color(0xFFA0522D),
          Color(0xFF654321),
        ];
    }
    return const [Colors.black, Colors.white];
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, circleRadius, outerPaint);

    if (angles.isEmpty) return;

    final innerRadius = circleRadius * 0.95;

    // Her vakit için ayrı radial gradient segment (RN Path/Arc mantığı)
    for (int i = 0; i < angles.length; i++) {
      final start = i == 0 ? angles.last : angles[i - 1];
      final end = angles[i];
      final sweep = _sweep(start, end);
      final rect = Rect.fromCircle(center: center, radius: innerRadius);
      final colors = _gradientFor(prayerNames[i]);
      final p =
          Paint()
            ..shader = RadialGradient(
              colors: colors,
              stops: List.generate(
                colors.length,
                (j) => j / (colors.length - 1),
              ),
              center: Alignment.center,
              radius: 1.0,
            ).createShader(rect);

      final path = Path()..moveTo(center.dx, center.dy);
      path.arcTo(rect, start - math.pi / 2, sweep, false);
      path.close();
      canvas.drawPath(path, p);
    }

    // Şu anki zaman: kırmızı çizgi + bilye
    final x = center.dx + innerRadius * math.cos(nowAngle - math.pi / 2);
    final y = center.dy + innerRadius * math.sin(nowAngle - math.pi / 2);
    final p2 =
        Paint()
          ..color = Colors.red
          ..strokeWidth = 2;
    canvas.drawLine(center, Offset(x, y), p2);
    canvas.drawCircle(Offset(x, y), 9, Paint()..color = Colors.red);

    // Kerahat işaretleri
    for (final (ang, label) in kerahatMarkers) {
      final mx = center.dx + innerRadius * math.cos(ang - math.pi / 2);
      final my = center.dy + innerRadius * math.sin(ang - math.pi / 2);
      canvas.drawCircle(Offset(mx, my), 10, Paint()..color = Colors.black);
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(mx - tp.width / 2, my - tp.height / 2));
      canvas.drawLine(
        center,
        Offset(mx, my),
        Paint()
          ..color = Colors.black
          ..strokeWidth = 2,
      );
    }
  }

  double _sweep(double start, double end) {
    var s = end - start;
    if (s < 0) s += 2 * math.pi;
    return s;
  }

  @override
  bool shouldRepaint(covariant PrayerCirclePainter old) =>
      old.angles != angles ||
      old.nowAngle != nowAngle ||
      old.prayerNames != prayerNames ||
      old.circleRadius != circleRadius;
}
