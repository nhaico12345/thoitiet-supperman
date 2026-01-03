package com.example.sieuthoitiet

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class WeatherWidgetLargeProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_large).apply {
                // Basic data
                val temp = widgetData.getString("temp", "--")
                val location = widgetData.getString("location", "Loading...")
                val description = widgetData.getString("description", "-")
                val windSpeed = widgetData.getString("wind_speed", "-- km/h")
                val highLow = widgetData.getString("high_low", "H:-- L:--")
                val iconName = widgetData.getString("icon_name", "ic_cloudy")
                val updated = widgetData.getString("updated", "--:--")

                setTextViewText(R.id.widget_temp, "$temp°")
                setTextViewText(R.id.widget_location, location)
                setTextViewText(R.id.widget_description, description)
                setTextViewText(R.id.widget_wind, "💨 $windSpeed")
                setTextViewText(R.id.widget_high_low, highLow)
                setTextViewText(R.id.widget_updated, "Updated: $updated")

                // 5-day forecast
                for (i in 1..5) {
                    val dayName = widgetData.getString("day${i}_name", "--")
                    val dayDesc = widgetData.getString("day${i}_desc", "--")
                    val dayTemp = widgetData.getString("day${i}_temp", "--°/--°")

                    val dayNameId = context.resources.getIdentifier("widget_day${i}_name", "id", context.packageName)
                    val dayDescId = context.resources.getIdentifier("widget_day${i}_desc", "id", context.packageName)
                    val dayTempId = context.resources.getIdentifier("widget_day${i}_temp", "id", context.packageName)

                    if (dayNameId != 0) setTextViewText(dayNameId, dayName)
                    if (dayDescId != 0) setTextViewText(dayDescId, dayDesc)
                    if (dayTempId != 0) setTextViewText(dayTempId, dayTemp)
                }

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
                val refreshIntent = Intent(context, WeatherWidgetLargeProvider::class.java).apply {
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
