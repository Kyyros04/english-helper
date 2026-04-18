package com.example.english_helper

import android.service.quicksettings.TileService
import android.content.Intent
import android.app.PendingIntent
import android.net.Uri
import android.os.Build

class MyTileService : TileService() {
    override fun onClick() {
        super.onClick()
        
        val intent = Intent(Intent.ACTION_VIEW).apply {
            data = Uri.parse("englishhelper://add")
            // FLAG_ACTIVITY_CLEAR_TOP è la chiave: se l'app è già aperta, 
            // la "resetta" e le invia il nuovo comando.
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }

        val pendingIntent = PendingIntent.getActivity(
            this, 
            0, 
            intent, 
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startActivityAndCollapse(pendingIntent)
        } else {
            @Suppress("DEPRECATION")
            startActivityAndCollapse(intent)
        }
    }
}
