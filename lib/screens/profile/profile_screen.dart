import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vakit/bloc/profile/profile_cubit.dart';
import 'package:vakit/bloc/profile/profile_state.dart';
import 'package:vakit/l10n/generated/app_localizations.dart';
import 'package:vakit/models/extra_prayer_type.dart';
import 'package:vakit/models/user_profile.dart';
import 'package:vakit/utlis/thems/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  DateTime? _selectedBirthDate;
  late String _gender;
  late bool _qadaEnabled;
  late bool _notificationsEnabled;
  late Set<ExtraPrayerType> _selectedExtraPrayers;
  String? _profileImagePath;
  final ImagePicker _picker = ImagePicker();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _gender = 'unspecified';
    _qadaEnabled = true;
    _notificationsEnabled = false;
    _selectedExtraPrayers = {};
  }

  void _initializeFromProfile(UserProfile? profile) {
    if (_isInitialized || profile == null) return;
    _isInitialized = true;

    _nameController.text = profile.name;
    _selectedBirthDate = profile.birthDate;
    _gender = profile.gender;
    _qadaEnabled = profile.qadaModeEnabled;
    _notificationsEnabled = profile.extraPrayerNotifications;
    _profileImagePath = profile.profileImagePath;
    _selectedExtraPrayers =
        profile.extraPrayers
            .map(
              (id) => ExtraPrayerType.values.firstWhere(
                (type) => type.id == id,
                orElse: () => ExtraPrayerType.duha,
              ),
            )
            .toSet();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _profileImagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Resim secilemedi: $e')));
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = UserProfile(
      name: _nameController.text.trim(),
      birthDate: _selectedBirthDate,
      gender: _gender,
      qadaModeEnabled: _qadaEnabled,
      extraPrayers: _selectedExtraPrayers.map((e) => e.id).toList(),
      extraPrayerNotifications: _notificationsEnabled,
      createdAt: DateTime.now(),
      profileImagePath: _profileImagePath,
    );

    await context.read<ProfileCubit>().saveProfile(profile);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.profileSaved),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.85),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SafeArea(
                child: Row(
                  children: [
                    const SizedBox(width: 40),
                    Expanded(
                      child: Text(
                        localization.profileSettings,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          _initializeFromProfile(state.profile);
          final isSaving = state.status == ProfileStatus.saving;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profil Resmi
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: AppColors.primary.withValues(
                                alpha: 0.1,
                              ),
                              backgroundImage:
                                  _profileImagePath != null
                                      ? FileImage(File(_profileImagePath!))
                                      : null,
                              child:
                                  _profileImagePath == null
                                      ? Icon(
                                        Icons.person,
                                        size: 60,
                                        color: AppColors.primary,
                                      )
                                      : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // İsim
                          _buildSectionTitle(localization.profilePersonalInfo),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: localization.profileName,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: const Icon(Icons.person_outline),
                            ),
                            textCapitalization: TextCapitalization.words,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return localization.profileNameRequired;
                              }
                              if (value.trim().length < 2) {
                                return localization.profileNameMinLength;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Doğum Tarihi
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate:
                                    _selectedBirthDate ?? DateTime(2000, 1, 1),
                                firstDate: DateTime(1930),
                                lastDate: DateTime.now(),
                                helpText: localization.profileBirthDateHelp,
                              );
                              if (date != null) {
                                setState(() {
                                  _selectedBirthDate = date;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: localization.profileBirthDate,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: const Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                _selectedBirthDate != null
                                    ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'
                                    : localization.profileSelectDate,
                                style: TextStyle(
                                  color:
                                      _selectedBirthDate != null
                                          ? Colors.black87
                                          : Colors.black54,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Cinsiyet
                          DropdownButtonFormField<String>(
                            initialValue: _gender,
                            items: [
                              DropdownMenuItem(
                                value: 'male',
                                child: Text(localization.profileGenderMale),
                              ),
                              DropdownMenuItem(
                                value: 'female',
                                child: Text(localization.profileGenderFemale),
                              ),
                              DropdownMenuItem(
                                value: 'unspecified',
                                child: Text(
                                  localization.profileGenderUnspecified,
                                ),
                              ),
                            ],
                            decoration: InputDecoration(
                              labelText: localization.profileGender,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: const Icon(Icons.wc),
                            ),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _gender = value);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Kaza Takibi
                    _buildSectionTitle(localization.qadaSettings),
                    const SizedBox(height: 12),
                    _buildSwitchCard(
                      title: localization.qadaTracking,
                      subtitle: localization.qadaTrackingSubtitle,
                      value: _qadaEnabled,
                      onChanged:
                          (value) => setState(() => _qadaEnabled = value),
                      icon: Icons.history,
                    ),
                    const SizedBox(height: 12),
                    _buildSwitchCard(
                      title: localization.extraPrayerNotifications,
                      subtitle: localization.extraPrayerNotificationsSubtitle,
                      value: _notificationsEnabled,
                      onChanged:
                          (value) =>
                              setState(() => _notificationsEnabled = value),
                      icon: Icons.notifications_active,
                    ),
                    const SizedBox(height: 32),

                    // Ekstra Namazlar
                    _buildSectionTitle(localization.extraPrayers),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            ExtraPrayerType.values.map((type) {
                              final isSelected = _selectedExtraPrayers.contains(
                                type,
                              );
                              return FilterChip(
                                label: Text(type.titleLocalized(context)),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedExtraPrayers.add(type);
                                    } else {
                                      _selectedExtraPrayers.remove(type);
                                    }
                                  });
                                },
                                selectedColor: AppColors.primary.withValues(
                                  alpha: 0.2,
                                ),
                                checkmarkColor: AppColors.primary,
                              );
                            }).toList(),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Kaydet Butonu
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            isSaving
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : Text(
                                  localization.profileSave,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              if (isSaving)
                Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildSwitchCard({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
