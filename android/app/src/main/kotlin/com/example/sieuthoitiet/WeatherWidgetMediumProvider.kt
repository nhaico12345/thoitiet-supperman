package com.example.sieuthoitiet

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class WeatherWidgetMediumProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_medium).apply {
                // Basic data
                val temp = widgetData.getString("temp", "--")
                val location = widgetData.getString("location", "Loading...")
                val description = widgetData.getString("description", "-")
                val highLow = widgetData.getString("high_low", "H:-- L:--")
                val iconName = widgetData.getString("icon_name", "ic_cloudy")
                val updated = widgetData.getString("updated", "--:--")

                setTextViewText(R.id.widget_temp, "$temp°")
                setTextViewText(R.id.widget_location, location)
                setTextViewText(R.id.widget_description, description)
                setTextViewText(R.id.widget_high_low, highLow)
                setTextViewText(R.id.widget_updated, "Updated: $updated")

                // 3-hour forecast
                val hour1Time = widgetData.getString("hour1_time", "Now")
                val hour1Temp = widgetData.getString("hour1_temp", "--°")
                val hour2Time = widgetData.getString("hour2_time", "+1h")
                val hour2Temp = widgetData.getString("hour2_temp", "--°")
                val hour3Time = widgetData.getString("hour3_time", "+2h")
                val hour3Temp = widgetData.getString("hour3_temp", "--°")

                setTextViewText(R.id.widget_hour1_time, hour1Time)
                setTextViewText(R.id.widget_hour1_temp, hour1Temp)
                setTextViewText(R.id.widget_hour2_time, hour2Time)
                setTextViewText(R.id.widget_hour2_temp, hour2Temp)
                setTextViewText(R.id.widget_hour3_time, hour3Time)
                setTextViewText(R.id.widget_hour3_temp, hour3Temp)

                // Update Icon
                val iconResId = context.resources.getIdentifier(iconName, "drawable", context.packageName)
                if (iconResId != 0) {
                    setImageViewResource(R.id.widget_icon, iconResId)
                }

                // Tap to open app
                val openIntent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                val openPendingIntent = PendingIntent.getActivity(
                    context, 0, openIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_container, openPendingIntent)

                // Refresh button action
                val refreshIntent = Intent(context, WeatherWidgetMediumProvider::class.java).apply {
                    action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, intArrayOf(widgetId))
                }
                val refreshPendingIntent = PendingIntent.getBroadcast(
                    context, widgetId, refreshIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_refresh, refreshPendingIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
