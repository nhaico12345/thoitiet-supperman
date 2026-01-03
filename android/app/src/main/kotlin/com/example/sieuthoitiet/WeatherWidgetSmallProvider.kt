package com.example.sieuthoitiet

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class WeatherWidgetSmallProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_small).apply {
                val temp = widgetData.getString("temp", "--")
                val location = widgetData.getString("location", "Loading...")
                val iconName = widgetData.getString("icon_name", "ic_cloudy")

                setTextViewText(R.id.widget_temp, "$temp°")
                setTextViewText(R.id.widget_location, location)

                // Update Icon
                val iconResId = context.resources.getIdentifier(iconName, "drawable", context.packageName)
                if (iconResId != 0) {
                    setImageViewResource(R.id.widget_icon, iconResId)
                }

                // Tap to open app
                val openIntent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                val pendingIntent = PendingIntent.getActivity(
                    context, 0, openIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_temp, pendingIntent)
                setOnClickPendingIntent(R.id.widget_location, pendingIntent)
                setOnClickPendingIntent(R.id.widget_icon, pendingIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

