import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:namaz/screens/homeContent.dart';
import 'package:namaz/screens/prayerTracking/views/prayer_tracking_screen.dart';
import 'package:namaz/screens/qiblahScreen.dart';
import 'package:namaz/utlis/thems/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
   final List<Widget> _pages = [
    HomeContent(),
    PrayerTrackingScreen(),
    QuranMainScreen(),
    Center(child: Text("Profil", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
  ];
    int _selectedIndex = 0;

   void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100), // AppBar yüksekliğini artır
        child: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          flexibleSpace: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        
            child: SafeArea(
              child: Row(
                children: [
                  // Kullanıcı profil ikonu ile modern etkiler
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.accent, AppColors.accent.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.transparent,
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.accent,
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(width: 16),
                  
                  // Kullanıcı bilgileri
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Selam
                        Text(
                          'Hoş Geldin..',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        
                        SizedBox(height: 4),
                        
                        // Kullanıcı adı
                        Text(
                          'Anas almaqtarı',
                           style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                         
                        ),
                      ],
                    ),
                  ),
                  
                  // Dini ikon ile modern etki
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.mosque,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
     body: _pages[_selectedIndex],

 bottomNavigationBar:ConvexAppBar(
  height: 60, 
  style: TabStyle.react,
  backgroundColor: AppColors.primary,
  items: [
    TabItem(icon: Icons.home, title: 'Ana Sayfa'),
    TabItem(icon: Icons.map, title: 'Namazlarım'),
    TabItem(icon: Icons.add, title: 'Kıble'),
    TabItem(icon: Icons.people, title: 'Ayarlar'),
  ],
  onTap: _onItemTapped,
)

    );
  }
}
