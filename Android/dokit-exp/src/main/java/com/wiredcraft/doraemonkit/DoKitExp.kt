package com.wiredcraft.doraemonkit

import android.app.Application
import com.didichuxing.doraemonkit.kit.blockmonitor.FileManager
import com.didichuxing.doraemonkit.kit.blockmonitor.core.BlockMonitorManager
import com.didichuxing.doraemonkit.kit.network.NetworkManager
import com.didichuxing.doraemonkit.kit.parameter.matrix.MatrixApplication
import com.didichuxing.doraemonkit.kit.performance.PerformanceDataManager
import com.wiredcraft.doraemonkit.kit.location.LocationManager

object DoKitExp {

    /**
     * 开启性能数据记录
     */
    fun startPerformanceRecording(app: Application) {
        // FPS
        PerformanceDataManager.getInstance().init()
        PerformanceDataManager.getInstance().startMonitorFrameInfo()
        // Network
        NetworkManager.get().startMonitor()
        // GPS
        LocationManager.init(app)
        // Launch Time
        FileManager.startSave()
        BlockMonitorManager.getInstance().start()
        // Memory Leak
        MatrixApplication.init(app)
        // CPU
        PerformanceDataManager.getInstance().startMonitorCPUInfo()
    }

}
