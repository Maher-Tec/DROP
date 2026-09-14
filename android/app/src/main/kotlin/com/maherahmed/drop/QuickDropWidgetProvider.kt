package com.maherahmed.drop

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

class QuickDropWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.quick_drop_widget)
            views.setOnClickPendingIntent(
                R.id.widget_write,
                launchIntent(context, ACTION_WRITE, widgetId * 2),
            )
            views.setOnClickPendingIntent(
                R.id.widget_wordless,
                launchIntent(context, ACTION_WORDLESS, widgetId * 2 + 1),
            )
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun launchIntent(
        context: Context,
        action: String,
        requestCode: Int,
    ): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra(EXTRA_ACTION, action)
        }
        return PendingIntent.getActivity(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    companion object {
        const val EXTRA_ACTION = "quick_drop_action"
        const val ACTION_WRITE = "write"
        const val ACTION_WORDLESS = "wordless"
    }
}
