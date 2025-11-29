import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NafileScreen extends StatefulWidget {
  const NafileScreen({super.key});

  @override
  State<NafileScreen> createState() => _NafileScreenState();
}

class _NafileScreenState extends State<NafileScreen> {
  bool _loading = true;
  List<String> _selectedNafile = [];
  final Map<String, bool> _expanded = {};

  final List<Map<String, dynamic>> _nafileList = [
    {
      'id': 'teheccud',
      'name': 'Teheccüd Namazı',
      'description':
          'Yatsı namazından sonra, gecenin son üçte birinde kılınan müstehap bir namazdır. 2, 4, 8 veya 12 rekat olarak kılınabilir.',
      'time': 'Gece yarısından sonra, sabah namazı vaktinden önce',
      'fazilet':
          'Gece namazı Allah katında büyük değere sahiptir. Peygamber Efendimiz (s.a.v.) düzenli olarak kılmıştır.',
      'category': 'Gece Namazları',
    },
    {
      'id': 'duha',
      'name': 'Kuşluk (Duha) Namazı',
      'description':
          'Güneş doğduktan yaklaşık 45-50 dakika sonra, öğle namazı vaktine kadar kılınabilen namazdır. 2, 4, 6 veya 8 rekat olarak kılınabilir.',
      'time':
          'Güneş doğduktan yaklaşık bir saat sonra ile öğleden önceki zaman arası',
      'fazilet':
          'Vücudunuzdaki her bir eklem için sadaka vermenin karşılığıdır. Rızık ve bereket vesilesidir.',
      'category': 'Gündüz Namazları',
    },
    {
      'id': 'evvabin',
      'name': 'Evvabin Namazı',
      'description':
          'Akşam namazı farzından sonra, akşam namazının sünneti ile birlikte veya ayrı olarak kılınan 6 rekatlık bir namazdır.',
      'time': 'Akşam namazından sonra, yatsı namazından önce',
      'fazilet':
          'Günahların affına, duaların kabulüne ve umre sevabı kazanmaya vesiledir.',
      'category': 'Akşam Namazları',
    },
    {
      'id': 'israk',
      'name': 'İşrak Namazı',
      'description':
          'Güneşin doğmasından yaklaşık 45-50 dakika sonra kılınan 2 rekatlık bir namazdır.',
      'time': 'Güneş doğduktan 45-50 dakika sonra',
      'fazilet': 'Bir hac ve umre sevabına eşittir.',
      'category': 'Gündüz Namazları',
    },
    {
      'id': 'tesbih',
      'name': 'Tesbih Namazı',
      'description':
          'Her rekatta 75 defa "Sübhanellahi vel-hamdülillahi ve lâ ilâhe illallahü vallahü ekber" denilen özel bir namazdır. Toplam 4 rekattır.',
      'time': 'Herhangi bir vakitte (kerahat vakitleri hariç)',
      'fazilet': 'Geçmiş günahların affına vesiledir.',
      'category': 'Özel Namazlar',
    },
    {
      'id': 'hacet',
      'name': 'Hacet Namazı',
      'description':
          'Bir ihtiyaç veya bir istek için Allah\'a yalvarmak amacıyla kılınan 2 veya 4 rekatlık bir namazdır.',
      'time': 'Herhangi bir vakitte (kerahat vakitleri hariç)',
      'fazilet':
          'İhtiyaçların karşılanmasına, dileklerin kabul olmasına vesiledir.',
      'category': 'Özel Namazlar',
    },
    {
      'id': 'istihare',
      'name': 'İstihare Namazı',
      'description':
          'Yapılacak bir iş hakkında Allah\'tan hayırlısını göstermesini istemek için kılınan 2 rekatlık bir namazdır.',
      'time': 'Herhangi bir vakitte (kerahat vakitleri hariç)',
      'fazilet':
          'Kişinin hayırlı olan işi yapmasına ve doğru kararlar vermesine yardımcı olur.',
      'category': 'Özel Namazlar',
    },
    {
      'id': 'tahiyyetul_mescid',
      'name': 'Tahiyyetü\'l-Mescid',
      'description':
          'Camiye girildiğinde, oturmadan önce cami selamlamak için kılınan 2 rekatlık bir namazdır.',
      'time': 'Camiye girildiği an (kerahat vakitleri hariç)',
      'fazilet': 'Camiye saygı göstermenin ve selamlamanın karşılığıdır.',
      'category': 'Özel Namazlar',
    },
    {
      'id': 'yagmur',
      'name': 'Yağmur Duası (İstiska) Namazı',
      'description':
          'Yağmur yağması için Allah\'a dua etmek amacıyla kılınan 2 rekatlık bir namazdır. Cemaatle kılınması sünnettir.',
      'time': 'İhtiyaç duyulduğunda (kerahat vakitleri hariç)',
      'fazilet': 'Allah\'ın rahmetini ve bereketini celbetmeye vesiledir.',
      'category': 'Toplu Namazlar',
    },
    {
      'id': 'tevbe',
      'name': 'Tövbe Namazı',
      'description':
          'Bir günah işlendikten sonra pişmanlık duyarak Allah\'tan af dilemek için kılınan 2 rekatlık bir namazdır.',
      'time':
          'Günah işlendikten sonra herhangi bir vakitte (kerahat vakitleri hariç)',
      'fazilet': 'Günahların affına ve tövbenin kabulüne vesiledir.',
      'category': 'Özel Namazlar',
    },
    {
      'id': 'taheccud',
      'name': 'Tahiyye-i Vudû (Abdest Namazı)',
      'description':
          'Abdest aldıktan sonra şükür amacıyla kılınan 2 rekatlık bir namazdır.',
      'time':
          'Abdest alındıktan sonra herhangi bir vakitte (kerahat vakitleri hariç)',
      'fazilet': 'Abdest almanın sevabını artırır.',
      'category': 'Özel Namazlar',
    },
    {
      'id': 'regaip',
      'name': 'Regaip Namazı',
      'description':
          'Recep ayının ilk cuma gecesi kılınan nafile bir namazdır. 12 rekat olarak kılınır.',
      'time': 'Recep ayının ilk cuma gecesi',
      'fazilet': 'Günahların affına, duaların kabulüne vesiledir.',
      'category': 'Mübarek Gün ve Geceler',
    },
    {
      'id': 'mirac',
      'name': 'Miraç Namazı',
      'description':
          'Recep ayının 27. gecesi kılınan nafile bir namazdır. 12 rekat olarak kılınır.',
      'time': 'Recep ayının 27. gecesi',
      'fazilet':
          'Peygamber Efendimizin (s.a.v.) miracını anma ve o gecenin bereketinden faydalanma vesilesidir.',
      'category': 'Mübarek Gün ve Geceler',
    },
    {
      'id': 'berat',
      'name': 'Berat Namazı',
      'description':
          'Şaban ayının 15. gecesi kılınan nafile bir namazdır. 100 rekat olarak kılınabilir ancak genellikle 2, 4 veya 12 rekat olarak kılınır.',
      'time': 'Şaban ayının 15. gecesi',
      'fazilet':
          'Günahların affına, duaların kabulüne ve bereketine vesiledir.',
      'category': 'Mübarek Gün ve Geceler',
    },
    {
      'id': 'kadir',
      'name': 'Kadir Gecesi Namazı',
      'description':
          'Ramazan ayının 27. gecesi veya son on günü içinde kılınan nafile bir namazdır. Genellikle 12 rekat olarak kılınır.',
      'time': 'Ramazan ayının 27. gecesi (veya son on günü içinde)',
      'fazilet':
          'Bin aydan daha hayırlı olan Kadir gecesinin faziletinden istifade etmek içindir.',
      'category': 'Mübarek Gün ve Geceler',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedNafile();
  }

  Future<void> _loadSelectedNafile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedNafile = prefs.getStringList('selectedNafile') ?? [];

      setState(() {
        _selectedNafile = savedNafile;
        _loading = false;
      });
    } catch (error) {
      setState(() {
        _selectedNafile = [];
        _loading = false;
      });
    }
  }

  void _toggleCategory(String category) {
    setState(() {
      _expanded[category] = !(_expanded[category] ?? false);
    });
  }

  Future<void> _toggleNafile(String id) async {
    try {
      List<String> newSelected = List.from(_selectedNafile);
      final wasSelected = newSelected.contains(id);

      if (wasSelected) {
        newSelected.remove(id);
      } else {
        newSelected.add(id);
      }

      setState(() {
        _selectedNafile = newSelected;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('selectedNafile', newSelected);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              wasSelected
                  ? 'Namaz çemberden kaldırıldı.'
                  : 'Namaz ana çembere eklendi.',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Namaz seçimi kaydedilemedi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<String> get _categories {
    return _nafileList
        .map((item) => item['category'] as String)
        .toSet()
        .toList();
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
        title: const Text('Nafile Namazlar'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F4FD),
                borderRadius: BorderRadius.circular(8),
                border: const Border(
                  left: BorderSide(color: Color(0xFF1e63b4), width: 4),
                ),
              ),
              child: const Text(
                'Aşağıdaki nafile namazlar arasından seçim yaparak ana çembere ekleyebilirsiniz. '
                'Seçtiğiniz namazlar için bildirimler alırsınız.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),

            ..._categories.map(
              (category) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => _toggleCategory(category),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              category,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Icon(
                              _expanded[category] == true
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (_expanded[category] == true)
                      ..._nafileList
                          .where((item) => item['category'] == category)
                          .map(
                            (nafile) => Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.grey,
                                    width: 0.2,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          nafile['name'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Switch(
                                        value: _selectedNafile.contains(
                                          nafile['id'],
                                        ),
                                        onChanged:
                                            (value) =>
                                                _toggleNafile(nafile['id']),
                                        activeThumbColor: const Color(
                                          0xFF1e63b4,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    nafile['description'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                      height: 1.4,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: Colors.black54,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          nafile['time'],
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.star_outline,
                                        size: 16,
                                        color: Colors.black54,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          nafile['fazilet'],
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
