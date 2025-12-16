import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_app/features/subjects/domain/schedule_model.dart';
import 'package:mobile_app/features/subjects/domain/subject.dart';
import 'package:mobile_app/features/subjects/presentation/providers/subject_provider.dart';
import 'package:mobile_app/core/widgets/modern_card.dart';
import 'package:mobile_app/core/widgets/modern_button.dart';
import 'package:mobile_app/core/theme/app_palette.dart';

class AddSubjectScreen extends HookConsumerWidget {
  final Subject? existingSubject;
  
  const AddSubjectScreen({super.key, this.existingSubject});

  bool get isEditing => existingSubject != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final teacherNameController = useTextEditingController();
    final teacherEmailController = useTextEditingController();
    final teacherPhoneController = useTextEditingController();
    final locationController = useTextEditingController();
    
    final selectedColor = useState<Color>(const Color(0xFF3B82F6));
    final selectedCategory = useState<String?>(null);
    final selectedDifficulty = useState<String?>(null);
    final hasStudyGoal = useState<bool>(false);
    final studyGoalHours = useState<double>(5.0);
    final schedules = useState<List<ScheduleItem>>([]);
    final isExpanded = useState<bool>(true);
    final isLoading = useState<bool>(false);
    final hasInitialized = useState<bool>(false);

    final formKey = useMemoized(() => GlobalKey<FormState>());

    // Pre-populate fields when editing an existing subject
    useEffect(() {
      if (existingSubject != null && !hasInitialized.value) {
        hasInitialized.value = true;
        nameController.text = existingSubject!.name;
        teacherNameController.text = existingSubject!.teacherName ?? '';
        teacherEmailController.text = existingSubject!.teacherEmail ?? '';
        teacherPhoneController.text = existingSubject!.teacherPhone ?? '';
        
        // Parse color from hex string
        try {
          final hexColor = existingSubject!.color.replaceAll('#', '');
          selectedColor.value = Color(int.parse('FF$hexColor', radix: 16));
        } catch (_) {
          // Keep default color if parsing fails
        }
        
        selectedCategory.value = existingSubject!.category;
        selectedDifficulty.value = existingSubject!.difficulty;
        
        if (existingSubject!.studyGoalHours > 0) {
          hasStudyGoal.value = true;
          studyGoalHours.value = existingSubject!.studyGoalHours;
        }
        
        schedules.value = List<ScheduleItem>.from(existingSubject!.schedules);
      }
      return null;
    }, [existingSubject]);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Subject' : 'Add New Subject',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppPalette.darkBackground,
                    AppPalette.darkSurface,
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppPalette.lightBackground,
                    AppPalette.lightSurface,
                  ],
                ),
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ========== SECTION 1: Basic Info ==========
                AnimatedModernCard(
                  padding: const EdgeInsets.all(24),
                  borderRadius: 24,
                  delay: 100.ms,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: isDark
                                  ? AppPalette.darkPrimaryGradient
                                  : AppPalette.lightPrimaryGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              LucideIcons.bookOpen,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Basic Information',
                              style: GoogleFonts.poppins(
                                fontSize: MediaQuery.of(context).size.width < 360 ? 18 : 20,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
              
                      // Subject Name
                      TextFormField(
                        controller: nameController,
                        style: GoogleFonts.poppins(),
                        decoration: InputDecoration(
                          labelText: 'Subject Name *',
                          hintText: 'e.g., Mathematics',
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              LucideIcons.bookOpen,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outline.withValues(alpha: 0.1),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Subject name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedCategory.value,
                        style: GoogleFonts.poppins(
                          color: theme.colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Category',
                          hintText: 'Select a category',
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              LucideIcons.folder,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outline.withValues(alpha: 0.1),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        ),
                items: const [
                  DropdownMenuItem(value: 'Mathematics', child: Text('Mathematics')),
                  DropdownMenuItem(value: 'Science', child: Text('Science')),
                  DropdownMenuItem(value: 'Language', child: Text('Language')),
                  DropdownMenuItem(value: 'Arts', child: Text('Arts')),
                  DropdownMenuItem(value: 'History', child: Text('History')),
                  DropdownMenuItem(value: 'Computer Science', child: Text('Computer Science')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) {
                  selectedCategory.value = value;
                  // Auto-color logic
                  if (value != null) {
                    Color newColor;
                    switch (value) {
                      case 'Mathematics':
                        newColor = const Color(0xFF3B82F6); // Blue
                        break;
                      case 'Science':
                        newColor = const Color(0xFF10B981); // Green
                        break;
                      case 'Arts':
                        newColor = const Color(0xFFF59E0B); // Orange
                        break;
                      default:
                        newColor = selectedColor.value; // Keep current color
                    }
                    selectedColor.value = newColor;
                  }
                },
              ),
                      const SizedBox(height: 20),

                      // Difficulty Selector (Chips)
                      Text(
                        'Difficulty',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _ModernDifficultyChip(
                              label: 'Easy',
                              isSelected: selectedDifficulty.value == 'Easy',
                              onSelected: (selected) {
                                selectedDifficulty.value = selected ? 'Easy' : null;
                              },
                              color: const Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ModernDifficultyChip(
                              label: 'Medium',
                              isSelected: selectedDifficulty.value == 'Medium',
                              onSelected: (selected) {
                                selectedDifficulty.value = selected ? 'Medium' : null;
                              },
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ModernDifficultyChip(
                              label: 'Hard',
                              isSelected: selectedDifficulty.value == 'Hard',
                              onSelected: (selected) {
                                selectedDifficulty.value = selected ? 'Hard' : null;
                              },
                              color: const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Color Picker
                      Text(
                        'Color',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Current color display
                          GestureDetector(
                            onTap: () => _showColorPicker(context, selectedColor),
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: selectedColor.value,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: selectedColor.value.withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                                  width: 1.5,
                                ),
                                color: theme.colorScheme.surfaceContainerHighest,
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _showColorPicker(context, selectedColor),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          LucideIcons.palette,
                                          color: theme.colorScheme.primary,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Choose Color',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ========== SECTION 2: Teacher Info ==========
                AnimatedModernCard(
                  padding: const EdgeInsets.all(24),
                  borderRadius: 24,
                  delay: 200.ms,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: isDark
                                  ? AppPalette.darkSecondaryGradient
                                  : AppPalette.lightSecondaryGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              LucideIcons.user,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Teacher Information',
                              style: GoogleFonts.poppins(
                                fontSize: MediaQuery.of(context).size.width < 360 ? 18 : 20,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: teacherNameController,
                        style: GoogleFonts.poppins(),
                        decoration: InputDecoration(
                          labelText: 'Teacher Name',
                          hintText: 'e.g., Dr. Smith',
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              LucideIcons.user,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outline.withValues(alpha: 0.1),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: teacherEmailController,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.poppins(),
                        decoration: InputDecoration(
                          labelText: 'Teacher Email',
                          hintText: 'teacher@university.edu',
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              LucideIcons.mail,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outline.withValues(alpha: 0.1),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: teacherPhoneController,
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.poppins(),
                        decoration: InputDecoration(
                          labelText: 'Teacher Phone',
                          hintText: '+1234567890',
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              LucideIcons.phone,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outline.withValues(alpha: 0.1),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ========== SECTION 3: Class Schedule ==========
                AnimatedModernCard(
                  padding: const EdgeInsets.all(24),
                  borderRadius: 24,
                  delay: 300.ms,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: isDark
                                  ? AppPalette.darkAccentGradient
                                  : LinearGradient(
                                      colors: [
                                        AppPalette.lightAccent,
                                        AppPalette.lightAccentDark,
                                      ],
                                    ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              LucideIcons.calendar,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Class Schedule',
                              style: GoogleFonts.poppins(
                                fontSize: MediaQuery.of(context).size.width < 360 ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              gradient: isDark
                                  ? AppPalette.darkPrimaryGradient
                                  : AppPalette.lightPrimaryGradient,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _showAddScheduleDialog(
                                  context,
                                  schedules,
                                  locationController,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        LucideIcons.plus,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Add',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Schedule List
                      if (schedules.value.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  LucideIcons.calendar,
                                  size: 56,
                                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No schedule added yet',
                                  style: GoogleFonts.poppins(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...schedules.value.asMap().entries.map((entry) {
                          final index = entry.key;
                          final schedule = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.colorScheme.outline.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: isDark
                                        ? AppPalette.darkPrimaryGradient
                                        : AppPalette.lightPrimaryGradient,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      schedule.dayOfWeek.substring(0, 3),
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${schedule.startTime} - ${schedule.endTime}',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      if (schedule.location != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          '@ ${schedule.location}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(LucideIcons.edit, size: 20),
                                  color: theme.colorScheme.primary,
                                  onPressed: () => _showEditScheduleDialog(
                                    context,
                                    schedules,
                                    index,
                                    locationController,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(LucideIcons.trash2, size: 20),
                                  color: theme.colorScheme.error,
                                  onPressed: () {
                                    final newSchedules = List<ScheduleItem>.from(schedules.value);
                                    newSchedules.removeAt(index);
                                    schedules.value = newSchedules;
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ========== SECTION 4: Goals ==========
                AnimatedModernCard(
                  padding: const EdgeInsets.all(24),
                  borderRadius: 24,
                  delay: 400.ms,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [
                                        AppPalette.darkSuccess,
                                        AppPalette.darkSuccess.withValues(alpha: 0.8),
                                      ]
                                    : [
                                        AppPalette.lightSuccess,
                                        AppPalette.lightSuccess.withValues(alpha: 0.8),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              LucideIcons.target,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Study Goals',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.outline.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Set Study Goal',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                if (hasStudyGoal.value) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '${studyGoalHours.value.toStringAsFixed(1)} hours per week',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Switch(
                              value: hasStudyGoal.value,
                              onChanged: (value) => hasStudyGoal.value = value,
                            ),
                          ],
                        ),
                      ),
                      if (hasStudyGoal.value) ...[
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: Icon(LucideIcons.minus),
                                onPressed: () {
                                  if (studyGoalHours.value > 0) {
                                    studyGoalHours.value = studyGoalHours.value - 0.5;
                                  }
                                },
                              ),
                            ),
                            Expanded(
                              child: Slider(
                                value: studyGoalHours.value,
                                min: 0,
                                max: 50,
                                divisions: 100,
                                label: '${studyGoalHours.value.toStringAsFixed(1)} hours',
                                onChanged: (value) => studyGoalHours.value = value,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: Icon(LucideIcons.plus),
                                onPressed: () {
                                  if (studyGoalHours.value < 50) {
                                    studyGoalHours.value = studyGoalHours.value + 0.5;
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: isDark
                                  ? AppPalette.darkPrimaryGradient
                                  : AppPalette.lightPrimaryGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${studyGoalHours.value.toStringAsFixed(1)} hours per week',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ========== FOOTER: Save Button ==========
                ModernElevatedButton(
                  gradient: isDark
                      ? AppPalette.darkPrimaryGradient
                      : AppPalette.lightPrimaryGradient,
                  onPressed: isLoading.value
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          isLoading.value = true;

                          try {
                            // Convert schedules to ScheduleItem objects for API
                            final scheduleItems = schedules.value.map((schedule) {
                              return ScheduleItem(
                                id: '', // Will be generated by backend
                                dayOfWeek: schedule.dayOfWeek,
                                startTime: schedule.startTime,
                                endTime: schedule.endTime,
                                location: schedule.location,
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                              );
                            }).toList();

                            // Convert Color to hex string
                            final colorValue = selectedColor.value.value;
                            final hexColor = '#${colorValue.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
                            
                            if (isEditing) {
                              // Update existing subject
                              await ref.read(subjectProvider.notifier).updateSubject(
                                    id: existingSubject!.id,
                                    name: nameController.text.trim(),
                                    color: hexColor,
                                    teacherName: teacherNameController.text.trim().isEmpty
                                        ? null
                                        : teacherNameController.text.trim(),
                                    teacherEmail: teacherEmailController.text.trim().isEmpty
                                        ? null
                                        : teacherEmailController.text.trim(),
                                    teacherPhone: teacherPhoneController.text.trim().isEmpty
                                        ? null
                                        : teacherPhoneController.text.trim(),
                                    studyGoalHours: hasStudyGoal.value
                                        ? studyGoalHours.value
                                        : 0.0,
                                    category: selectedCategory.value,
                                    difficulty: selectedDifficulty.value,
                                    schedules: scheduleItems.isNotEmpty ? scheduleItems : null,
                                  );
                            } else {
                              // Create new subject
                              await ref.read(subjectProvider.notifier).createSubject(
                                    name: nameController.text.trim(),
                                    color: hexColor,
                                    teacherName: teacherNameController.text.trim().isEmpty
                                        ? null
                                        : teacherNameController.text.trim(),
                                    teacherEmail: teacherEmailController.text.trim().isEmpty
                                        ? null
                                        : teacherEmailController.text.trim(),
                                    teacherPhone: teacherPhoneController.text.trim().isEmpty
                                        ? null
                                        : teacherPhoneController.text.trim(),
                                    studyGoalHours: hasStudyGoal.value
                                        ? studyGoalHours.value
                                        : null,
                                    category: selectedCategory.value,
                                    difficulty: selectedDifficulty.value,
                                    schedules: scheduleItems.isNotEmpty ? scheduleItems : null,
                                  );
                            }

                            if (context.mounted) {
                              context.pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isEditing ? 'Subject updated successfully!' : 'Subject created successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } finally {
                            isLoading.value = false;
                          }
                        },
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  borderRadius: 18,
                  child: isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.check,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Save Subject',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 500.ms)
                    .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 500.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context, ValueNotifier<Color> selectedColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Choose Color',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: ColorPicker(
            color: selectedColor.value,
            onColorChanged: (color) => selectedColor.value = color,
            width: 40,
            height: 40,
            borderRadius: 8,
            spacing: 5,
            runSpacing: 5,
            wheelDiameter: 155,
            heading: Text(
              'Select color',
              style: GoogleFonts.poppins(),
            ),
            subheading: Text(
              'Select color shade',
              style: GoogleFonts.poppins(),
            ),
            wheelSubheading: Text(
              'Selected color and its shades',
              style: GoogleFonts.poppins(),
            ),
            showMaterialName: true,
            showColorName: true,
            showColorCode: true,
            copyPasteBehavior: const ColorPickerCopyPasteBehavior(
              longPressMenu: true,
            ),
            materialNameTextStyle: GoogleFonts.poppins(),
            colorNameTextStyle: GoogleFonts.poppins(),
            colorCodeTextStyle: GoogleFonts.poppins(),
            pickersEnabled: const <ColorPickerType, bool>{
              ColorPickerType.both: false,
              ColorPickerType.primary: true,
              ColorPickerType.accent: true,
              ColorPickerType.bw: false,
              ColorPickerType.custom: true,
              ColorPickerType.wheel: true,
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Done', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _showAddScheduleDialog(
    BuildContext context,
    ValueNotifier<List<ScheduleItem>> schedules,
    TextEditingController locationController,
  ) {
    _showScheduleDialog(
      context,
      schedules,
      null,
      locationController,
    );
  }

  void _showEditScheduleDialog(
    BuildContext context,
    ValueNotifier<List<ScheduleItem>> schedules,
    int index,
    TextEditingController locationController,
  ) {
    _showScheduleDialog(
      context,
      schedules,
      index,
      locationController,
    );
  }

  void _showScheduleDialog(
    BuildContext context,
    ValueNotifier<List<ScheduleItem>> schedules,
    int? editIndex,
    TextEditingController locationController,
  ) {
    // Initialize state variables
    String dayOfWeek = 'Mon';
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 0);

    // Initialize with existing values if editing
    if (editIndex != null && editIndex < schedules.value.length) {
      final schedule = schedules.value[editIndex];
      dayOfWeek = schedule.dayOfWeek;
      startTime = ScheduleItem.stringToTimeOfDay(schedule.startTime);
      endTime = ScheduleItem.stringToTimeOfDay(schedule.endTime);
      locationController.text = schedule.location ?? '';
    } else {
      locationController.clear();
    }

    final daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            editIndex != null ? 'Edit Schedule' : 'Add Schedule',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Day of Week Dropdown
                DropdownButtonFormField<String>(
                  value: dayOfWeek,
                  decoration: InputDecoration(
                    labelText: 'Day of Week',
                    prefixIcon: const Icon(LucideIcons.calendar),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: daysOfWeek.map((day) {
                    return DropdownMenuItem(
                      value: day,
                      child: Text(
                        day,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => dayOfWeek = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Start Time
                ListTile(
                  leading: const Icon(LucideIcons.clock),
                  title: const Text('Start Time'),
                  subtitle: Text(
                    DateFormat('h:mm a').format(
                      DateTime(2024, 1, 1, startTime.hour, startTime.minute),
                    ),
                  ),
                  trailing: FilledButton(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: startTime,
                      );
                      if (picked != null) {
                        setState(() => startTime = picked);
                      }
                    },
                    child: const Text('Select'),
                  ),
                ),
                const SizedBox(height: 8),

                // End Time
                ListTile(
                  leading: const Icon(LucideIcons.clock),
                  title: const Text('End Time'),
                  subtitle: Text(
                    DateFormat('h:mm a').format(
                      DateTime(2024, 1, 1, endTime.hour, endTime.minute),
                    ),
                  ),
                  trailing: FilledButton(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: endTime,
                      );
                      if (picked != null) {
                        setState(() => endTime = picked);
                      }
                    },
                    child: const Text('Select'),
                  ),
                ),
                const SizedBox(height: 16),

                // Location
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: 'Room/Location',
                    hintText: 'e.g., Room 101',
                    prefixIcon: const Icon(LucideIcons.mapPin),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            FilledButton(
              onPressed: () {
                final newSchedule = ScheduleItem(
                  id: editIndex != null && editIndex < schedules.value.length
                      ? schedules.value[editIndex].id
                      : '',
                  dayOfWeek: dayOfWeek,
                  startTime: ScheduleItem.timeOfDayToString(startTime),
                  endTime: ScheduleItem.timeOfDayToString(endTime),
                  location: locationController.text.isEmpty ? null : locationController.text,
                  createdAt: editIndex != null && editIndex < schedules.value.length
                      ? schedules.value[editIndex].createdAt
                      : DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                final newSchedules = List<ScheduleItem>.from(schedules.value);
                if (editIndex != null) {
                  newSchedules[editIndex] = newSchedule;
                } else {
                  newSchedules.add(newSchedule);
                }
                schedules.value = newSchedules;

                Navigator.pop(context);
              },
              child: Text(
                editIndex != null ? 'Update' : 'Add',
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modern Difficulty Chip Widget
class _ModernDifficultyChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;
  final Color color;

  const _ModernDifficultyChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelected(!isSelected),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      color,
                      color.withValues(alpha: 0.8),
                    ],
                  )
                : null,
            color: isSelected ? null : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isSelected
                    ? Colors.white
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

