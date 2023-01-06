package com.didichuxing.doraemonkit.kit.parameter.matrix.canary

import android.app.Application
import com.tencent.matrix.memory.canary.MemoryCanaryConfig
import sample.tencent.matrix.kt.memory.canary.monitor.BackgroundMemoryMonitorBoot

/**
 * Created by Yves on 2021/11/5
 */
class MemoryCanaryBoot {
    companion object {
        private const val TAG = "MicroMsg.MemoryCanaryBoot"

        @JvmStatic
        fun configure(app: Application): MemoryCanaryConfig {
            return MemoryCanaryConfig(
                appBgSumPssMonitorConfigs = arrayOf(
                    BackgroundMemoryMonitorBoot.appStagedBgMemoryMonitorConfig,
                    BackgroundMemoryMonitorBoot.appDeepBgMemoryMonitorConfig
                ),
                processBgMemoryMonitorConfigs = arrayOf(
                    BackgroundMemoryMonitorBoot.procStagedBgMemoryMonitorConfig,
                    BackgroundMemoryMonitorBoot.procDeepBgMemoryMonitorConfig
                )
            )
        }
    }
}
