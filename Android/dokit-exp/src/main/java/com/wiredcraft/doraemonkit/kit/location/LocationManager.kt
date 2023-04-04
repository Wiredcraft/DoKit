package com.wiredcraft.doraemonkit.kit.location

import android.content.Context
import android.location.GnssStatus
import android.location.GpsStatus
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import com.didichuxing.doraemonkit.database.LocationEntity
import com.didichuxing.doraemonkit.kit.core.DoKitViewManager

object LocationManager {

    fun init(context: Context) {
        GpsUtil.getLocationManager(
            context,
            @RequiresApi(Build.VERSION_CODES.N)
            object : GnssStatus.Callback() {
                override fun onStarted() {
                    super.onStarted()
                    GpsTimeUtil.start()
                }

                override fun onStopped() {
                    super.onStopped()
                    GpsTimeUtil.end()
                    DoKitViewManager.INSTANCE.counterDb.wclDao().insertLocation(LocationEntity(GpsTimeUtil.getDuration(), GpsTimeUtil.startMS))
                }
            },
            object : GpsStatus.Listener {
                override fun onGpsStatusChanged(event: Int) {
                    if (event === GpsStatus.GPS_EVENT_STARTED) {
                        Log.d("zmenaGPS", "GPS event started ")
                        GpsTimeUtil.start()
                    } else if (event === GpsStatus.GPS_EVENT_STOPPED) {
                        Log.d("zmenaGPS", "GPS event stopped ")
                        GpsTimeUtil.end()
                        DoKitViewManager.INSTANCE.counterDb.wclDao().insertLocation(LocationEntity(GpsTimeUtil.getDuration(), GpsTimeUtil.startMS))
                    } else if (event === GpsStatus.GPS_EVENT_FIRST_FIX) {
                        Log.d("zmenaGPS", "GPS fixace ")
                    } else if (event === GpsStatus.GPS_EVENT_SATELLITE_STATUS) {
                        Log.d("zmenaGPS", "GPS EVET NECO ")
                    }
                }
            }
        )
    }

}
