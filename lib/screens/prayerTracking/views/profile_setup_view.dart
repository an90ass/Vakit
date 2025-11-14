import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:namaz/bloc/prayer/prayer_bloc.dart';
import 'package:namaz/bloc/prayer/prayer_state.dart';
import 'package:namaz/bloc/profile/profile_cubit.dart';
import 'package:namaz/bloc/profile/profile_state.dart';
import 'package:namaz/models/extra_prayer_type.dart';
import 'package:namaz/models/user_profile.dart';
import 'package:namaz/utlis/thems/colors.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resim seçilemedi: $e')),
        );
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
    final isEditing = widget.initialProfile != null;
    final title = isEditing ? 'Profilini Güncelle' : 'Namaz Takibini Başlat';

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
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: widget.isDialog ? 12 : 32,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kişisel tercihlerini ekle, kaza ve nafile ibadetlerini takip et.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
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
                      decoration: const InputDecoration(
                        labelText: 'İsim',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Lütfen adını yaz';
                        }
                        if (value.trim().length < 2) {
                          return 'İsim en az 2 karakter olmalı';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedBirthDate ?? DateTime(2000, 1, 1),
                          firstDate: DateTime(1930),
                          lastDate: DateTime.now(),
                          helpText: 'Doğum Tarihinizi Seçin',
                        );
                        if (date != null) {
                          setState(() {
                            _selectedBirthDate = date;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Doğum Tarihi',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _selectedBirthDate != null
                              ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'
                              : 'Tarih seçin',
                          style: TextStyle(
                            color: _selectedBirthDate != null
                                ? Colors.black87
                                : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _gender,
                      items: const [
                        DropdownMenuItem(value: 'male', child: Text('Erkek')),
                        DropdownMenuItem(value: 'female', child: Text('Kadın')),
                        DropdownMenuItem(
                          value: 'unspecified',
                          child: Text('Belirtmek istemiyorum'),
                        ),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Cinsiyet',
                        border: OutlineInputBorder(),
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
                title: 'Kaza Takibi',
                subtitle: 'Kaçırdığın vakitleri otomatik kaydedelim.',
                value: _qadaEnabled,
                onChanged: (value) => setState(() => _qadaEnabled = value),
              ),
              const SizedBox(height: 12),
              _buildSwitchTile(
                title: 'Nafile Hatırlatmaları',
                subtitle: 'Duha, İşrak ve diğerlerini bildirim olarak al.',
                value: _notificationsEnabled,
                onChanged:
                    (value) => setState(() => _notificationsEnabled = value),
              ),
              const SizedBox(height: 24),
              Text(
                'Ekstra İbadetler',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    ExtraPrayerType.values.map((type) {
                      final isSelected = _selectedExtraPrayers.contains(type);
                      return ChoiceChip(
                        label: Text(type.title),
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
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon:
                      isSaving
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.check_circle_outline),
                  label: Text(isEditing ? 'Profili Kaydet' : 'Başla'),
                  onPressed: isSaving ? null : _submit,
                ),
              ),
            ],
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
            color: Colors.black.withOpacity(0.05),
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
    
    if (_selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen doğum tarihinizi seçin')),
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
