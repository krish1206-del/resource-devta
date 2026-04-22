
import 'supabase_client.dart';

class NotificationService {
  /// Calls Supabase Edge Function `notify-assignment`.
  ///
  /// You must implement FCM server key / service account handling inside the
  /// edge function (recommended) and store device tokens in a secure table.
  static Future<void> notifyAssignment({
    required String volunteerId,
    required String taskId,
    required String title,
  }) async {
    await AppSupabase.client.functions.invoke(
      'notify-assignment',
      body: {
        'volunteer_id': volunteerId,
        'task_id': taskId,
        'title': title,
      },
    );
  }
}

