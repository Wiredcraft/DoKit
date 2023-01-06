package com.didichuxing.doraemondemo.module.leak

import android.content.ComponentName
import android.content.Intent
import android.content.ServiceConnection
import android.os.Bundle
import android.os.IBinder
import androidx.appcompat.app.AppCompatActivity
import com.didichuxing.doraemondemo.App
import com.didichuxing.doraemondemo.R
import com.didichuxing.doraemonkit.kit.parameter.matrix.OtherProcessService

/**
 * 模拟内存泄漏的activity
 */
class LeakActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_leak)
        App.leakActivity = this
        val intent = Intent()
        intent.component = ComponentName(this, OtherProcessService::class.java)
        bindService(
            intent,
            object : ServiceConnection {
                override fun onServiceConnected(name: ComponentName, service: IBinder) {}
                override fun onServiceDisconnected(name: ComponentName) {}
            },
            BIND_AUTO_CREATE
        )
    }
}
