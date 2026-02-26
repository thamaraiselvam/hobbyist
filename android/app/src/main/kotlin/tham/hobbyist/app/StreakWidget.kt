package tham.hobbyist.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.os.Build
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale

/**
 * Shared widget renderer used by all streak widget designs.
 *
 * Each widget provider can point to a different layout while reusing the same
 * data and interaction logic.
 */
open class StreakWidget : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        for (widgetId in appWidgetIds) {
            updateWidget(
                context = context,
                appWidgetManager = appWidgetManager,
                widgetId = widgetId,
                widgetData = widgetData,
                layoutResId = layoutResId,
            )
        }
    }

    protected open val layoutResId: Int = R.layout.streak_widget

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
            widgetData: SharedPreferences,
            layoutResId: Int,
        ) {
            val streak = widgetData.getInt("streak_current", 0)
            val daysStr = widgetData.getString("streak_days", "0000000") ?: "0000000"
            val hasHobbies = widgetData.getInt("streak_has_hobbies", 0) == 1
            val userName = widgetData.getString("streak_user_name", "") ?: ""

            val views = RemoteViews(context.packageName, layoutResId)

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

            val days = daysStr.padEnd(7, '0')
            val todayCompleted = days.getOrElse(6) { '0' } == '1'

            views.setTextViewText(R.id.streak_hero, "\uD83D\uDD25 $streak")
            views.setTextViewText(
                R.id.widget_subtitle,
                subtitleFor(userName, hasHobbies, todayCompleted),
            )

            val sdf = SimpleDateFormat("EEE", Locale.ENGLISH)

            for (i in 0..6) {
                val completed = days.getOrElse(i) { '0' } == '1'
                val isToday = i == 6
                val isMissed = !isToday && !completed && hasHobbies

                val cal = Calendar.getInstance()
                cal.add(Calendar.DAY_OF_YEAR, -(6 - i))
                val label = sdf.format(cal.time)[0].uppercaseChar().toString()
                views.setTextViewText(DAY_LABEL_IDS[i], label)

                views.setTextColor(
                    DAY_LABEL_IDS[i],
                    if (isToday) Color.WHITE else Color.argb(140, 255, 255, 255),
                )

                val circleDrawable = when {
                    isToday && completed -> R.drawable.widget_day_done_today
                    isToday -> R.drawable.widget_day_today
                    completed -> R.drawable.widget_day_done
                    isMissed -> R.drawable.widget_day_missed
                    else -> R.drawable.widget_day_pending
                }
                views.setInt(DAY_CIRCLE_IDS[i], "setBackgroundResource", circleDrawable)

                val symbol = when {
                    completed -> "✓"
                    isToday -> "🔥"
                    else -> ""
                }
                views.setTextViewText(DAY_CIRCLE_IDS[i], symbol)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }

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

