package tham.hobbyist.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Build
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale

/**
 * Android home-screen widget displaying the user's current streak and a
 * **rolling 7-day window** anchored on today.
 *
 * Layout sections (top → bottom):
 *   1. Hero streak counter — "🔥 N days" (large, bold, top-left)
 *   2. Motivational subtitle — context-aware copy below the counter
 *   3. Weekday label row — M T W T F S S
 *   4. Streak indicator row — 7 circles inside a pill container
 *
 * Data is written by HomeWidgetService (Dart) via the home_widget plugin.
 * This provider reads that store via [HomeWidgetPlugin.getData] on every
 * update — never hardcode the SharedPreferences file name directly, as the
 * plugin's internal constant may differ across versions.
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
            // Use HomeWidgetPlugin.getData() — the correct API for home_widget 0.5+.
            // Do NOT call getSharedPreferences("HomeWidgetPlugin", ...) directly; the
            // plugin's internal PREFERENCES constant may differ from that string and
            // would cause the widget to always read defaults (streak = 0).
            val prefs      = HomeWidgetPlugin.getData(context)
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

            // ── Parse 7-day bitmask ───────────────────────────────────────
            val days          = daysStr.padEnd(7, '0')
            val todayCompleted = days.getOrElse(6) { '0' } == '1'

            // ── Hero streak counter ────────────────────────────────────────
            val dayLabel = if (streak == 1) "day" else "days"
            views.setTextViewText(R.id.streak_hero, "🔥 $streak $dayLabel")

            // ── Subtitle ──────────────────────────────────────────────────
            views.setTextViewText(
                R.id.widget_subtitle,
                subtitleFor(userName, hasHobbies, todayCompleted),
            )

            // ── Rolling 7-day window (index 6 = today) ────────────────────
            val sdf = SimpleDateFormat("EEE", Locale.ENGLISH)

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
                    if (isToday) Color.WHITE else Color.argb(80, 255, 255, 255),
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
                    completed -> "✓"
                    isToday   -> "🔥"
                    isMissed  -> "✗"
                    else      -> ""
                }
                views.setTextViewText(DAY_CIRCLE_IDS[i], symbol)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }

        // ── Copy helpers ──────────────────────────────────────────────────

        /**
         * Returns contextual subtitle copy based on onboarding state,
         * username presence, and whether today has been completed.
         *
         * Priority:
         *   1. Not onboarded (no hobbies) → "Start your journey"
         *   2. Has name, today not done    → "<Name>! Streak?"
         *   3. Has name, today done        → "Keep it up, <Name>"
         *   4. No name, today done         → "Great job today!"
         *   5. No name, today not done     → "Keep the streak going!"
         */
        private fun subtitleFor(
            userName: String,
            hasHobbies: Boolean,
            todayCompleted: Boolean,
        ): String {
            if (!hasHobbies) return "Start your journey"
            if (userName.isNotBlank()) {
                return if (todayCompleted) "Keep it up, $userName" else "$userName! Streak?"
            }
            return if (todayCompleted) "Great job today!" else "Keep the streak going!"
        }
    }
}
