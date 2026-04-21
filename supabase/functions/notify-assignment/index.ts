// Supabase Edge Function: notify-assignment
// Triggered by the app (admin) after assigning a volunteer.
//
// NOTE:
// - For production, store device tokens in a table like `device_tokens`
// - Use service-role key only inside the function (never ship to client)
// - Send notifications via FCM HTTP v1 (service account) or legacy API

import "jsr:@supabase/supabase-js@2";

Deno.serve(async (req) => {
  try {
    const payload = await req.json();
    const volunteerId = payload.volunteer_id as string | undefined;
    const taskId = payload.task_id as string | undefined;
    const title = payload.title as string | undefined;

    if (!volunteerId || !taskId) {
      return new Response(JSON.stringify({ error: "Missing volunteer_id or task_id" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    // TODO: lookup FCM tokens for volunteerId and send notification
    // Example shape:
    // { "to": "<token>", "notification": { "title": "...", "body": "..." } }

    return new Response(
      JSON.stringify({
        ok: true,
        message: "Stubbed notify-assignment (implement FCM send here).",
        volunteer_id: volunteerId,
        task_id: taskId,
        title,
      }),
      { headers: { "Content-Type": "application/json" } },
    );
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});

