import 'dart:io';

import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vakit/bloc/myPrayers/my_prayers_bloc.dart';
import 'package:vakit/bloc/myPrayers/my_prayers_event.dart';
import 'package:vakit/bloc/myPrayers/my_prayers_state.dart';
import 'package:vakit/bloc/profile/profile_cubit.dart';
import 'package:vakit/bloc/profile/profile_state.dart';
import 'package:vakit/models/Prayer.dart';
import 'package:vakit/models/extra_prayer_type.dart';
import 'package:vakit/models/qada_record.dart';
import 'package:vakit/models/user_profile.dart';
import 'package:vakit/repositories/extra_prayer_repository.dart';
import 'package:vakit/repositories/qada_repository.dart';
import 'package:vakit/screens/prayerTracking/views/profile_setup_view.dart';
import 'package:vakit/l10n/generated/app_localizations.dart';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../utlis/thems/colors.dart';

class PrayerTrackingScreen extends StatelessWidget {
  const PrayerTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final todayKey = DateTime.now().toIso8601String().substring(0, 10);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state.status == ProfileStatus.needsSetup) {
              return const ProfileSetupView();
            }

            if (state.status == ProfileStatus.error && state.profile == null) {
              return _ProfileErrorView(message: state.errorMessage);
            }

            final profile = state.profile;
            if (profile == null) {
              return const _CenteredLoading();
            }

            final showSavingBanner = state.status == ProfileStatus.saving;
            return _TrackedPrayersView(
              profile: profile,
              todayKey: todayKey,
              showSavingBanner: showSavingBanner,
            );
          },
        ),
      ),
    );
  }
}

class _TrackedPrayersView extends StatelessWidget {
  const _TrackedPrayersView({
    required this.profile,
    required this.todayKey,
    this.showSavingBanner = false,
  });

  final UserProfile profile;
  final String todayKey;
  final bool showSavingBanner;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyPrayersBloc()..add(LoadMyPrayers(todayKey)),
      child: Stack(
        children: [
          BlocListener<MyPrayersBloc, MyPrayersState>(
            listener: (context, state) {
              if (state is MyPrayersError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Failed to load prayers: ${state.message}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFFDC2626),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            },
            child: BlocBuilder<MyPrayersBloc, MyPrayersState>(
              builder: (context, state) {
                if (state is MyPrayersLoading || state is MyPrayersInitial) {
                  return const _CenteredLoading();
                }
                if (state is MyPrayersLoaded) {
                  final prayerDay = state.prayerDay;
                  final prayers = [
                    Prayer(
                      name: 'Fajr',
                      time: prayerDay.fajr,
                      done: prayerDay.fajrStatus,
                    ),
                    Prayer(
                      name: 'Dhuhr',
                      time: prayerDay.dhuhr,
                      done: prayerDay.dhuhrStatus,
                    ),
                    Prayer(
                      name: 'Asr',
                      time: prayerDay.asr,
                      done: prayerDay.asrStatus,
                    ),
                    Prayer(
                      name: 'Maghrib',
                      time: prayerDay.maghrib,
                      done: prayerDay.maghribStatus,
                    ),
                    Prayer(
                      name: 'Isha',
                      time: prayerDay.isha,
                      done: prayerDay.ishaStatus,
                    ),
                  ];
                  return _buildMainContent(context, prayers, todayKey, profile);
                }
                return _buildEmptyState();
              },
            ),
          ),
          if (showSavingBanner) const _SavingOverlay(),
        ],
      ),
    );
  }
}

String _getLocalizedPrayerName(BuildContext context, String prayerName) {
  final locale = Localizations.localeOf(context);
  final languageCode = locale.languageCode;

  switch (prayerName) {
    case 'Fajr':
      if (languageCode == 'tr') return 'Sabah';
      if (languageCode == 'ar') return 'الفجر';
      return 'Fajr';
    case 'Dhuhr':
      if (languageCode == 'tr') return 'Öğle';
      if (languageCode == 'ar') return 'الظهر';
      return 'Dhuhr';
    case 'Asr':
      if (languageCode == 'tr') return 'İkindi';
      if (languageCode == 'ar') return 'العصر';
      return 'Asr';
    case 'Maghrib':
      if (languageCode == 'tr') return 'Akşam';
      if (languageCode == 'ar') return 'المغرب';
      return 'Maghrib';
    case 'Isha':
      if (languageCode == 'tr') return 'Yatsı';
      if (languageCode == 'ar') return 'العشاء';
      return 'Isha';
    default:
      return prayerName;
  }
}

/// Mevcut vakti hesapla - Gece yarisi (00:00) sonrasi Yatsi icin ozel mantik
/// Eger saat 00:00-05:00 arasi ise ve henuz Imsak vakti girmediyse,
/// kullanici onceki gunun Yatsi namazini isaretleyebilir
int _getCurrentPrayerIndex(List<Prayer> prayers) {
  final now = DateTime.now();
  final currentTime = now.hour * 60 + now.minute;

  // Gece yarisi sonrasi kontrolu (00:00-05:00 arasi)
  // Imsak vakti genellikle 04:00-06:00 arasi olur
  if (now.hour >= 0 && now.hour < 6) {
    // Imsak vaktini al
    final imsakTimeParts = prayers[0].time.split(':');
    final imsakTime =
        int.parse(imsakTimeParts[0]) * 60 + int.parse(imsakTimeParts[1]);

    // Henuz Imsak vakti girmediyse, tum namazlar isaretlenebilir (Yatsi dahil)
    if (currentTime < imsakTime) {
      return prayers.length -
          1; // Son namaz (Yatsi) dahil hepsini isaretleyebilir
    }
  }

  for (int i = 0; i < prayers.length; i++) {
    final timeParts = prayers[i].time.split(':');
    final prayerTime = int.parse(timeParts[0]) * 60 + int.parse(timeParts[1]);

    if (currentTime < prayerTime) {
      // Eger henuz ilk namaz vaktine gelmediyse, hicbir namaz isaretlenemez
      return i > 0 ? i - 1 : -1;
    }
  }
  // Gun sonunda tum namazlar isaretlenebilir
  return prayers.length - 1;
}

Widget _buildMainContent(
  BuildContext context,
  List<Prayer> prayers,
  String todayKey,
  UserProfile profile,
) {
  final completedPrayers = prayers.where((p) => p.done == true).length;
  final progress = completedPrayers / prayers.length;
  final currentPrayerIndex = _getCurrentPrayerIndex(prayers);

  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProfileHeaderCard(profile: profile),
        const SizedBox(height: 16),
        _buildProgressCard(context, completedPrayers, prayers.length, progress),
        const SizedBox(height: 16),
        _buildDateHeader(context, todayKey),
        const SizedBox(height: 12),
        Text(
          AppLocalizations.of(context)!.dailyPrayers,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: prayers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final prayer = prayers[index];
            // Sadece mevcut vakit ve önceki vakitler işaretlenebilir
            final canMark =
                currentPrayerIndex >= 0 && index <= currentPrayerIndex;
            return PrayerItem(
              key: ValueKey(prayer.name),
              prayer: prayer,
              canMark: canMark,
              onStatusChanged: (bool status) {
                _showUpdateFeedback(context, prayer.name, status);
                context.read<MyPrayersBloc>().add(
                  UpdatePrayerStatus(
                    dateKey: todayKey,
                    prayerName: prayer.name,
                    status: status,
                  ),
                );
                if (profile.qadaModeEnabled) {
                  final qadaRepository = context.read<QadaRepository>();
                  if (status) {
                    qadaRepository.resolvePrayer(
                      dateKey: todayKey,
                      prayerName: prayer.name,
                    );
                  } else {
                    qadaRepository.recordMissedPrayer(
                      dateKey: todayKey,
                      prayerName: prayer.name,
                    );
                  }
                }
              },
            );
          },
        ),
        if (profile.extraPrayers.isNotEmpty) ...[
          const SizedBox(height: 24),
          _ExtraPrayerChecklist(profile: profile, dateKey: todayKey),
        ],
        if (profile.qadaModeEnabled) ...[
          const SizedBox(height: 24),
          const _QadaSummaryCard(),
        ],
        const SizedBox(height: 24),
      ],
    ),
  );
}

Widget _buildProgressCard(
  BuildContext context,
  int completed,
  int total,
  double progress,
) {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.primaryLight, AppColors.primary],
        begin: Alignment.bottomRight,
        end: Alignment.topLeft,
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.15),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.todaysProgress,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.keepUpGoodWork,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$completed/$total',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).toInt()}% ${AppLocalizations.of(context)!.complete}',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

Widget _buildDateHeader(BuildContext context, String todayKey) {
  final date = DateTime.parse(todayKey);
  final locale = Localizations.localeOf(context);
  final languageCode = locale.languageCode;

  String formattedDate;
  if (languageCode == 'tr') {
    final monthsTr = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    formattedDate = '${date.day} ${monthsTr[date.month - 1]} ${date.year}';
  } else if (languageCode == 'ar') {
    final monthsAr = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    formattedDate = '${date.day} ${monthsAr[date.month - 1]} ${date.year}';
  } else {
    final monthsEn = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    formattedDate = '${monthsEn[date.month - 1]} ${date.day}, ${date.year}';
  }

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.calendar_today_rounded,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.todaysDate,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              formattedDate,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildEmptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(
            Icons.mosque_outlined,
            size: 48,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'No Prayer Data Available',
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Please try refreshing the app',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    ),
  );
}

void _showUpdateFeedback(BuildContext context, String prayerName, bool status) {
  final message =
      status
          ? '$prayerName prayer marked as completed'
          : '$prayerName prayer marked as missed';

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            status ? Icons.check_circle_outline : Icons.info_outline,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 16))),
        ],
      ),
      backgroundColor:
          status ? const Color(0xFF059669) : const Color(0xFFF59E0B),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
    ),
  );
}

class _CenteredLoading extends StatelessWidget {
  const _CenteredLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E40AF)),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Loading prayer data...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavingOverlay extends StatelessWidget {
  const _SavingOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black26,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Profil güncelleniyor...'),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileErrorView extends StatelessWidget {
  const _ProfileErrorView({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
          const SizedBox(height: 12),
          Text(message ?? 'Profil yüklenemedi'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.read<ProfileCubit>().loadProfile(),
            child: const Text('Tekrar dene'),
          ),
        ],
      ),
    );
  }
}

class PrayerItem extends StatefulWidget {
  final Prayer prayer;
  final ValueChanged<bool> onStatusChanged;
  final bool canMark;

  const PrayerItem({
    super.key,
    required this.prayer,
    required this.onStatusChanged,
    required this.canMark,
  });

  @override
  State<PrayerItem> createState() => _PrayerItemState();
}

class _PrayerItemState extends State<PrayerItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusIcon = _getStatusIcon();
    final statusText = _getStatusText();

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _getLocalizedPrayerName(
                                context,
                                widget.prayer.name,
                              ),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.prayer.time,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildActionButton(
                        icon: Icons.check_circle_rounded,
                        color: const Color(0xFF059669),
                        onPressed: () => _handleStatusChange(true),
                        isSelected: widget.prayer.done == true,
                        label: 'Done',
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        icon: Icons.cancel_rounded,
                        color: const Color(0xFFDC2626),
                        onPressed: () => _handleStatusChange(false),
                        isSelected: widget.prayer.done == false,
                        label: 'Missed',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required bool isSelected,
    required String label,
  }) {
    final isDisabled = !widget.canMark;
    return Tooltip(
      message: isDisabled ? 'Henüz bu vakit gelmedi' : label,
      child: Opacity(
        opacity: isDisabled ? 0.3 : 1.0,
        child: GestureDetector(
          onTapDown: isDisabled ? null : (_) => _animationController.forward(),
          onTapUp: isDisabled ? null : (_) => _animationController.reverse(),
          onTapCancel: isDisabled ? null : () => _animationController.reverse(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color, width: 1.5),
            ),
            child: InkWell(
              onTap: isDisabled ? null : onPressed,
              borderRadius: BorderRadius.circular(10),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (widget.prayer.done) {
      case true:
        return const Color(0xFF059669);
      case false:
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getStatusIcon() {
    switch (widget.prayer.done) {
      case true:
        return Icons.check_circle_rounded;
      case false:
        return Icons.cancel_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }

  String _getStatusText() {
    final localization = AppLocalizations.of(context)!;
    switch (widget.prayer.done) {
      case true:
        return localization.completed;
      case false:
        return localization.missed;
      default:
        return localization.pending;
    }
  }

  void _handleStatusChange(bool status) {
    widget.onStatusChanged(status);
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final qadaStatus =
        profile.qadaModeEnabled
            ? localization.qadaTrackingOn
            : localization.qadaTrackingOff;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary,
                backgroundImage:
                    profile.profileImagePath != null
                        ? FileImage(File(profile.profileImagePath!))
                        : null,
                child:
                    profile.profileImagePath == null
                        ? Text(
                          profile.name.isEmpty
                              ? '?'
                              : profile.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                        : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${profile.age} ${localization.ageYears} • ${localization.hijriAge}: ${profile.hijriAge} ${localization.ageYears}',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      qadaStatus,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (profile.extraPrayers.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children:
                  profile.extraPrayers
                      .map(
                        (id) => Chip(
                          label: Text(
                            ExtraPrayerType.values
                                .firstWhere(
                                  (type) => type.id == id,
                                  orElse: () => ExtraPrayerType.duha,
                                )
                                .titleLocalized(context),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExtraPrayerChecklist extends StatefulWidget {
  const _ExtraPrayerChecklist({required this.profile, required this.dateKey});

  final UserProfile profile;
  final String dateKey;

  @override
  State<_ExtraPrayerChecklist> createState() => _ExtraPrayerChecklistState();
}

class _ExtraPrayerChecklistState extends State<_ExtraPrayerChecklist> {
  late ExtraPrayerRepository _repository;
  late Map<String, bool?> _statuses;

  @override
  void initState() {
    super.initState();
    _repository = context.read<ExtraPrayerRepository>();
    _statuses = _repository.loadStatuses(widget.dateKey);
  }

  @override
  Widget build(BuildContext context) {
    final types =
        ExtraPrayerType.values
            .where((type) => widget.profile.extraPrayers.contains(type.id))
            .toList();
    if (types.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nafile Kontrol Listesi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              Icon(
                Icons.notifications_active_outlined,
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...types.map((type) {
            final status = _statuses[type.id] ?? false;
            return CheckboxListTile(
              value: status,
              title: Text(type.titleLocalized(context)),
              subtitle: Text(type.descriptionLocalized(context)),
              onChanged: (value) async {
                final resolvedStatus = value ?? false;
                await _repository.updateStatus(
                  widget.dateKey,
                  type.id,
                  resolvedStatus,
                );
                setState(() {
                  _statuses[type.id] = resolvedStatus;
                });
              },
            );
          }),
        ],
      ),
    );
  }
}

class _QadaSummaryCard extends StatefulWidget {
  const _QadaSummaryCard();

  @override
  State<_QadaSummaryCard> createState() => _QadaSummaryCardState();
}

class _QadaSummaryCardState extends State<_QadaSummaryCard> {
  final GlobalKey _exportKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final repository = context.read<QadaRepository>();
    final box = Hive.box(QadaRepository.boxName);
    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (_, __, ___) {
        final pending = repository.pendingRecords();
        final count = pending.length;
        return RepaintBoundary(
          key: _exportKey,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.qadaTracking,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  count == 0
                      ? AppLocalizations.of(context)!.noPendingQada
                      : AppLocalizations.of(context)!.pendingQadaMessage(count),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                          ),
                          onPressed: () => _openDetails(context, pending),
                          icon: const Icon(Icons.table_chart_outlined),
                          label: Text(AppLocalizations.of(context)!.table),
                        ),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                          ),
                          onPressed:
                              count == 0
                                  ? null
                                  : () => _exportToExcel(context, pending),
                          icon: const Icon(Icons.ios_share),
                          label: Text(AppLocalizations.of(context)!.share),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _exportToExcel(
    BuildContext context,
    List<QadaRecord> records,
  ) async {
    try {
      final localization = AppLocalizations.of(context)!;

      // Excel paketi ile Excel dosyası oluştur
      final excel = Excel.createExcel();
      final sheet = excel['Kaza Namazları'];

      // Başlık satırı
      sheet.appendRow([
        TextCellValue(localization.qadaDetailDate),
        TextCellValue(localization.qadaDetailPrayer),
        TextCellValue(localization.qadaDetailMissedAt),
        TextCellValue(localization.qadaDetailStatus),
      ]);

      // Veri satırları
      for (final record in records) {
        final status =
            record.resolvedAt == null
                ? localization.qadaStatusPending
                : localization.qadaStatusCompleted;
        sheet.appendRow([
          TextCellValue(record.dateKey),
          TextCellValue(_getLocalizedPrayerName(context, record.prayerName)),
          TextCellValue(record.missedAt.toLocal().toString().substring(0, 16)),
          TextCellValue(status),
        ]);
      }

      // Dosyayı kaydet
      final directory = await getTemporaryDirectory();
      final fileName =
          'kaza_namazlari_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final filePath = '${directory.path}/$fileName';

      final fileBytes = excel.save();
      if (fileBytes != null) {
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);

        // Dosyayı paylaş
        // ignore: deprecated_member_use
        await Share.shareXFiles([
          XFile(filePath),
        ], text: localization.currentQadaSummary);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localization.excelExported),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.excelExportError),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openDetails(BuildContext context, List<QadaRecord> records) {
    final csv = _buildCsv(records);
    final localization = AppLocalizations.of(context)!;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (_) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 60,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localization.pendingQadaPrayers,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (records.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(localization.noRecordsYet),
                    )
                  else
                    SizedBox(
                      height: 320,
                      child: ListView.separated(
                        itemCount: records.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final record = records[index];
                          return ListTile(
                            onTap: () => _showRecordDetail(context, record),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    record.resolvedAt == null
                                        ? Colors.orange.withValues(alpha: 0.1)
                                        : Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                record.resolvedAt == null
                                    ? Icons.schedule
                                    : Icons.check_circle,
                                color:
                                    record.resolvedAt == null
                                        ? Colors.orange
                                        : Colors.green,
                              ),
                            ),
                            title: Text(
                              _getLocalizedPrayerName(
                                context,
                                record.prayerName,
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(record.dateKey),
                            trailing: Icon(
                              Icons.chevron_right,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed:
                            records.isEmpty
                                ? null
                                : () => _exportToExcel(context, records),
                        icon: const Icon(Icons.table_chart),
                        label: Text(localization.exportExcel),
                      ),
                      OutlinedButton.icon(
                        onPressed:
                            records.isEmpty
                                ? null
                                : () => _shareCsv(csv, context),
                        icon: const Icon(Icons.share),
                        label: Text(localization.shareCSV),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showRecordDetail(BuildContext context, QadaRecord record) {
    final localization = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(localization.qadaDetailTitle),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                  localization.qadaDetailDate,
                  record.dateKey,
                  Icons.calendar_today,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  localization.qadaDetailPrayer,
                  _getLocalizedPrayerName(context, record.prayerName),
                  Icons.access_time,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  localization.qadaDetailMissedAt,
                  record.missedAt.toLocal().toString().substring(0, 16),
                  Icons.warning_amber,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  localization.qadaDetailStatus,
                  record.resolvedAt == null
                      ? localization.qadaStatusPending
                      : localization.qadaStatusCompleted,
                  record.resolvedAt == null
                      ? Icons.schedule
                      : Icons.check_circle,
                  color:
                      record.resolvedAt == null ? Colors.orange : Colors.green,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(localization.dialogOk),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _shareCsv(String csv, BuildContext context) async {
    try {
      final localization = AppLocalizations.of(context)!;
      // ignore: deprecated_member_use
      await Share.share(csv, subject: localization.qadaTable);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV paylaşılırken hata oluştu: $error')),
      );
    }
  }

  String _buildCsv(List<QadaRecord> records) {
    final buffer = StringBuffer('dateKey,prayerName,missedAt,resolvedAt\n');
    for (final record in records) {
      buffer.writeln(
        '${record.dateKey},${record.prayerName},'
        '${record.missedAt.toIso8601String()},'
        '${record.resolvedAt?.toIso8601String() ?? ''}',
      );
    }
    return buffer.toString();
  }
}
