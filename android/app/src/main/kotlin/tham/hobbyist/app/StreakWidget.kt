package tham.hobbyist.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Build
import android.widget.RemoteViews
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale

/**
 * Android home-screen widget displaying the user's current streak and a
 * **rolling 7-day window** anchored on today.
 *
 * Data is written by HomeWidgetService (Dart) via the home_widget plugin's
 * SharedPreferences file ("HomeWidgetPlugin").  This provider reads that
 * store on every update and rebuilds RemoteViews accordingly.
 *
 * SharedPreferences keys (written by Dart):
 *   streak_current      – Int,    global consecutive-day streak count
 *   streak_days         – String, 7-char bitmask "1101100"
 *                         index 0 = 6 days ago … index 6 = today
 *   streak_has_hobbies  – Int,    1 = user has hobbies, 0 = fresh install
 *   streak_user_name    – String, display name (empty = not set)
 *
 * Day circle states:
 *   widget_day_done        – solid green, past completed
 *   widget_day_done_today  – bright green + border, today completed
 *   widget_day_today       – solid orange, today pending (fire emoji)
 *   widget_day_missed      – dull red, past missed (hobbies exist)
 *   widget_day_pending     – muted grey, fresh-install or future slot
 */
class StreakWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (widgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, widgetId)
        }
    }

    companion object {

        private val DAY_LABEL_IDS = intArrayOf(
            R.id.day_label_0, R.id.day_label_1, R.id.day_label_2,
            R.id.day_label_3, R.id.day_label_4, R.id.day_label_5,
            R.id.day_label_6,
        )
        private val DAY_CIRCLE_IDS = intArrayOf(
            R.id.day_circle_0, R.id.day_circle_1, R.id.day_circle_2,
            R.id.day_circle_3, R.id.day_circle_4, R.id.day_circle_5,
            R.id.day_circle_6,
        )

        // Single-char abbreviations indexed by Calendar.DAY_OF_WEEK (1=Sun … 7=Sat)
        private val DAY_ABBR_BY_DOW = arrayOf("", "S", "M", "T", "W", "T", "F", "S")

        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            widgetId: Int,
        ) {
            val prefs = context.getSharedPreferences(
                "HomeWidgetPlugin",
                Context.MODE_PRIVATE,
            )
            val streak     = prefs.getInt("streak_current", 0)
            val daysStr    = prefs.getString("streak_days", "0000000") ?: "0000000"
            val hasHobbies = prefs.getInt("streak_has_hobbies", 0) == 1
            val userName   = prefs.getString("streak_user_name", "") ?: ""

            val views = RemoteViews(context.packageName, R.layout.streak_widget)

            // ── Tap widget → open app ─────────────────────────────────────
            val launchIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val piFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            else
                PendingIntent.FLAG_UPDATE_CURRENT

            views.setOnClickPendingIntent(
                R.id.widget_root,
                PendingIntent.getActivity(context, 0, launchIntent, piFlags),
            )

            // ── Header ────────────────────────────────────────────────────
            views.setTextViewText(R.id.streak_pill, "🔥 $streak")
            views.setTextViewText(R.id.widget_subtitle, subtitleFor(streak, userName, hasHobbies))

            // ── CTA ───────────────────────────────────────────────────────
            views.setTextViewText(R.id.cta_button, "⚡  ${ctaFor(streak)}")

            // ── Rolling 7-day window (index 6 = today) ────────────────────
            val days = daysStr.padEnd(7, '0')
            val sdf  = SimpleDateFormat("EEE", Locale.ENGLISH)

            for (i in 0..6) {
                val completed = days.getOrElse(i) { '0' } == '1'
                val isToday   = i == 6      // rolling window always has today at index 6
                val isMissed  = !isToday && !completed && hasHobbies

                // Rolling day label: compute weekday of (today - (6 - i))
                val cal = Calendar.getInstance()
                cal.add(Calendar.DAY_OF_YEAR, -(6 - i))
                val label = sdf.format(cal.time)[0].uppercaseChar().toString()
                views.setTextViewText(DAY_LABEL_IDS[i], label)

                // Label brightness: today = full white, past = dimmer
                views.setTextColor(
                    DAY_LABEL_IDS[i],
                    if (isToday) Color.WHITE else Color.argb(100, 255, 255, 255),
                )

                // Circle background
                val circleDrawable = when {
                    isToday && completed -> R.drawable.widget_day_done_today
                    isToday              -> R.drawable.widget_day_today
                    completed            -> R.drawable.widget_day_done
                    isMissed             -> R.drawable.widget_day_missed
                    else                 -> R.drawable.widget_day_pending
                }
                views.setInt(DAY_CIRCLE_IDS[i], "setBackgroundResource", circleDrawable)

                // Circle text symbol
                val symbol = when {
                    completed            -> "✓"
                    isToday              -> "🔥"
                    isMissed             -> "✗"
                    else                 -> ""
                }
                views.setTextViewText(DAY_CIRCLE_IDS[i], symbol)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }

        // ── Copy helpers ──────────────────────────────────────────────────

        private fun subtitleFor(streak: Int, userName: String, hasHobbies: Boolean): String {
            if (userName.isNotBlank()) return "Keep it up, $userName"
            if (!hasHobbies) return "Create your first task to start your streak"
            return "Keep going — you're building a great habit"
        }

        private fun ctaFor(streak: Int): String =
            if (streak == 0) "Start your streak today" else "Stay Consistent"
    }
}
