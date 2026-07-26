class IntentContract {
  IntentContract._();

  static const String actionLostPetReported =
      'com.examenb2.petflow.action.LOST_PET_REPORTED';

  static const String categoryDefault = 'android.intent.category.DEFAULT';

  // Extras Paso 1 → 2
  static const String extraPetId = 'pet_id';
  static const String extraPetName = 'pet_name';
  static const String extraPetType = 'pet_type';
  static const String extraDescription = 'description';
  static const String extraLastSeenLat = 'last_seen_lat';
  static const String extraLastSeenLng = 'last_seen_lng';
  static const String extraContactPhone = 'contact_phone';
  static const String extraReportedAt = 'reported_at';
}