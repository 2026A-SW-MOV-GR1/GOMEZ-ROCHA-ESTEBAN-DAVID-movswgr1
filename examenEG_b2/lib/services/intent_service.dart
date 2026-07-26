import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'intent_contract.dart';

class IntentService {
  IntentService._();

  static Future<void> sendLostPetReport({
    required String petId,
    required String petName,
    required String petType,
    required String description,
    required double lastSeenLat,
    required double lastSeenLng,
    required String contactPhone,
    required String reportedAt,
  }) async {
    final intent = AndroidIntent(
      action: IntentContract.actionLostPetReported,
      category: IntentContract.categoryDefault,
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      arguments: {
        IntentContract.extraPetId: petId,
        IntentContract.extraPetName: petName,
        IntentContract.extraPetType: petType,
        IntentContract.extraDescription: description,
        IntentContract.extraLastSeenLat: lastSeenLat,
        IntentContract.extraLastSeenLng: lastSeenLng,
        IntentContract.extraContactPhone: contactPhone,
        IntentContract.extraReportedAt: reportedAt,
      },
    );

    final canResolve = await intent.canResolveActivity();
    if (canResolve == true) {
      await intent.launch();
    }
  }
}