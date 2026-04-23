import 'package:flutter/foundation.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import '/../models/user_session.dart';
import '/../models/landlord_profile.dart';
import '/../services/api_service.dart';


class BuildYourProfileViewModel extends ChangeNotifier {
  String bio = '';
  String university = '';
  String? major;
  int? birthYear;
  int? graduationYear;
  Set<String> selectedHobbies = {};
  String? profilePhotoPath;
  static const int maxHobbies = 5;

  static final List<int> birthYears =
      List.generate(DateTime.now().year - 1970 + 1, (i) => 1970 + i);
  static final List<int> gradYears =
      List.generate(DateTime.now().year - 1970 + 6, (i) => 1970 + i);

  static const List<String> majors = [
    'Computer Science', 'Business Administration', 'Mechanical Engineering',
    'Electrical Engineering', 'Civil Engineering', 'Economics', 'Psychology',
    'Biology', 'Chemistry', 'Mathematics', 'Physics', 'Political Science',
    'Communications', 'Architecture', 'Law', 'Medicine', 'Nursing', 'Finance',
    'Marketing', 'Graphic Design', 'Industrial Engineering',
    'Environmental Science', 'International Relations', 'Data Science',
    'Philosophy', 'Sociology', 'Art History', 'Music', 'Education', 'Other',
  ];

  static const List<String> hobbies = [
    '📚 Reading', '😴 Sleeping', '🎣 Fishing', '🌙 Star gazing',
    '🧗 Rock climbing', '👾 Netflix', '🏃 Running', '🏕 Camping',
    '🎮 Video games', '🍳 Cooking', '✍️ Journaling', '🥳 Partying',
  ];

  void toggleHobby(String hobby) {
    if (selectedHobbies.contains(hobby)) {
      selectedHobbies.remove(hobby);
    } else if (selectedHobbies.length < maxHobbies) {
      selectedHobbies.add(hobby);
    }
    notifyListeners();
  }

  bool get canContinue => selectedHobbies.isNotEmpty;
}


enum HousingSituation {
  havePlace,
  needPlace;

  String get title => switch (this) {
        HousingSituation.havePlace => 'Ya tengo un lugar',
        HousingSituation.needPlace => 'Necesito un lugar',
      };

  String get subtitle => switch (this) {
        HousingSituation.havePlace => 'Busco un roommate para compartir',
        HousingSituation.needPlace => 'Busco donde vivir',
      };

  String get description => switch (this) {
        HousingSituation.havePlace =>
          'Mi depto está listo. Necesito encontrar a la persona correcta para compartirlo.',
        HousingSituation.needPlace =>
          'Busco un lugar cerca del campus que se adapte a mi presupuesto y estilo de vida.',
      };

  String get icon => switch (this) {
        HousingSituation.havePlace => '🏠',
        HousingSituation.needPlace => '📍',
      };
}

class RoommateSituationViewModel extends ChangeNotifier {
  HousingSituation? situation;

  void setSituation(HousingSituation s) {
    situation = s;
    notifyListeners();
  }

  bool get canContinue => situation != null;
}


class RoommatePreferencesViewModel extends ChangeNotifier {
  int spotsAvailable = 1;
  String? moveInMonth;
  int? genderPreference;
  int? sleepSchedule;
  int? cleanliness;
  Set<String> selectedLifestyle = {};
  Set<String> selectedRequirements = {};

  void toggle(Set<String> set, String item) {
    if (set.contains(item)) {
      set.remove(item);
    } else {
      set.add(item);
    }
    notifyListeners();
  }

  void setSpotsAvailable(int n) { spotsAvailable = n; notifyListeners(); }
  void setMoveInMonth(String? m) { moveInMonth = m; notifyListeners(); }
  void setGenderPreference(int? v) { genderPreference = v; notifyListeners(); }
  void setSleepSchedule(int? v) { sleepSchedule = v; notifyListeners(); }
  void setCleanliness(int? v) { cleanliness = v; notifyListeners(); }
}


class ListingPreferencesViewModel extends ChangeNotifier {
  int? maxBudget = 850;
  String? propertyType;
  DateTime moveInDate = DateTime.now();
  int leaseLength = 6;
  int? maxDistance;
  Set<String> selectedAmenities = {};
  Set<String> selectedPreferences = {};

  static const List<int> budgetOptions = [300, 600, 900, 1200];
  static const List<int> leaseOptions = [3, 6, 12];

  static const List<Map<String, String>> propertyTypes = [
    {'emoji': '🛋', 'label': 'Studio', 'sub': 'Espacio privado y compacto'},
    {'emoji': '🚪', 'label': '1 Bedroom', 'sub': 'Dormitorio y sala separados'},
    {'emoji': '🏠', 'label': 'Shared room', 'sub': 'Compartir costo con roommates'},
    {'emoji': '🏢', 'label': 'Any', 'sub': 'Mostrar todo'},
  ];

  static const List<Map<String, dynamic>> distanceOptions = [
    {'label': '≤ 500m', 'value': 0},
    {'label': '≤ 1 km', 'value': 1},
    {'label': '≤ 2 km', 'value': 2},
    {'label': 'Cualquier', 'value': 3},
  ];

  static const List<Map<String, String>> amenities = [
    {'emoji': '📶', 'label': 'WiFi'}, {'emoji': '🧺', 'label': 'Laundry'},
    {'emoji': '❄️', 'label': 'AC'}, {'emoji': '🛋', 'label': 'Furnished'},
    {'emoji': '🐾', 'label': 'Pet-friendly'}, {'emoji': '🏋️', 'label': 'Gym'},
  ];

  static const List<Map<String, String>> preferences = [
    {'emoji': '🚭', 'label': 'Smoke-free', 'sub': 'Solo unidades sin fumadores'},
    {'emoji': '🎓', 'label': 'Students only', 'sub': 'Estudiantes verificados como inquilinos'},
    {'emoji': '📸', 'label': 'Photos required', 'sub': 'Solo listings con fotos'},
  ];

  void setMaxBudget(int v) { maxBudget = v; notifyListeners(); }
  void setPropertyType(String? v) { propertyType = propertyType == v ? null : v; notifyListeners(); }
  void setMoveInDate(DateTime d) { moveInDate = d; notifyListeners(); }
  void setLeaseLength(int v) { leaseLength = v; notifyListeners(); }
  void setMaxDistance(int? v) { maxDistance = maxDistance == v ? null : v; notifyListeners(); }
  void toggleAmenity(String v) {
    selectedAmenities.contains(v) ? selectedAmenities.remove(v) : selectedAmenities.add(v);
    notifyListeners();
  }
  void togglePreference(String v) {
    selectedPreferences.contains(v) ? selectedPreferences.remove(v) : selectedPreferences.add(v);
    notifyListeners();
  }
}


class NewListingViewModel extends ChangeNotifier {
  String title = '';
  String monthlyRent = '';
  String securityDeposit = '';
  String? propertyType;
  String leaseLength = '12 months';
  DateTime availableFrom = DateTime.now();
  Set<String> selectedAmenities = {};
  Set<String> selectedRules = {};
  String description = '';

  static const List<String> propertyTypes = [
    'Shared room', 'Studio', '1 bedroom', '2 bedrooms', '3+ bedrooms',
  ];
  static const List<String> leaseOptions = [
    '3 months', '6 months', '12 months', '24 months',
  ];
  static const List<String> amenities = [
    'WiFi', 'Laundry', 'Parking', 'AC', 'Gym', 'Pool', 'Balcony', 'Furnished',
  ];
  static const List<String> rules = [
    'No smoking', 'No parties', 'No pets', 'No overnight guests',
    'Quiet after 10 pm', 'Students only',
  ];
  static const int descriptionMinChars = 80;

  void toggleAmenity(String v) {
    selectedAmenities.contains(v) ? selectedAmenities.remove(v) : selectedAmenities.add(v);
    notifyListeners();
  }
  void toggleRule(String v) {
    selectedRules.contains(v) ? selectedRules.remove(v) : selectedRules.add(v);
    notifyListeners();
  }

  bool get canContinue => title.isNotEmpty && monthlyRent.isNotEmpty;
}

class OnboardingViewModel extends ChangeNotifier {
  int step = 0;
  bool isLoading = false;
  String? errorMessage;
  bool showCelebration = false;
  LandlordProfile? completedProfile;

  bool isLandlord = false;

  int get totalSteps => isLandlord ? 2 : 3;
  bool get isLastStep => step == totalSteps - 1;
  bool get needsPlace => situation.situation == HousingSituation.needPlace;

  final buildProfile = BuildYourProfileViewModel();
  final situation = RoommateSituationViewModel();
  final preferences = RoommatePreferencesViewModel();
  final listingPrefs = ListingPreferencesViewModel();
  final newListing = NewListingViewModel();

  OnboardingViewModel() {
    buildProfile.addListener(notifyListeners);
    situation.addListener(notifyListeners);
    preferences.addListener(notifyListeners);
    listingPrefs.addListener(notifyListeners);
    newListing.addListener(notifyListeners);
  }

  bool get canContinue => switch (step) {
        0 => buildProfile.canContinue,
        1 => isLandlord ? newListing.canContinue : situation.canContinue,
        _ => true,
      };

  void previousStep() {
    if (step > 0) { step--; notifyListeners(); }
  }

  Future<void> nextStep(ClerkAuthState auth) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final tokenObj = await auth.sessionToken();
    final token = tokenObj?.jwt;
    if (token == null) {
      errorMessage = 'No se pudo obtener el token de sesión';
      isLoading = false;
      notifyListeners();
      return;
    }

    if (step == 0) {
      if (isLandlord) {
        await _saveLandlordProfile(token);
      } else {
        await _saveStudentProfile(token);
      }
    }

    if (errorMessage == null && step < totalSteps - 1) {
      step++;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> complete(ClerkAuthState auth) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final tokenObj = await auth.sessionToken();
    final token = tokenObj?.jwt;
    if (token == null) {
      errorMessage = 'No se pudo obtener el token de sesión';
      isLoading = false;
      notifyListeners();
      return;
    }

    if (isLandlord) {
      await _saveNewListing(token);
    } else if (needsPlace) {
      await _saveListingProfile(token);
    } else {
      await _saveLifestyleProfile(token);
    }

    if (errorMessage != null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final profile = await ApiService().updateProfile(
        {'onboarded': true},
        token: token,
      );
      completedProfile = profile;
      showCelebration = true;
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('[Onboarding] complete failed: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  void finishOnboarding(UserSession session) {
    if (completedProfile != null) session.setLoaded(completedProfile!);
  }


  Future<void> _saveLandlordProfile(String token) async {
    final bp = buildProfile;
    final fields = <String, dynamic>{};
    if (bp.birthYear != null) fields['birth_year'] = bp.birthYear;
    if (bp.bio.isNotEmpty) fields['bio'] = bp.bio;
    if (bp.selectedHobbies.isNotEmpty) {
      fields['hobbies'] = _cleanHobbies(bp.selectedHobbies.toList());
    }
    if (fields.isEmpty) return;
    try {
      await ApiService().patchProfile('/profile/landlord', 'landlord_profile', fields, token: token);
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('[Onboarding] saveLandlordProfile failed: $e');
    }
  }

  Future<void> _saveStudentProfile(String token) async {
    final bp = buildProfile;
    final fields = <String, dynamic>{};
    if (bp.university.isNotEmpty) fields['university'] = bp.university;
    if (bp.major != null) fields['major'] = bp.major;
    if (bp.birthYear != null) fields['birth_year'] = bp.birthYear;
    if (bp.graduationYear != null) fields['graduation_year'] = bp.graduationYear;
    if (bp.bio.isNotEmpty) fields['bio'] = bp.bio;
    if (bp.selectedHobbies.isNotEmpty) {
      fields['hobbies'] = _cleanHobbies(bp.selectedHobbies.toList());
    }
    if (fields.isEmpty) return;
    try {
      await ApiService().patchProfile('/profile/student', 'student_profile', fields, token: token);
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('[Onboarding] saveStudentProfile failed: $e');
    }
  }

  Future<void> _saveLifestyleProfile(String token) async {
    final pref = preferences;
    final fields = <String, dynamic>{
      'spots_available': pref.spotsAvailable,
      if (pref.moveInMonth != null) 'move_in_month': pref.moveInMonth,
      if (pref.genderPreference != null) 'gender_preference': pref.genderPreference,
      if (pref.sleepSchedule != null) 'sleep_schedule': pref.sleepSchedule,
      if (pref.cleanliness != null) 'cleanliness_level': pref.cleanliness,
      if (pref.selectedLifestyle.isNotEmpty)
        'lifestyle': _cleanTags(pref.selectedLifestyle.toList()),
      if (pref.selectedRequirements.isNotEmpty)
        'requirements': _cleanTags(pref.selectedRequirements.toList()),
    };
    try {
      await ApiService().patchProfile('/profile/lifestyle', 'lifestyle_profile', fields, token: token);
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('[Onboarding] saveLifestyleProfile failed: $e');
    }
  }

  Future<void> _saveListingProfile(String token) async {
    final lp = listingPrefs;
    final fields = <String, dynamic>{
      if (lp.maxBudget != null) 'max_budget': lp.maxBudget,
      if (lp.propertyType != null) 'property_type': lp.propertyType,
      'move_in_date': lp.moveInDate.toIso8601String().substring(0, 10),
      'lease_length_months': lp.leaseLength,
      if (lp.maxDistance != null) 'max_distance': lp.maxDistance,
      if (lp.selectedAmenities.isNotEmpty)
        'amenities': lp.selectedAmenities.toList()..sort(),
      if (lp.selectedPreferences.isNotEmpty)
        'preferences': lp.selectedPreferences.toList()..sort(),
    };
    try {
      await ApiService().patchProfile('/profile/listing_preferences', 'listing_profile', fields, token: token);
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('[Onboarding] saveListingProfile failed: $e');
    }
  }

  Future<void> _saveNewListing(String token) async {
    final nl = newListing;
    final fields = <String, dynamic>{
      'listing_type': 'property',
      'title': nl.title,
      if (nl.description.isNotEmpty) 'description': nl.description,
      if (int.tryParse(nl.monthlyRent) != null) 'rent': int.parse(nl.monthlyRent),
      if (int.tryParse(nl.securityDeposit) != null && nl.securityDeposit.isNotEmpty)
        'security_deposit': int.parse(nl.securityDeposit),
      if (nl.propertyType != null) 'property_type': nl.propertyType,
      'available_date': nl.availableFrom.toIso8601String().substring(0, 10),
      if (nl.selectedAmenities.isNotEmpty)
        'amenities': nl.selectedAmenities.toList()..sort(),
      if (nl.selectedRules.isNotEmpty)
        'rules': nl.selectedRules.toList()..sort(),
    };

    final months = int.tryParse(nl.leaseLength.split(' ').first);
    if (months != null) fields['lease_term_months'] = months;

    try {
      await ApiService().createListingRaw(fields, token: token);
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('[Onboarding] saveNewListing failed: $e');
    }
  }


  List<String> _cleanHobbies(List<String> items) => items
      .map((h) => h.replaceAll(RegExp(r'^[^\w\s]+\s*'), '').trim())
      .toList()
    ..sort();

  List<String> _cleanTags(List<String> items) => items
      .map((t) => t.replaceAll(RegExp(r'^[^\w\s]+\s*'), '').trim())
      .toList()
    ..sort();
}