import 'dart:io';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:namaz/screens/homeContent.dart';
import 'package:namaz/l10n/generated/app_localizations.dart';
import 'package:namaz/screens/locations/cities_dashboard_screen.dart';
import 'package:namaz/screens/prayerTracking/views/prayer_tracking_screen.dart';
import 'package:namaz/screens/quran/views/quran_sura_page.dart';
import 'package:namaz/screens/settings_screen.dart';
import 'package:namaz/utlis/thems/colors.dart';
import 'package:namaz/bloc/app_language/app_language_cubit.dart';
import 'package:namaz/bloc/profile/profile_cubit.dart';
import 'package:namaz/bloc/profile/profile_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final List<Widget> _pages;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pages = [
      const CitiesDashboardScreen(),
      const PrayerTrackingScreen(),
      HomeContent(), // Ana sayfa ortada
      const QuranPage(),
      const SettingsScreen(),
    ];
    _selectedIndex = 2; // Ana sayfa başlangıçta seçili
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final languageCubit = context.watch<AppLanguageCubit>();
    final profileState = context.watch<ProfileCubit>().state;
    final profile = profileState.profile;
    
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
                  // Kullanıcı profil fotoğrafı
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accent,
                          AppColors.accent.withOpacity(0.7),
                        ],
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
                        backgroundImage: profile?.profileImagePath != null
                            ? FileImage(File(profile!.profileImagePath!))
                            : null,
                        child: profile?.profileImagePath == null
                            ? Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.white,
                              )
                            : null,
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
                          profile != null && profile.name.isNotEmpty
                              ? '${localization.homeGreeting}, ${profile.name}'
                              : localization.homeGreeting,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: 4),

                        // Alt yazı
                        Text(
                          localization.homeGreetingSubtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Dil değiştirme butonu
                  IconButton(
                    icon: Icon(Icons.language, color: Colors.white, size: 28),
                    tooltip: localization.languageTitle,
                    onPressed: () => _openLanguageSheet(languageCubit.state),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _pages[_selectedIndex],

      bottomNavigationBar: ConvexAppBar(
        height: 60,
        style: TabStyle.react,
        backgroundColor: AppColors.primary,
        initialActiveIndex: 2, // Ana sayfa ortada başlasın
        items: [
          TabItem(icon: Icons.location_city, title: localization.tabCities),
          TabItem(icon: Icons.map, title: localization.tabMyPrayers),
          TabItem(icon: Icons.home, title: localization.tabHome), // Ortada
          TabItem(icon: Icons.book, title: localization.tabQuran),
          TabItem(icon: Icons.settings, title: localization.tabSettings),
        ],
        onTap: _onItemTapped,
      ),
    );
  }

  void _openLanguageSheet(Locale currentLocale) {
    final localization = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final options = [
          _LanguageOption(localization.languageTurkish, const Locale('tr')),
          _LanguageOption(localization.languageEnglish, const Locale('en')),
          _LanguageOption(localization.languageArabic, const Locale('ar')),
        ];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localization.languageTitle,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  localization.languageSubtitle,
                  style: TextStyle(color: Colors.black54),
                ),
                SizedBox(height: 16),
                ...options.map(
                  (option) => RadioListTile<Locale>(
                    title: Text(option.label),
                    value: option.locale,
                    groupValue: currentLocale,
                    onChanged: (value) {
                      if (value == null) return;
                      context.read<AppLanguageCubit>().updateLocale(value);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(content: Text(localization.languageChanged)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LanguageOption {
  const _LanguageOption(this.label, this.locale);
  final String label;
  final Locale locale;
}
