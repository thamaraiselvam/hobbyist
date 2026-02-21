package tham.hobbyist.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Build
import android.widget.RemoteViews

/**
 * Android home-screen widget that displays the user's current streak and a
 * 7-day week indicator.
 *
 * Data is written by [HomeWidgetService] (Dart) via the home_widget plugin's
 * SharedPreferences file ("HomeWidgetPlugin").  This provider reads that file
 * on every update and rebuilds the RemoteViews accordingly.
 *
 * Keys written by Dart:
 *   streak_current     – Int,    global streak day count
 *   streak_days        – String, 7 chars "1100100" (Mon→Sun, '1' = completed)
 *   streak_today_index – Int,    0 = Monday … 6 = Sunday
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
            val todayIndex = prefs.getInt("streak_today_index", 0).coerceIn(0, 6)

            val views = RemoteViews(context.packageName, R.layout.streak_widget)

            // ── Tap anywhere → open app ───────────────────────────────────
            val launchIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val piFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            else
                PendingIntent.FLAG_UPDATE_CURRENT

            val pendingIntent = PendingIntent.getActivity(context, 0, launchIntent, piFlags)
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            // ── Header: streak pill ───────────────────────────────────────
            views.setTextViewText(R.id.streak_pill, "🔥 $streak")
            views.setTextViewText(R.id.widget_subtitle, subtitleFor(streak))

            // ── CTA button ────────────────────────────────────────────────
            views.setTextViewText(R.id.cta_button, "⚡  ${ctaFor(streak)}")

            // ── Week indicator ────────────────────────────────────────────
            val days = daysStr.padEnd(7, '0')
            for (i in 0..6) {
                val completed = days.getOrElse(i) { '0' } == '1'
                val isToday   = i == todayIndex
                val isFuture  = i > todayIndex

                // Circle background
                val circleDrawable = when {
                    completed && isToday -> R.drawable.widget_day_done_today
                    completed            -> R.drawable.widget_day_done
                    isToday              -> R.drawable.widget_day_today
                    isFuture             -> R.drawable.widget_day_future
                    else                 -> R.drawable.widget_day_missed
                }
                views.setInt(DAY_CIRCLE_IDS[i], "setBackgroundResource", circleDrawable)

                // Circle text: checkmark on completed days, empty otherwise
                views.setTextViewText(DAY_CIRCLE_IDS[i], if (completed) "✓" else "")

                // Label brightness: full white for today, dim for others
                val labelColor = when {
                    isToday  -> Color.WHITE
                    isFuture -> Color.argb(50,  255, 255, 255)
                    else     -> Color.argb(100, 255, 255, 255)
                }
                views.setTextColor(DAY_LABEL_IDS[i], labelColor)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }

        // ── Copy helpers ──────────────────────────────────────────────────

        private fun subtitleFor(streak: Int): String = when {
            streak == 0  -> "Your journey starts now"
            streak == 1  -> "Great start — day 1 done!"
            streak < 7   -> "Building momentum…"
            streak < 30  -> "You're on a roll!"
            else         -> "You're unstoppable!"
        }

        private fun ctaFor(streak: Int): String = when {
            streak == 0 -> "Start your streak today"
            streak < 3  -> "Keep the momentum going"
            streak < 7  -> "Stay consistent"
            streak < 30 -> "You're doing great!"
            else        -> "Legendary streak — keep going"
        }
    }
}
