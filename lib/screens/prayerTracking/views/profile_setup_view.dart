import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vakit/bloc/prayer/prayer_bloc.dart';
import 'package:vakit/bloc/prayer/prayer_state.dart';
import 'package:vakit/bloc/profile/profile_cubit.dart';
import 'package:vakit/bloc/profile/profile_state.dart';
import 'package:vakit/l10n/generated/app_localizations.dart';
import 'package:vakit/models/extra_prayer_type.dart';
import 'package:vakit/models/user_profile.dart';
import 'package:vakit/utlis/thems/colors.dart';

class ProfileSetupView extends StatefulWidget {
  const ProfileSetupView({
    super.key,
    this.initialProfile,
    this.isDialog = false,
  });

  final UserProfile? initialProfile;
  final bool isDialog;

  @override
  State<ProfileSetupView> createState() => _ProfileSetupViewState();
}

class _ProfileSetupViewState extends State<ProfileSetupView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _birthYearController;
  DateTime? _selectedBirthDate;
  late String _gender;
  late bool _qadaEnabled;
  late bool _notificationsEnabled;
  late Set<ExtraPrayerType> _selectedExtraPrayers;
  String? _profileImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final profile = widget.initialProfile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _birthYearController = TextEditingController();
    _selectedBirthDate = profile?.birthDate;

    _gender = profile?.gender ?? 'unspecified';
    _qadaEnabled = profile?.qadaModeEnabled ?? true;
    _notificationsEnabled = profile?.extraPrayerNotifications ?? false;
    _profileImagePath = profile?.profileImagePath;
    _selectedExtraPrayers =
        profile == null
            ? <ExtraPrayerType>{}
            : profile.extraPrayers
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
        ).showSnackBar(SnackBar(content: Text('Resim seçilemedi: $e')));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isEditing = widget.initialProfile != null;
    final title =
        isEditing ? localization.profileUpdate : localization.profileSetupTitle;

    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (context, state) {
        final isSaving = state.status == ProfileStatus.saving;
        final localization = AppLocalizations.of(context)!;
        final theme = Theme.of(context);

        return SafeArea(
          minimum: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  localization.profileSetupSubtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                ),
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
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
                                    size: 50,
                                    color: AppColors.primary,
                                  )
                                  : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: localization.profileName,
                          border: const OutlineInputBorder(),
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
                            border: const OutlineInputBorder(),
                            suffixIcon: const Icon(Icons.calendar_today),
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
                            child: Text(localization.profileGenderUnspecified),
                          ),
                        ],
                        decoration: InputDecoration(
                          labelText: localization.profileGender,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _gender = value);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildSwitchTile(
                  title: localization.qadaTracking,
                  subtitle: localization.qadaTrackingSubtitle,
                  value: _qadaEnabled,
                  onChanged: (value) => setState(() => _qadaEnabled = value),
                ),
                const SizedBox(height: 12),
                _buildSwitchTile(
                  title: localization.extraPrayerNotifications,
                  subtitle: localization.extraPrayerNotificationsSubtitle,
                  value: _notificationsEnabled,
                  onChanged:
                      (value) => setState(() => _notificationsEnabled = value),
                ),
                const SizedBox(height: 24),
                Text(
                  localization.extraPrayers,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      ExtraPrayerType.values.map((type) {
                        final isSelected = _selectedExtraPrayers.contains(type);
                        return ChoiceChip(
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
                        );
                      }).toList(),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon:
                          isSaving
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.check_circle_outline),
                      label: Text(
                        isEditing
                            ? localization.save
                            : localization.profileStart,
                      ),
                      onPressed: isSaving ? null : _submit,
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

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        value: value,
        onChanged: onChanged,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final localization = AppLocalizations.of(context)!;

    if (_selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localization.profileBirthDateRequired)),
      );
      return;
    }

    final profileCubit = context.read<ProfileCubit>();
    final base = widget.initialProfile;
    final extraIds = _selectedExtraPrayers.map((type) => type.id).toList();

    final profile =
        base == null
            ? UserProfile(
              name: _nameController.text.trim(),
              birthDate: _selectedBirthDate,
              gender: _gender,
              qadaModeEnabled: _qadaEnabled,
              extraPrayers: extraIds,
              extraPrayerNotifications: _notificationsEnabled,
              createdAt: DateTime.now(),
              profileImagePath: _profileImagePath,
            )
            : base.copyWith(
              name: _nameController.text.trim(),
              birthDate: _selectedBirthDate,
              gender: _gender,
              qadaModeEnabled: _qadaEnabled,
              extraPrayers: extraIds,
              extraPrayerNotifications: _notificationsEnabled,
              profileImagePath: _profileImagePath,
            );

    await profileCubit.saveProfile(profile);
    if (!mounted) return;
    final prayerState = context.read<PrayerBloc>().state;
    if (prayerState is PrayerLoaded) {
      await profileCubit.scheduleRemindersIfNeeded(
        prayerState.prayerTimes,
        force: true,
      );
    }
    if (widget.isDialog && mounted) {
      Navigator.of(context).maybePop();
    }
  }
}
