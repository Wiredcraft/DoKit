package com.didichuxing.doraemonkit.kit.parameter.matrix

import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.util.Log

class OtherProcessService : Service() {
    var mInit = false
    override fun onBind(intent: Intent): IBinder? {
        Log.e(TAG, "Service started")
        if (mInit) {
            return null
        }
        mInit = true
        return null
    }

    override fun onDestroy() {
        Log.e(TAG, "Service onDestroy")
    }

    companion object {
        private const val TAG = "Matrix.OtherProcess"
    }
}
