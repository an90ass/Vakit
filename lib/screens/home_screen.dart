import 'dart:io';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vakit/screens/homeContent.dart';
import 'package:vakit/l10n/generated/app_localizations.dart';
import 'package:vakit/screens/locations/cities_dashboard_screen.dart';
import 'package:vakit/screens/prayerTracking/views/prayer_tracking_screen.dart';
import 'package:vakit/screens/quran/views/quran_sura_page.dart';
import 'package:vakit/screens/settings_screen.dart';
import 'package:vakit/utlis/thems/colors.dart';
import 'package:vakit/bloc/app_language/app_language_cubit.dart';
import 'package:vakit/bloc/profile/profile_cubit.dart';

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
    final profileState = context.watch<ProfileCubit>().state;
    final profile = profileState.profile;
    final theme = Theme.of(context);

    return Scaffold(
     appBar: PreferredSize(
  preferredSize: const Size.fromHeight(100),
  child: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.colorScheme.primary,
          theme.colorScheme.primary.withOpacity(0.85),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: theme.colorScheme.primary.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SafeArea(
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(3),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.colorScheme.secondary,
                    backgroundImage: profile?.profileImagePath != null
                        ? FileImage(File(profile!.profileImagePath!))
                        : null,
                    child: profile?.profileImagePath == null
                        ? Icon(
                            Icons.person_rounded,
                            size: 28,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      profile != null && profile.name.isNotEmpty
                          ? '${localization.homeGreeting}, ${profile.name}'
                          : localization.homeGreeting,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 8,
                                color: theme.colorScheme.secondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                localization.homeGreetingSubtitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () {
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
),  body: _pages[_selectedIndex],

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
