package com.example.english_helper

import android.service.quicksettings.TileService
import android.content.Intent
import android.app.PendingIntent
import android.net.Uri
import android.os.Build
import android.app.ActivityOptions
import android.graphics.Rect

class MyTileService : TileService() {
    override fun onClick() {
        super.onClick()
        
        val intent = Intent(Intent.ACTION_VIEW).apply {
            data = Uri.parse("englishhelper://add")
            // Fondamentale per il formato finestra
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_LAUNCH_ADJACENT
        }

        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Creiamo le opzioni per la finestra fluttuante
        val options = ActivityOptions.makeBasic()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            // Definisce un rettangolo (es. in alto a destra)
            // Parametri: left, top, right, bottom
            options.launchBounds = Rect(600, 100, 1000, 700)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startActivityAndCollapse(pendingIntent) 
            // Nota: Android 14+ a volte ignora launchBounds da TileService per sicurezza
        } else {
            @Suppress("DEPRECATION")
            startActivityAndCollapse(intent)
        }
    }
}