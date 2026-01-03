package com.example.sieuthoitiet

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class WeatherWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                val temp = widgetData.getString("temp", "--")
                val location = widgetData.getString("location", "Loading...")
                val description = widgetData.getString("description", "-")
                val windSpeed = widgetData.getString("wind_speed", "- km/h")
                val iconName = widgetData.getString("icon_name", "ic_cloudy")
                val updated = widgetData.getString("updated", "--:--")

                setTextViewText(R.id.widget_temp, "$temp°")
                setTextViewText(R.id.widget_location, location)
                setTextViewText(R.id.widget_description, "$description • Gió: $windSpeed")
                setTextViewText(R.id.widget_updated, "Updated: $updated")

                // Update Icon
                val iconResId = context.resources.getIdentifier(iconName, "drawable", context.packageName)
                if (iconResId != 0) {
                    setImageViewResource(R.id.widget_icon, iconResId)
                }
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
